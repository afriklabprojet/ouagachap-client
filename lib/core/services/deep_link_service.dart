import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:app_links/app_links.dart';
import 'package:share_plus/share_plus.dart';

/// Service pour gérer les deep links et le partage
/// Permet d'ouvrir l'app via des liens et de partager des contenus
class DeepLinkService {
  final AppLinks _appLinks = AppLinks();
  
  StreamSubscription<Uri>? _linkSubscription;
  final _linkController = StreamController<DeepLinkData>.broadcast();
  
  /// Stream des deep links reçus
  Stream<DeepLinkData> get onDeepLink => _linkController.stream;

  // Configuration des schémas
  static const String scheme = 'ouagachap';
  static const String httpHost = 'ouagachap.bf';
  static const String httpsHost = 'www.ouagachap.bf';

  /// Initialise l'écoute des deep links
  Future<void> initialize() async {
    try {
      // Gérer le lien initial (si l'app a été ouverte via un lien)
      final initialLink = await _appLinks.getInitialLink();
      if (initialLink != null) {
        _handleDeepLink(initialLink);
      }

      // Écouter les liens entrants
      _linkSubscription = _appLinks.uriLinkStream.listen(
        _handleDeepLink,
        onError: (error) {
          debugPrint('❌ DeepLink error: $error');
        },
      );

      debugPrint('🔗 DeepLinkService initialisé');
    } catch (e) {
      debugPrint('❌ DeepLink init error: $e');
    }
  }

  void _handleDeepLink(Uri uri) {
    debugPrint('🔗 Deep link reçu: $uri');
    
    final data = _parseUri(uri);
    if (data != null) {
      _linkController.add(data);
    }
  }

  DeepLinkData? _parseUri(Uri uri) {
    final path = uri.path;
    final params = uri.queryParameters;

    // Pattern: ouagachap://order/{id}
    // Pattern: https://ouagachap.bf/order/{id}
    if (path.startsWith('/order/') || path.startsWith('/commande/')) {
      final orderId = path.split('/').last;
      return DeepLinkData(
        type: DeepLinkType.order,
        id: orderId,
        params: params,
      );
    }

    // Pattern: ouagachap://tracking/{code}
    if (path.startsWith('/tracking/') || path.startsWith('/suivi/')) {
      final trackingCode = path.split('/').last;
      return DeepLinkData(
        type: DeepLinkType.tracking,
        id: trackingCode,
        params: params,
      );
    }

    // Pattern: ouagachap://promo/{code}
    if (path.startsWith('/promo/')) {
      final promoCode = path.split('/').last;
      return DeepLinkData(
        type: DeepLinkType.promo,
        id: promoCode,
        params: params,
      );
    }

    // Pattern: ouagachap://invite/{referralCode}
    if (path.startsWith('/invite/') || path.startsWith('/parrain/')) {
      final referralCode = path.split('/').last;
      return DeepLinkData(
        type: DeepLinkType.referral,
        id: referralCode,
        params: params,
      );
    }

    debugPrint('⚠️ Deep link non reconnu: $uri');
    return null;
  }

  // ==================== GÉNÉRATION DE LIENS ====================

  /// Génère un lien de partage pour une commande
  String generateOrderLink(String orderId) {
    return 'https://$httpHost/order/$orderId';
  }

  /// Génère un lien de suivi
  String generateTrackingLink(String trackingCode) {
    return 'https://$httpHost/tracking/$trackingCode';
  }

  /// Génère un lien de parrainage
  String generateReferralLink(String referralCode) {
    return 'https://$httpHost/invite/$referralCode';
  }

  /// Génère un lien promo
  String generatePromoLink(String promoCode) {
    return 'https://$httpHost/promo/$promoCode';
  }

  // ==================== PARTAGE ====================

  /// Partage une commande
  Future<void> shareOrder({
    required String orderId,
    required String trackingCode,
    String? message,
  }) async {
    final link = generateTrackingLink(trackingCode);
    final text = message ?? 
        'Suivez ma commande OUAGA CHAP en temps réel :\n$link';
    
    await Share.share(text, subject: 'Suivi de commande OUAGA CHAP');
  }

  /// Partage un lien de parrainage
  Future<void> shareReferral({
    required String referralCode,
    String? userName,
  }) async {
    final link = generateReferralLink(referralCode);
    final name = userName ?? 'Un ami';
    final text = '$name vous invite à rejoindre OUAGA CHAP !\n\n'
        'Utilisez le code $referralCode pour obtenir une réduction sur votre première commande.\n\n'
        '$link';
    
    await Share.share(text, subject: 'Invitation OUAGA CHAP');
  }

  /// Partage un code promo
  Future<void> sharePromo({
    required String promoCode,
    String? description,
  }) async {
    final link = generatePromoLink(promoCode);
    final desc = description ?? 'une réduction';
    final text = '🎉 Profitez de $desc sur OUAGA CHAP avec le code $promoCode !\n\n$link';
    
    await Share.share(text, subject: 'Promo OUAGA CHAP');
  }

  /// Partage du texte générique
  Future<void> shareText(String text, {String? subject}) async {
    await Share.share(text, subject: subject);
  }

  /// Partage un fichier (reçu, facture...)
  Future<void> shareFile(String filePath, {String? text}) async {
    await Share.shareXFiles([XFile(filePath)], text: text);
  }

  /// Libère les ressources
  void dispose() {
    _linkSubscription?.cancel();
    _linkController.close();
  }
}

/// Types de deep links supportés
enum DeepLinkType {
  order,      // Détails d'une commande
  tracking,   // Suivi d'une commande
  promo,      // Code promo
  referral,   // Parrainage
}

/// Données d'un deep link parsé
class DeepLinkData {
  final DeepLinkType type;
  final String id;
  final Map<String, String> params;

  DeepLinkData({
    required this.type,
    required this.id,
    this.params = const {},
  });

  @override
  String toString() => 'DeepLinkData(type: $type, id: $id, params: $params)';
}
