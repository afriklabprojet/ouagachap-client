import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

/// Service de gestion de la connectivité réseau.
/// 
/// **Pourquoi un ping HTTP en plus de connectivity_plus ?**
/// `connectivity_plus` vérifie uniquement si le WiFi ou la 3G/4G est activé.
/// En Afrique, il est courant d'avoir la 3G activée sans crédit data,
/// ce qui retourne "connecté" alors qu'aucune requête ne peut aboutir.
/// Le ping HTTP vers Google DNS confirme l'accès réel à Internet.
class ConnectivityService extends ChangeNotifier {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  
  bool _isOnline = true;
  bool _hasInternetAccess = true;
  ConnectivityResult _connectionType = ConnectivityResult.none;

  /// Vrai si le réseau est activé ET Internet est accessible
  bool get isOnline => _isOnline && _hasInternetAccess;
  bool get isOffline => !isOnline;
  
  /// Type de connexion brut (WiFi, Mobile, etc.)
  ConnectivityResult get connectionType => _connectionType;
  
  /// Type de connexion lisible
  String get connectionTypeString {
    switch (_connectionType) {
      case ConnectivityResult.wifi:
        return 'WiFi';
      case ConnectivityResult.mobile:
        return 'Mobile';
      case ConnectivityResult.ethernet:
        return 'Ethernet';
      case ConnectivityResult.bluetooth:
        return 'Bluetooth';
      case ConnectivityResult.vpn:
        return 'VPN';
      case ConnectivityResult.none:
      default:
        return 'Aucune connexion';
    }
  }

  ConnectivityService() {
    _initConnectivity();
  }

  Future<void> _initConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity();
      await _updateStatus(results);
    } catch (e) {
      debugPrint('⚠️ Connectivity: erreur init: $e');
    }

    _subscription = _connectivity.onConnectivityChanged.listen(
      (results) => _updateStatus(results),
    );
  }

  Future<void> _updateStatus(List<ConnectivityResult> results) async {
    // Prendre le premier résultat significatif
    final result = results.firstWhere(
      (r) => r != ConnectivityResult.none,
      orElse: () => ConnectivityResult.none,
    );
    
    final wasOnline = isOnline;
    _connectionType = result;
    _isOnline = result != ConnectivityResult.none;
    
    // Si le réseau semble actif, vérifier l'accès Internet réel
    if (_isOnline) {
      _hasInternetAccess = await _checkInternetAccess();
    } else {
      _hasInternetAccess = false;
    }
    
    // Notifier seulement si le statut a changé
    if (wasOnline != isOnline) {
      debugPrint('🌐 Connectivity: ${isOnline ? "en ligne" : "hors ligne"} '
          '(type: $connectionTypeString, internet: $_hasInternetAccess)');
      notifyListeners();
    }
  }

  /// Vérifie l'accès réel à Internet via un lookup DNS rapide.
  /// 
  /// Utilise une résolution DNS vers google.com (très léger ~100 bytes)
  /// plutôt qu'un HTTP GET complet, pour minimiser la consommation data.
  /// Timeout de 5s pour ne pas bloquer sur 3G lent.
  Future<bool> _checkInternetAccess() async {
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 5));
      return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  /// Vérifie la connectivité actuelle (avec ping Internet)
  Future<bool> checkConnectivity() async {
    final results = await _connectivity.checkConnectivity();
    await _updateStatus(results);
    return isOnline;
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
