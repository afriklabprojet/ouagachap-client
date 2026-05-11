import 'package:flutter/foundation.dart';

/// Constantes de l'application OUAGA CHAP
class AppConstants {
  AppConstants._();

  // ═══════════════════════════════════════════════════════════════
  // API CONFIGURATION
  // ═══════════════════════════════════════════════════════════════

  static const String appName = 'OUAGA CHAP';
  static const String appVersion = '1.0.0';

  /// URL de base de l'API - change automatiquement selon le mode
  static String get baseUrl {
    if (kDebugMode) {
      return 'http://127.0.0.1:8000/api/v1';
    }
    return 'https://ouagachap.pro/api/v1';
  }

  /// URL WebSocket pour le suivi en temps réel (Laravel Reverb)
  static String get wsBaseUrl {
    if (kDebugMode) {
      return 'http://127.0.0.1:8080';
    }
    return 'https://ws.ouagachap.pro';
  }

  /// Clé d'application WebSocket (Laravel Reverb/Pusher).
  ///
  /// Injectée via `--dart-define=WS_APP_KEY=xxxxx` au build.
  /// Ne jamais mettre la valeur réelle en clair ici.
  // ignore: do_not_use_environment
  static const String wsAppKey = String.fromEnvironment(
    'WS_APP_KEY',
    defaultValue: '', // pas de fallback en clair — utiliser AppConfig.wsAppKey
  );

  /// Timeouts en millisecondes.
  ///
  /// Valeurs optimisées pour les réseaux 3G africains :
  /// - connectTimeout : 15s suffit pour établir la connexion TCP+TLS
  /// - receiveTimeout : 20s pour recevoir la réponse complète
  /// - sendTimeout    : 30s pour les uploads multipart (photos de profil)
  ///
  /// Des valeurs trop élevées (30s+) gèlent l'UI trop longtemps
  /// avant d'afficher un message d'erreur utile à l'utilisateur.
  static const int connectTimeout = 15000;
  static const int receiveTimeout = 20000;
  static const int sendTimeout = 30000;

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String onboardingKey = 'onboarding_completed';
  static const String languageKey = 'app_language';

  // OTP Configuration
  static const int otpLength = 6;
  static const int otpExpiryMinutes = 5;
  static const int otpResendSeconds = 60;

  // Map Configuration (Ouagadougou center)
  static const double defaultLatitude = 12.3714;
  static const double defaultLongitude = -1.5197;
  static const double defaultZoom = 14.0;

  // Pricing (en FCFA)
  static const int baseFare = 500;
  static const int pricePerKm = 200;
  static const int minimumFare = 500;

  // Phone prefix Burkina Faso
  static const String phonePrefix = '+226';
  static const String phonePrefixDisplay = '🇧🇫 +226';

  // Validation
  static const int minPhoneLength = 8;
  static const int maxPhoneLength = 8;
  static const String phonePattern = r'^[0-9]{8}$';

  // Pagination
  static const int defaultPageSize = 20;

  // ═══════════════════════════════════════════════════════════════
  // UI DURATIONS
  // ═══════════════════════════════════════════════════════════════

  /// Auto-scroll carousel (home page promos, onboarding)
  static const Duration autoScrollInterval = Duration(seconds: 5);

  /// Délai entre rafraîchissements de messages (chat)
  static const Duration messageRefreshInterval = Duration(seconds: 5);

  /// Animation standard (transitions, fade-in)
  static const Duration animationDuration = Duration(milliseconds: 300);

  /// Debounce recherche d'adresse (frappe clavier)
  static const Duration searchDebounce = Duration(milliseconds: 500);

  /// Timeout attente réponse BLoC (ex: save profile)
  static const Duration blocResponseTimeout = Duration(seconds: 15);

  // ═══════════════════════════════════════════════════════════════
  // LIMITS
  // ═══════════════════════════════════════════════════════════════

  /// Max points dans l'historique de route coursier (tracking)
  static const int maxRouteHistoryPoints = 500;

  /// Max tentatives de reconnexion WebSocket
  static const int maxReconnectAttempts = 15;

  /// Longueur minimum du nom utilisateur
  static const int minNameLength = 3;

  /// Dimensions max image upload
  static const int maxImageWidth = 1024;
  static const int maxImageHeight = 1024;

  /// Qualité compression image (0-100)
  static const int imageCompressionQuality = 80;
}

/// Endpoints de l'API centralisés
class ApiEndpoints {
  ApiEndpoints._();

  // Auth
  static const String sendOtp = '/auth/otp/send';
  static const String verifyOtp = '/auth/otp/verify';
  static const String logout = '/auth/logout';
  static const String me = '/auth/me';

  // Orders
  static const String orders = '/orders';
  static String orderDetails(String id) => '/orders/$id';
  static String cancelOrder(String id) => '/orders/$id/cancel';
  static String rateCourier(String id) => '/orders/$id/rate-courier';
  static const String calculatePrice = '/orders/calculate-price';

  // Incoming Orders
  static const String incomingOrders = '/incoming-orders';
  static String incomingOrderDetails(String id) => '/incoming-orders/$id';
  static String trackIncomingOrder(String id) => '/incoming-orders/$id/track';
  static String confirmReceipt(String id) => '/incoming-orders/$id/confirm';

  // Profile
  static const String profile = '/profile';
  static const String updateFcmToken = '/profile/fcm-token';

  // Wallet
  static const String wallet = '/wallet';
  static const String walletTransactions = '/wallet/transactions';

  // Notifications
  static const String notifications = '/notifications';
  static String markNotificationRead(String id) => '/notifications/$id/read';

  // Support
  static const String faqs = '/faqs';
  static const String complaints = '/complaints';
}
