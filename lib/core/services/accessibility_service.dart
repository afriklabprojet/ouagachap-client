import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service de gestion de l'accessibilité
class AccessibilityService extends ChangeNotifier {
  static const String _reducedMotionKey = 'accessibility_reduced_motion';
  static const String _largeFontKey = 'accessibility_large_font';
  static const String _highContrastKey = 'accessibility_high_contrast';
  static const String _screenReaderOptimizedKey = 'accessibility_screen_reader';

  SharedPreferences? _prefs;

  bool _reducedMotion = false;
  bool _largeFont = false;
  bool _highContrast = false;
  bool _screenReaderOptimized = false;
  bool _initialized = false;

  bool get reducedMotion => _reducedMotion;
  bool get largeFont => _largeFont;
  bool get highContrast => _highContrast;
  bool get screenReaderOptimized => _screenReaderOptimized;
  bool get isInitialized => _initialized;

  /// Facteur de scale pour les polices (1.0 = normal, 1.2 = grand)
  double get fontScaleFactor => _largeFont ? 1.2 : 1.0;

  /// Durée des animations (réduite si reducedMotion activé)
  Duration getAnimationDuration(Duration normalDuration) {
    if (_reducedMotion) {
      return Duration.zero;
    }
    return normalDuration;
  }

  /// Initialise le service avec les préférences sauvegardées
  Future<void> init() async {
    if (_initialized) return;

    _prefs = await SharedPreferences.getInstance();
    
    _reducedMotion = _prefs?.getBool(_reducedMotionKey) ?? false;
    _largeFont = _prefs?.getBool(_largeFontKey) ?? false;
    _highContrast = _prefs?.getBool(_highContrastKey) ?? false;
    _screenReaderOptimized = _prefs?.getBool(_screenReaderOptimizedKey) ?? false;

    _initialized = true;
    notifyListeners();
  }

  /// Active/désactive la réduction des mouvements
  Future<void> setReducedMotion(bool value) async {
    if (_reducedMotion == value) return;
    
    _reducedMotion = value;
    await _prefs?.setBool(_reducedMotionKey, value);
    notifyListeners();
  }

  /// Active/désactive les grandes polices
  Future<void> setLargeFont(bool value) async {
    if (_largeFont == value) return;
    
    _largeFont = value;
    await _prefs?.setBool(_largeFontKey, value);
    notifyListeners();
  }

  /// Active/désactive le mode haut contraste
  Future<void> setHighContrast(bool value) async {
    if (_highContrast == value) return;
    
    _highContrast = value;
    await _prefs?.setBool(_highContrastKey, value);
    notifyListeners();
  }

  /// Active/désactive l'optimisation pour lecteur d'écran
  Future<void> setScreenReaderOptimized(bool value) async {
    if (_screenReaderOptimized == value) return;
    
    _screenReaderOptimized = value;
    await _prefs?.setBool(_screenReaderOptimizedKey, value);
    notifyListeners();
  }

  /// Annonce un message au lecteur d'écran
  void announce(String message, {TextDirection textDirection = TextDirection.ltr}) {
    SemanticsService.announce(message, textDirection);
  }

  /// Génère une description d'accessibilité pour un prix
  String formatPriceForAccessibility(int amount, {String currency = 'FCFA'}) {
    return '$amount francs CFA';
  }

  /// Génère une description d'accessibilité pour une distance
  String formatDistanceForAccessibility(double distanceKm) {
    if (distanceKm < 1) {
      return '${(distanceKm * 1000).round()} mètres';
    }
    return '${distanceKm.toStringAsFixed(1)} kilomètres';
  }

  /// Génère une description d'accessibilité pour une durée
  String formatDurationForAccessibility(Duration duration) {
    if (duration.inHours > 0) {
      final hours = duration.inHours;
      final minutes = duration.inMinutes.remainder(60);
      if (minutes > 0) {
        return '$hours heure${hours > 1 ? 's' : ''} et $minutes minute${minutes > 1 ? 's' : ''}';
      }
      return '$hours heure${hours > 1 ? 's' : ''}';
    }
    final minutes = duration.inMinutes;
    return '$minutes minute${minutes > 1 ? 's' : ''}';
  }

