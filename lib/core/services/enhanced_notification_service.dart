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
    
    notifications.add(json.encode({
      'id': message.messageId,
      'title': message.notification?.title,
      'body': message.notification?.body,
      'data': message.data,
      'receivedAt': DateTime.now().toIso8601String(),
    }));
    
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
  orderStatus('order_status', 'Statut des commandes', 'Mises à jour sur vos livraisons'),
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
enum NotificationAction {
  track,
  call,
  rate,
  reply,
  view,
  orderAgain,
}

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
      imageUrl: message.notification?.android?.imageUrl ?? 
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

/// Service de notifications push Firebase amélioré
class EnhancedFirebaseNotificationService {
  static final EnhancedFirebaseNotificationService _instance = 
      EnhancedFirebaseNotificationService._internal();
  
  factory EnhancedFirebaseNotificationService() => _instance;
  
  EnhancedFirebaseNotificationService._internal();

  late final FirebaseMessaging _messaging;
  late final FlutterLocalNotificationsPlugin _localNotifications;
  
  String? _fcmToken;
  bool _isInitialized = false;
  
  // Streams pour les événements
  final _notificationController = StreamController<AppNotification>.broadcast();
  final _tokenController = StreamController<String>.broadcast();
  final _badgeCountController = StreamController<int>.broadcast();

  /// Stream des notifications reçues
  Stream<AppNotification> get onNotification => _notificationController.stream;
  
  /// Stream des changements de token
  Stream<String> get onTokenRefresh => _tokenController.stream;
  
  /// Stream du compteur de badges
  Stream<int> get onBadgeCountChange => _badgeCountController.stream;

  /// Token FCM actuel
  String? get fcmToken => _fcmToken;
  
  /// Est initialisé
  bool get isInitialized => _isInitialized;

  // =========================================================================
  // INITIALISATION
  // =========================================================================

