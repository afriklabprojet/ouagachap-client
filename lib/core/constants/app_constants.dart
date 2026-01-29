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
    return 'https://api.ouagachap.bf/api/v1';
  }
  
  /// Timeouts en millisecondes
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;
  
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
