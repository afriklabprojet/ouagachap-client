import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../firebase_options.dart';
import '../network/api_client.dart';
import 'notification_display_service.dart';
import 'notification_storage_service.dart';
import 'notification_token_service.dart';

/// Handler pour les messages en background (doit être top-level)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint('📬 [Background] Message reçu: ${message.messageId}');

  // Sauvegarder la notification pour l'afficher plus tard
  await _saveNotificationToStorage(message);
}

/// Sauvegarder une notification dans le stockage local
Future<void> _saveNotificationToStorage(RemoteMessage message) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final notifications = prefs.getStringList('pending_notifications') ?? [];

    notifications.add(
      json.encode({
        'id': message.messageId,
        'title': message.notification?.title,
        'body': message.notification?.body,
        'data': message.data,
        'receivedAt': DateTime.now().toIso8601String(),
      }),
    );

    // Garder max 50 notifications
    if (notifications.length > 50) {
      notifications.removeRange(0, notifications.length - 50);
    }

    await prefs.setStringList('pending_notifications', notifications);
  } catch (e) {
    debugPrint('Erreur sauvegarde notification: $e');
  }
}

/// Types de canaux de notification
enum NotificationChannel {
  orderStatus(
    'order_status',
    'Statut des commandes',
    'Mises à jour sur vos livraisons',
  ),
  payments('payments', 'Paiements', 'Confirmations de paiement'),
  chat('chat', 'Messages', 'Messages des coursiers'),
  promotions('promotions', 'Promotions', 'Offres et réductions'),
  general('general', 'Général', 'Notifications générales');

  final String id;
  final String name;
  final String description;

  const NotificationChannel(this.id, this.name, this.description);
}

/// Type d'action de notification
enum NotificationAction { track, call, rate, reply, view, orderAgain }

/// Représente une notification reçue
class AppNotification {
  final String id;
  final String title;
  final String body;
  final String? imageUrl;
  final Map<String, dynamic> data;
  final DateTime receivedAt;
  final bool isRead;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    this.imageUrl,
    required this.data,
    required this.receivedAt,
    this.isRead = false,
  });

  String? get type => data['type'] as String?;
  String? get orderId => data['order_id'] as String?;

  factory AppNotification.fromRemoteMessage(RemoteMessage message) {
    return AppNotification(
      id: message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: message.notification?.title ?? 'OUAGA CHAP',
      body: message.notification?.body ?? '',
      imageUrl:
          message.notification?.android?.imageUrl ??
          message.notification?.apple?.imageUrl,
      data: message.data,
      receivedAt: message.sentTime ?? DateTime.now(),
    );
  }

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as String,
      title: json['title'] as String? ?? 'OUAGA CHAP',
      body: json['body'] as String? ?? '',
      imageUrl: json['imageUrl'] as String?,
      data: (json['data'] as Map<String, dynamic>?) ?? {},
      receivedAt: DateTime.parse(json['receivedAt'] as String),
      isRead: json['isRead'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'body': body,
    'imageUrl': imageUrl,
    'data': data,
    'receivedAt': receivedAt.toIso8601String(),
    'isRead': isRead,
  };

  AppNotification copyWith({bool? isRead}) {
    return AppNotification(
      id: id,
      title: title,
      body: body,
      imageUrl: imageUrl,
      data: data,
      receivedAt: receivedAt,
      isRead: isRead ?? this.isRead,
    );
  }
}

/// Service de notifications push Firebase amélioré (orchestrateur)
///
/// Délègue les responsabilités à des services spécialisés :
/// - [NotificationTokenService] : gestion du token FCM
/// - [NotificationDisplayService] : affichage des notifications locales
/// - [NotificationStorageService] : persistance et historique
class EnhancedFirebaseNotificationService {
  static final EnhancedFirebaseNotificationService _instance =
      EnhancedFirebaseNotificationService._internal();

  factory EnhancedFirebaseNotificationService() => _instance;

  EnhancedFirebaseNotificationService._internal();

  late final FirebaseMessaging _messaging;
  late NotificationTokenService _tokenService;
  late NotificationDisplayService _displayService;
  late NotificationStorageService _storageService;

  bool _isInitialized = false;

  // Stream pour les notifications reçues en temps réel
  final _notificationController = StreamController<AppNotification>.broadcast();
  final _tokenController = StreamController<String>.broadcast();

  // Firebase listener subscriptions
  StreamSubscription<RemoteMessage>? _onMessageSub;
  StreamSubscription<RemoteMessage>? _onMessageOpenedSub;
  StreamSubscription<String>? _onTokenRefreshSub;

  /// Stream des notifications reçues
  Stream<AppNotification> get onNotification => _notificationController.stream;

  /// Stream des changements de token
  Stream<String> get onTokenRefresh => _tokenController.stream;