  /// Initialiser le service de notifications
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialiser Firebase si pas déjà fait
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }

      _messaging = FirebaseMessaging.instance;
      _localNotifications = FlutterLocalNotificationsPlugin();

      // Configurer le handler background
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      // Demander les permissions
      await _requestPermissions();

      // Configurer les notifications locales avec canaux
      await _setupLocalNotifications();

      // Configurer les listeners
      _setupMessageListeners();

      // Obtenir le token FCM
      await _getToken();

      // Charger les notifications en attente
      await _loadPendingNotifications();

      _isInitialized = true;
      debugPrint('✅ Firebase Notifications initialisées');
    } catch (e) {
      debugPrint('❌ Erreur initialisation Firebase: $e');
    }
  }

  /// Demander les permissions de notification
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

    final authorized = settings.authorizationStatus == AuthorizationStatus.authorized ||
                       settings.authorizationStatus == AuthorizationStatus.provisional;

    debugPrint('📱 Permission status: ${settings.authorizationStatus}');

    // iOS: Configurer la présentation foreground
    if (!kIsWeb && Platform.isIOS) {
      await _messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }

    return authorized;
  }

  /// Configurer les notifications locales avec canaux multiples
  Future<void> _setupLocalNotifications() async {
    // Android settings
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    
    // iOS settings
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
      onDidReceiveBackgroundNotificationResponse: _onBackgroundNotificationTapped,
    );

    // Créer les canaux Android
    if (!kIsWeb && Platform.isAndroid) {
      final androidPlugin = _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      
      if (androidPlugin != null) {
        // Canal pour les commandes (haute priorité)
        await androidPlugin.createNotificationChannel(
          const AndroidNotificationChannel(
            'order_status',
            'Statut des commandes',
            description: 'Mises à jour sur vos livraisons',
            importance: Importance.high,
            playSound: true,
            enableVibration: true,
          ),
        );

        // Canal pour les paiements
        await androidPlugin.createNotificationChannel(
          const AndroidNotificationChannel(
            'payments',
            'Paiements',
            description: 'Confirmations de paiement',
            importance: Importance.high,
            playSound: true,
          ),
        );

        // Canal pour le chat
        await androidPlugin.createNotificationChannel(
          const AndroidNotificationChannel(
            'chat',
            'Messages',
            description: 'Messages des coursiers',
            importance: Importance.high,
            playSound: true,
          ),
        );

        // Canal pour les promotions
        await androidPlugin.createNotificationChannel(
          const AndroidNotificationChannel(
            'promotions',
            'Promotions',
            description: 'Offres et réductions',
            importance: Importance.defaultImportance,
          ),
        );

        // Canal général
        await androidPlugin.createNotificationChannel(
          const AndroidNotificationChannel(
            'general',
            'Général',
            description: 'Notifications générales',
            importance: Importance.defaultImportance,
          ),
        );
      }
    }
  }

  // =========================================================================
  // GESTION DES MESSAGES
  // =========================================================================

  /// Configurer les listeners de messages
  void _setupMessageListeners() {
    // Message reçu en foreground
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Message qui ouvre l'app depuis background
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

    // Message qui a ouvert l'app (cold start)
    _messaging.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        debugPrint('📬 [Initial] Message: ${message.notification?.title}');
        _handleMessageOpenedApp(message);
      }
    });

    // Écouter les changements de token
    _messaging.onTokenRefresh.listen((newToken) {
      debugPrint('🔑 Token FCM rafraîchi');
      _fcmToken = newToken;
      _tokenController.add(newToken);
    });
  }

  /// Gérer un message en foreground
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    debugPrint('📬 [Foreground] Message: ${message.notification?.title}');
    
    final notification = AppNotification.fromRemoteMessage(message);
    
    // Émettre sur le stream
    _notificationController.add(notification);
    
    // Sauvegarder
    await _saveNotification(notification);
    
    // Mettre à jour le badge
    await _updateBadgeCount();
    
    // Afficher la notification locale
    await _showLocalNotification(message);
  }

  /// Gérer un message qui ouvre l'app
  void _handleMessageOpenedApp(RemoteMessage message) {
    debugPrint('📬 [OpenedApp] Message: ${message.notification?.title}');
    
    final notification = AppNotification.fromRemoteMessage(message);
    _notificationController.add(notification);
    
    // Naviguer selon le type
    _handleNotificationNavigation(message.data);
  }

  /// Afficher une notification locale
  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    // Déterminer le canal
    final channelId = _getChannelForType(message.data['type'] as String?);
    
    final androidDetails = AndroidNotificationDetails(
      channelId,
      _getChannelName(channelId),
      channelDescription: _getChannelDescription(channelId),
      importance: _getImportanceForChannel(channelId),
      priority: Priority.high,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
      largeIcon: message.notification?.android?.imageUrl != null
          ? const DrawableResourceAndroidBitmap('@mipmap/ic_launcher')
          : null,
      styleInformation: BigTextStyleInformation(
        notification.body ?? '',
        contentTitle: notification.title,
      ),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      id: notification.hashCode,
      title: notification.title,
      body: notification.body,
      notificationDetails: details,
      payload: json.encode(message.data),
    );
  }

  /// Callback quand l'utilisateur tape sur une notification
  static void _onNotificationTapped(NotificationResponse response) {
    debugPrint('🔔 Notification tapped: ${response.payload}');
    
    if (response.payload != null) {
      try {
        final data = json.decode(response.payload!) as Map<String, dynamic>;
        EnhancedFirebaseNotificationService()._handleNotificationNavigation(data);
      } catch (e) {
        debugPrint('Erreur parsing payload: $e');
      }
    }
  }

  /// Callback background pour notification tap
  @pragma('vm:entry-point')
  static void _onBackgroundNotificationTapped(NotificationResponse response) {
    debugPrint('🔔 [Background] Notification tapped: ${response.payload}');
  }

  // =========================================================================
  // NAVIGATION
  // =========================================================================

  /// Callback pour la navigation (à définir par l'app)
  Function(String type, Map<String, dynamic> data)? onNavigate;

  /// Gérer la navigation après tap sur notification
  void _handleNotificationNavigation(Map<String, dynamic> data) {
    final type = data['type'] as String?;
    final orderId = data['order_id'] as String?;

    debugPrint('🧭 Navigation: type=$type, orderId=$orderId');

    if (onNavigate != null && type != null) {
      onNavigate!(type, data);
    }
  }

  // =========================================================================
  // TOKEN FCM
  // =========================================================================

  /// Obtenir le token FCM
  Future<String?> _getToken() async {
    try {
      if (kIsWeb) {
        const vapidKey = String.fromEnvironment(
          'FIREBASE_VAPID_KEY',
          defaultValue: '',
        );
        
        if (vapidKey.isEmpty) {
          debugPrint('⚠️ VAPID key non configurée');
          return null;
        }
        
        _fcmToken = await _messaging.getToken(vapidKey: vapidKey);
      } else {
        _fcmToken = await _messaging.getToken();
      }
      
      if (_fcmToken != null) {
        debugPrint('🔑 FCM Token: ${_fcmToken!.substring(0, 20)}...');
      }
      return _fcmToken;
    } catch (e) {
      debugPrint('❌ Erreur obtention token FCM: $e');
      return null;
    }
  }

  /// Enregistrer le token auprès du backend
  Future<bool> registerTokenWithBackend(ApiClient apiClient) async {
    if (_fcmToken == null) {
      await _getToken();
    }

    if (_fcmToken == null) {
      return false;
    }

    try {
      await apiClient.put('/auth/fcm-token', data: {
        'fcm_token': _fcmToken,
        'device_type': _getDeviceType(),
        'device_name': await _getDeviceName(),
      });
      debugPrint('✅ Token FCM enregistré sur le serveur');
      return true;
    } catch (e) {
      debugPrint('❌ Erreur enregistrement token: $e');
      return false;
    }
  }

  /// Obtenir le type d'appareil
  String _getDeviceType() {
    if (kIsWeb) return 'web';
    if (Platform.isAndroid) return 'android';
    if (Platform.isIOS) return 'ios';
    return 'unknown';
  }

  /// Obtenir le nom de l'appareil
  Future<String> _getDeviceName() async {
    // Simplified - could use device_info_plus for more details
    if (kIsWeb) return 'Web Browser';
    if (Platform.isAndroid) return 'Android Device';
    if (Platform.isIOS) return 'iOS Device';
    return 'Unknown Device';
  }

  // =========================================================================
  // GESTION DES NOTIFICATIONS STOCKÉES
  // =========================================================================

  final List<AppNotification> _notifications = [];
  
  /// Liste des notifications
  List<AppNotification> get notifications => List.unmodifiable(_notifications);
  
  /// Nombre de notifications non lues
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  /// Charger les notifications en attente
  Future<void> _loadPendingNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getStringList('pending_notifications') ?? [];
      
      for (final item in stored) {
        try {
          final json = jsonDecode(item) as Map<String, dynamic>;
          _notifications.add(AppNotification.fromJson(json));
        } catch (e) {
          debugPrint('Erreur parsing notification: $e');
        }
      }
      
      // Trier par date
      _notifications.sort((a, b) => b.receivedAt.compareTo(a.receivedAt));
      
      _badgeCountController.add(unreadCount);
    } catch (e) {
      debugPrint('Erreur chargement notifications: $e');
    }
  }

  /// Sauvegarder une notification
  Future<void> _saveNotification(AppNotification notification) async {
    _notifications.insert(0, notification);
    
    // Garder max 100 notifications
    if (_notifications.length > 100) {
      _notifications.removeRange(100, _notifications.length);
    }
    
    await _persistNotifications();
  }

  /// Persister les notifications
  Future<void> _persistNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = _notifications.map((n) => json.encode(n.toJson())).toList();
      await prefs.setStringList('pending_notifications', data);
    } catch (e) {
      debugPrint('Erreur persistence notifications: $e');
    }
  }

  /// Marquer une notification comme lue
  Future<void> markAsRead(String notificationId) async {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      await _persistNotifications();
      await _updateBadgeCount();
    }
  }

  /// Marquer toutes comme lues
  Future<void> markAllAsRead() async {
    for (var i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isRead: true);
    }
    await _persistNotifications();
    await _updateBadgeCount();
  }

  /// Supprimer une notification
  Future<void> deleteNotification(String notificationId) async {
    _notifications.removeWhere((n) => n.id == notificationId);
    await _persistNotifications();
    await _updateBadgeCount();
  }

  /// Effacer toutes les notifications
  Future<void> clearAllNotifications() async {
    _notifications.clear();
    await _persistNotifications();
    await _updateBadgeCount();
  }

  /// Mettre à jour le compteur de badges
  Future<void> _updateBadgeCount() async {
    final count = unreadCount;
    _badgeCountController.add(count);
    
    // TODO: Mettre à jour le badge de l'app (utiliser flutter_app_badger)
  }

  // =========================================================================
  // TOPICS
  // =========================================================================

  /// S'abonner à un topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
      debugPrint('✅ Abonné au topic: $topic');
    } catch (e) {
      debugPrint('❌ Erreur abonnement topic: $e');
    }
  }

  /// Se désabonner d'un topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
      debugPrint('✅ Désabonné du topic: $topic');
    } catch (e) {
      debugPrint('❌ Erreur désabonnement topic: $e');
    }
  }

  // =========================================================================
  // DÉCONNEXION
  // =========================================================================

  /// Supprimer le token (déconnexion)
  Future<void> deleteToken() async {
    try {
      await _messaging.deleteToken();
      _fcmToken = null;
      debugPrint('✅ Token FCM supprimé');
    } catch (e) {
      debugPrint('❌ Erreur suppression token: $e');
    }
  }

  /// Nettoyer les ressources
  void dispose() {
    _notificationController.close();
    _tokenController.close();
    _badgeCountController.close();
  }

  // =========================================================================
  // HELPERS
  // =========================================================================

  String _getChannelForType(String? type) {
    switch (type) {
      case 'order_created':
      case 'order_assigned':
      case 'order_picked_up':
      case 'order_delivered':
      case 'courier_arriving':
        return 'order_status';
      case 'payment_received':
      case 'earnings_credited':
        return 'payments';
      case 'chat_message':
        return 'chat';
      case 'promotion':
        return 'promotions';
      default:
        return 'general';
    }
  }

  String _getChannelName(String channelId) {
    return NotificationChannel.values
        .firstWhere((c) => c.id == channelId, orElse: () => NotificationChannel.general)
        .name;
  }

  String _getChannelDescription(String channelId) {
    return NotificationChannel.values
        .firstWhere((c) => c.id == channelId, orElse: () => NotificationChannel.general)
        .description;
  }

  Importance _getImportanceForChannel(String channelId) {
    switch (channelId) {
      case 'order_status':
      case 'payments':
      case 'chat':
        return Importance.high;
      default:
        return Importance.defaultImportance;
    }
  }
}
