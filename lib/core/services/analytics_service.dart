import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

/// Service d'analytics pour tracker les événements utilisateur
class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  FirebaseAnalytics? _analytics;
  FirebaseAnalyticsObserver? _observer;
  bool _initialized = false;

  /// Observer pour la navigation (à utiliser avec NavigatorObserver)
  FirebaseAnalyticsObserver? get observer => _observer;

  /// Vérifie si le service est initialisé
  bool get isInitialized => _initialized;

  /// Initialise Firebase Analytics
  Future<void> init() async {
    if (_initialized) return;

    try {
      _analytics = FirebaseAnalytics.instance;
      _observer = FirebaseAnalyticsObserver(analytics: _analytics!);
      _initialized = true;
      debugPrint('AnalyticsService: Initialized successfully');
    } catch (e) {
      debugPrint('AnalyticsService: Failed to initialize - $e');
    }
  }

  /// Définit l'ID utilisateur pour le tracking
  Future<void> setUserId(String? userId) async {
    if (!_initialized) return;
    try {
      await _analytics?.setUserId(id: userId);
    } catch (e) {
      debugPrint('AnalyticsService: Error setting user ID - $e');
    }
  }

  /// Définit une propriété utilisateur
  Future<void> setUserProperty({
    required String name,
    required String? value,
  }) async {
    if (!_initialized) return;
    try {
      await _analytics?.setUserProperty(name: name, value: value);
    } catch (e) {
      debugPrint('AnalyticsService: Error setting user property - $e');
    }
  }

  /// Log un événement personnalisé
  Future<void> logEvent({
    required String name,
    Map<String, Object>? parameters,
  }) async {
    if (!_initialized) return;
    try {
      await _analytics?.logEvent(name: name, parameters: parameters);
      debugPrint('AnalyticsService: Event logged - $name');
    } catch (e) {
      debugPrint('AnalyticsService: Error logging event - $e');
    }
  }

  /// Log un écran visité
  Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) async {
    if (!_initialized) return;
    try {
      await _analytics?.logScreenView(
        screenName: screenName,
        screenClass: screenClass,
      );
    } catch (e) {
      debugPrint('AnalyticsService: Error logging screen view - $e');
    }
  }

  // ========================================
  // Événements spécifiques à OUAGA CHAP
  // ========================================

  /// Utilisateur connecté
  Future<void> logLogin({String? method}) async {
    await logEvent(
      name: 'login',
      parameters: {'method': method ?? 'phone'},
    );
  }

  /// Utilisateur inscrit
  Future<void> logSignUp({String? method}) async {
    await logEvent(
      name: 'sign_up',
      parameters: {'method': method ?? 'phone'},
    );
  }

  /// Utilisateur déconnecté
  Future<void> logLogout() async {
    await logEvent(name: 'logout');
    await setUserId(null);
  }

  /// Commande créée
  Future<void> logOrderCreated({
    required String orderId,
    required int amount,
    required String deliveryType,
    String? vehicleType,
  }) async {
    final params = <String, Object>{
      'order_id': orderId,
      'amount': amount,
      'currency': 'XOF',
      'delivery_type': deliveryType,
    };
    if (vehicleType != null) params['vehicle_type'] = vehicleType;
    await logEvent(name: 'order_created', parameters: params);
  }

  /// Commande confirmée par le coursier
  Future<void> logOrderConfirmed({
    required String orderId,
    required String courierId,
  }) async {
    await logEvent(
      name: 'order_confirmed',
      parameters: {
        'order_id': orderId,
        'courier_id': courierId,
      },
    );
  }

  /// Commande livrée
  Future<void> logOrderDelivered({
    required String orderId,
    required int amount,
    required Duration deliveryDuration,
  }) async {
    await logEvent(
      name: 'order_delivered',
      parameters: {
        'order_id': orderId,
        'amount': amount,
        'currency': 'XOF',
        'delivery_duration_minutes': deliveryDuration.inMinutes,
      },
    );
  }

  /// Commande annulée
  Future<void> logOrderCancelled({
    required String orderId,
    required String reason,
    required String cancelledBy,
  }) async {
    await logEvent(
      name: 'order_cancelled',
      parameters: {
        'order_id': orderId,
        'reason': reason,
        'cancelled_by': cancelledBy,
      },
    );
  }

  /// Paiement initié
  Future<void> logPaymentInitiated({
    required String orderId,
    required int amount,
    required String paymentMethod,
  }) async {
    await logEvent(
      name: 'payment_initiated',
      parameters: {
        'order_id': orderId,
        'amount': amount,
        'currency': 'XOF',
        'payment_method': paymentMethod,
      },
    );
  }

  /// Paiement réussi
  Future<void> logPaymentSuccess({
    required String orderId,
    required int amount,
    required String paymentMethod,
    required String transactionId,
  }) async {
    await logEvent(
      name: 'purchase',
      parameters: {
        'transaction_id': transactionId,
        'value': amount.toDouble(),
        'currency': 'XOF',
        'payment_method': paymentMethod,
        'order_id': orderId,
      },
    );
  }

  /// Paiement échoué
  Future<void> logPaymentFailed({
    required String orderId,
    required String paymentMethod,
    required String errorMessage,
  }) async {
    await logEvent(
      name: 'payment_failed',
      parameters: {
        'order_id': orderId,
        'payment_method': paymentMethod,
        'error_message': errorMessage,
      },
    );
  }

  /// Note attribuée à un coursier
  Future<void> logCourierRated({
    required String orderId,
    required String courierId,
    required int rating,
  }) async {
    await logEvent(
      name: 'courier_rated',
      parameters: {
        'order_id': orderId,
        'courier_id': courierId,
        'rating': rating,
      },
    );
  }

  /// Recherche d'adresse
  Future<void> logAddressSearch({
    required String searchTerm,
    required int resultsCount,
  }) async {
    await logEvent(
      name: 'search',
      parameters: {
        'search_term': searchTerm,
        'results_count': resultsCount,
        'search_type': 'address',
      },
    );
  }

  /// Adresse ajoutée aux favoris
  Future<void> logAddressSaved({
    required String addressType,
  }) async {
    await logEvent(
      name: 'address_saved',
      parameters: {
        'address_type': addressType,
      },
    );
  }

  /// Erreur de l'application
  Future<void> logAppError({
    required String errorType,
    required String errorMessage,
    String? screenName,
  }) async {
    final params = <String, Object>{
      'error_type': errorType,
      'error_message': errorMessage.length > 100 
          ? errorMessage.substring(0, 100) 
          : errorMessage,
    };
    if (screenName != null) params['screen_name'] = screenName;
    await logEvent(name: 'app_error', parameters: params);
  }

  /// Mode sombre activé/désactivé
  Future<void> logThemeChanged({required bool isDarkMode}) async {
    await logEvent(
      name: 'theme_changed',
      parameters: {
        'theme': isDarkMode ? 'dark' : 'light',
      },
    );
  }

  /// Notification reçue
  Future<void> logNotificationReceived({
    required String notificationType,
    String? orderId,
  }) async {
    final params = <String, Object>{
      'notification_type': notificationType,
    };
    if (orderId != null) params['order_id'] = orderId;
    await logEvent(name: 'notification_received', parameters: params);
  }

  /// Notification ouverte
  Future<void> logNotificationOpened({
    required String notificationType,
    String? orderId,
  }) async {
    final params = <String, Object>{
      'notification_type': notificationType,
    };
    if (orderId != null) params['order_id'] = orderId;
    await logEvent(name: 'notification_opened', parameters: params);
  }

  /// Partage effectué
  Future<void> logShare({
    required String contentType,
    required String itemId,
    String? method,
  }) async {
    final params = <String, Object>{
      'content_type': contentType,
      'item_id': itemId,
    };
    if (method != null) params['method'] = method;
    await logEvent(name: 'share', parameters: params);
  }

  /// App rating demandée
  Future<void> logAppRatingPrompted() async {
    await logEvent(name: 'app_rating_prompted');
  }

  /// Support contacté
  Future<void> logSupportContacted({required String method}) async {
    await logEvent(
      name: 'support_contacted',
      parameters: {
        'method': method,
      },
    );
  }

  /// Tutorial complété
  Future<void> logTutorialComplete() async {
    await logEvent(name: 'tutorial_complete');
  }

  /// Deep link ouvert
  Future<void> logDeepLinkOpened({
    required String path,
    Map<String, String>? parameters,
  }) async {
    await logEvent(
      name: 'deep_link_opened',
      parameters: {
        'path': path,
        ...?parameters,
      },
    );
  }
}

/// Instance globale du service analytics
final analyticsService = AnalyticsService();