  /// Stream du compteur de badges (délégué au storage service)
  Stream<int> get onBadgeCountChange => _storageService.onBadgeCountChange;

  /// Token FCM actuel
  String? get fcmToken => _tokenService.fcmToken;

  /// Est initialisé
  bool get isInitialized => _isInitialized;

  /// Liste des notifications
  List<AppNotification> get notifications => _storageService.notifications;

  /// Nombre de notifications non lues
  int get unreadCount => _storageService.unreadCount;

  /// Callback pour la navigation (à définir par l'app)
  Function(String type, Map<String, dynamic> data)? onNavigate;

  // =========================================================================
  // INITIALISATION
  // =========================================================================

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }

      _messaging = FirebaseMessaging.instance;
      final localNotifications = FlutterLocalNotificationsPlugin();

      // Créer les sous-services
      _tokenService = NotificationTokenService(_messaging);
      _displayService = NotificationDisplayService(
        localNotifications,
        onNotificationTapped: _handleNotificationNavigation,
      );
      _storageService = NotificationStorageService(localNotifications);

      // Configurer le handler background
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      // Demander les permissions
      await _requestPermissions();

      // Initialiser les sous-services
      await _displayService.initialize();
      await _tokenService.getToken();
      await _storageService.loadPendingNotifications();

      // Configurer les listeners
      _setupMessageListeners();

      _isInitialized = true;
      debugPrint('✅ Firebase Notifications initialisées');
    } catch (e) {
      debugPrint('❌ Erreur initialisation Firebase: $e');
    }
  }

  Future<bool> _requestPermissions() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    final authorized =
        settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;

    debugPrint('📱 Permission status: ${settings.authorizationStatus}');

    if (!kIsWeb && Platform.isIOS) {
      await _messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }

    return authorized;
  }

  // =========================================================================
  // GESTION DES MESSAGES
  // =========================================================================

  void _setupMessageListeners() {
    _onMessageSub = FirebaseMessaging.onMessage.listen(
      _handleForegroundMessage,
    );
    _onMessageOpenedSub = FirebaseMessaging.onMessageOpenedApp.listen(
      _handleMessageOpenedApp,
    );

    _messaging.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        debugPrint('📬 [Initial] Message: ${message.notification?.title}');
        _handleMessageOpenedApp(message);
      }
    });

    _onTokenRefreshSub = _messaging.onTokenRefresh.listen((newToken) {
      debugPrint('🔑 Token FCM rafraîchi');
      _tokenController.add(newToken);
    });
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    debugPrint('📬 [Foreground] Message: ${message.notification?.title}');

    final notification = AppNotification.fromRemoteMessage(message);
    _notificationController.add(notification);

    await _storageService.saveNotification(notification);
    await _storageService.updateBadgeCount();
    await _displayService.showLocalNotification(message);
  }

  void _handleMessageOpenedApp(RemoteMessage message) {
    debugPrint('📬 [OpenedApp] Message: ${message.notification?.title}');

    final notification = AppNotification.fromRemoteMessage(message);
    _notificationController.add(notification);
    _handleNotificationNavigation(message.data);
  }

  void _handleNotificationNavigation(Map<String, dynamic> data) {
    final type = data['type'] as String?;
    final orderId = data['order_id'] as String?;
    debugPrint('🧭 Navigation: type=$type, orderId=$orderId');

    if (onNavigate != null && type != null) {
      onNavigate!(type, data);
    }
  }

  // =========================================================================
  // DÉLÉGATION TOKEN
  // =========================================================================

  Future<bool> registerTokenWithBackend(ApiClient apiClient) =>
      _tokenService.registerTokenWithBackend(apiClient);

  Future<void> deleteToken() => _tokenService.deleteToken();

  // =========================================================================
  // DÉLÉGATION STOCKAGE
  // =========================================================================

  Future<void> markAsRead(String notificationId) =>
      _storageService.markAsRead(notificationId);

  Future<void> markAllAsRead() => _storageService.markAllAsRead();

  Future<void> deleteNotification(String notificationId) =>
      _storageService.deleteNotification(notificationId);

  Future<void> clearAllNotifications() =>
      _storageService.clearAllNotifications();

  // =========================================================================
  // TOPICS
  // =========================================================================

  Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
      debugPrint('✅ Abonné au topic: $topic');
    } catch (e) {
      debugPrint('❌ Erreur abonnement topic: $e');
    }
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
      debugPrint('✅ Désabonné du topic: $topic');
    } catch (e) {
      debugPrint('❌ Erreur désabonnement topic: $e');
    }
  }

  // =========================================================================
  // NETTOYAGE
  // =========================================================================

  void dispose() {
    _onMessageSub?.cancel();
    _onMessageOpenedSub?.cancel();
    _onTokenRefreshSub?.cancel();
    _notificationController.close();
    _tokenController.close();
    _storageService.dispose();
  }
}