  /// Génère une description d'accessibilité pour un statut de commande
  String formatOrderStatusForAccessibility(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Commande en attente de confirmation';
      case 'confirmed':
        return 'Commande confirmée';
      case 'picking_up':
        return 'Le coursier récupère votre colis';
      case 'in_transit':
        return 'Colis en cours de livraison';
      case 'delivered':
        return 'Colis livré avec succès';
      case 'cancelled':
        return 'Commande annulée';
      default:
        return 'Statut: $status';
    }
  }
}

/// Widget wrapper pour ajouter des labels d'accessibilité
class AccessibleWidget extends StatelessWidget {
  final Widget child;
  final String? label;
  final String? hint;
  final String? value;
  final bool isButton;
  final bool isHeader;
  final bool isImage;
  final bool excludeSemantics;
  final VoidCallback? onTapHint;

  const AccessibleWidget({
    super.key,
    required this.child,
    this.label,
    this.hint,
    this.value,
    this.isButton = false,
    this.isHeader = false,
    this.isImage = false,
    this.excludeSemantics = false,
    this.onTapHint,
  });

  @override
  Widget build(BuildContext context) {
    if (excludeSemantics) {
      return ExcludeSemantics(child: child);
    }

    return Semantics(
      label: label,
      hint: hint,
      value: value,
      button: isButton,
      header: isHeader,
      image: isImage,
      onTapHint: onTapHint != null ? 'Activer' : null,
      child: child,
    );
  }
}

/// Extension pour ajouter facilement l'accessibilité
extension AccessibilityExtensions on Widget {
  /// Ajoute un label sémantique au widget
  Widget withSemantics({
    String? label,
    String? hint,
    String? value,
    bool isButton = false,
    bool isHeader = false,
  }) {
    return Semantics(
      label: label,
      hint: hint,
      value: value,
      button: isButton,
      header: isHeader,
      child: this,
    );
  }

  /// Exclut le widget des sémantiques (pour éléments décoratifs)
  Widget excludeFromSemantics() {
    return ExcludeSemantics(child: this);
  }

  /// Fusionne les sémantiques des enfants
  Widget mergeSemantics() {
    return MergeSemantics(child: this);
  }
}

/// Contraste colors helper pour mode haut contraste
class HighContrastColors {
  static const Color text = Colors.black;
  static const Color background = Colors.white;
  static const Color primary = Color(0xFF000080); // Navy blue
  static const Color error = Color(0xFF8B0000); // Dark red
  static const Color success = Color(0xFF006400); // Dark green
  static const Color border = Colors.black;

  static const Color textDark = Colors.white;
  static const Color backgroundDark = Colors.black;
  static const Color primaryDark = Color(0xFF00BFFF); // Deep sky blue
  static const Color errorDark = Color(0xFFFF6B6B); // Light red
  static const Color successDark = Color(0xFF90EE90); // Light green
  static const Color borderDark = Colors.white;
}

/// Widget qui adapte le contenu selon les paramètres d'accessibilité
class AdaptiveAccessibilityWidget extends StatelessWidget {
  final Widget Function(BuildContext context, AccessibilityService service) builder;

  const AdaptiveAccessibilityWidget({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    // Dans une vraie app, utiliser un Provider ou un autre mécanisme
    // Ici on utilise un singleton pour la démo
    return builder(context, _accessibilityServiceInstance);
  }
}

// Instance globale (à remplacer par injection de dépendances)
final AccessibilityService _accessibilityServiceInstance = AccessibilityService();

/// Getter pour accéder au service d'accessibilité
AccessibilityService get accessibilityService => _accessibilityServiceInstance;
