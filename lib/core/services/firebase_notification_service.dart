import 'dart:convert';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../firebase_options.dart';
import '../network/api_client.dart';

/// Handler pour les messages en background (doit être top-level)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint('📬 [Background] Message reçu: ${message.messageId}');
}

/// Service de notifications push Firebase
class FirebaseNotificationService {
  static final FirebaseNotificationService _instance = 
      FirebaseNotificationService._internal();
  
  factory FirebaseNotificationService() => _instance;
  
  FirebaseNotificationService._internal();

  late final FirebaseMessaging _messaging;
  late final FlutterLocalNotificationsPlugin _localNotifications;
  
  String? _fcmToken;
  bool _isInitialized = false;

  /// Token FCM actuel
  String? get fcmToken => _fcmToken;

  /// Canal de notification Android
  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'ouaga_chap_channel',
    'OUAGA CHAP Notifications',
    description: 'Notifications pour les livraisons et commandes',
    importance: Importance.high,
    playSound: true,
    enableVibration: true,
  );

  /// Initialiser Firebase et les notifications
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialiser Firebase
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      _messaging = FirebaseMessaging.instance;
      _localNotifications = FlutterLocalNotificationsPlugin();

      // Configurer le handler background
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // Demander les permissions
      await _requestPermissions();

      // Configurer les notifications locales
      await _setupLocalNotifications();

      // Configurer les listeners
      _setupMessageListeners();

      // Obtenir le token FCM
      await _getToken();

      _isInitialized = true;
      debugPrint('✅ Firebase Notifications initialisées');
    } catch (e) {
      debugPrint('❌ Erreur initialisation Firebase: $e');
    }
  }

  /// Demander les permissions de notification
  Future<void> _requestPermissions() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    debugPrint('📱 Permission status: ${settings.authorizationStatus}');

    // iOS: Enregistrer pour les notifications distantes
    if (!kIsWeb && Platform.isIOS) {
      await _messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  /// Configurer les notifications locales (pour afficher en foreground)
  Future<void> _setupLocalNotifications() async {
    // Android
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    
    // iOS
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
    );

    // Créer le canal Android
    if (!kIsWeb && Platform.isAndroid) {
      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(_channel);
    }
  }

  /// Handler quand l'utilisateur tape sur une notification
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('🔔 Notification tapped: ${response.payload}');
    
    if (response.payload != null) {
      try {
        final data = json.decode(response.payload!);
        _handleNotificationNavigation(data);
      } catch (e) {
        debugPrint('Erreur parsing payload: $e');
      }
    }
  }

  /// Configurer les listeners de messages
  void _setupMessageListeners() {
    // Message reçu quand l'app est en foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('📬 [Foreground] Message: ${message.notification?.title}');
      _showLocalNotification(message);
    });

    // Quand l'utilisateur tape sur une notification (app en background)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('📬 [OpenedApp] Message: ${message.notification?.title}');
      _handleNotificationNavigation(message.data);
    });

    // Vérifier si l'app a été ouverte depuis une notification
    _messaging.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        debugPrint('📬 [Initial] Message: ${message.notification?.title}');
        _handleNotificationNavigation(message.data);
      }
    });

    // Écouter les changements de token
    _messaging.onTokenRefresh.listen((newToken) {
      debugPrint('🔑 Token FCM rafraîchi');
      _fcmToken = newToken;
      _sendTokenToServer(newToken);
    });
  }

  /// Obtenir le token FCM
  Future<String?> _getToken() async {
    try {
      if (kIsWeb) {
        // Pour le web, il faut une VAPID key depuis Firebase Console
        // En développement local, on désactive les push notifications web
        // Pour obtenir la VAPID key: Firebase Console > Project Settings > Cloud Messaging > Web Push certificates
        const vapidKey = String.fromEnvironment(
          'FIREBASE_VAPID_KEY',
          defaultValue: '',
        );
        
        if (vapidKey.isEmpty) {
          debugPrint('⚠️ VAPID key non configurée - Push notifications web désactivées');
          debugPrint('💡 Pour activer: ajoutez FIREBASE_VAPID_KEY dans les variables d\'environnement');
          return null;
        }
        
        _fcmToken = await _messaging.getToken(vapidKey: vapidKey);
      } else {
        _fcmToken = await _messaging.getToken();
      }
      
      debugPrint('🔑 FCM Token: ${_fcmToken?.substring(0, 20)}...');
      return _fcmToken;
    } catch (e) {
      debugPrint('❌ Erreur obtention token FCM: $e');
      // Ne pas bloquer l'app si les notifications ne fonctionnent pas
      return null;
    }
  }

  /// Envoyer le token au serveur Laravel
  Future<void> _sendTokenToServer(String token) async {
    try {
      // Cette méthode sera appelée après la connexion de l'utilisateur
      // Le token sera envoyé via l'API
      debugPrint('📤 Token à envoyer au serveur: ${token.substring(0, 20)}...');
    } catch (e) {
      debugPrint('❌ Erreur envoi token: $e');
    }
  }

  /// Enregistrer le token FCM auprès du backend
  Future<void> registerTokenWithBackend(ApiClient apiClient) async {
    if (_fcmToken == null) {
      await _getToken();
    }

    if (_fcmToken != null) {
      try {
        await apiClient.post('/user/fcm-token', data: {
          'fcm_token': _fcmToken,
          'device_type': _getDeviceType(),
        });
        debugPrint('✅ Token FCM enregistré sur le serveur');
      } catch (e) {
        debugPrint('❌ Erreur enregistrement token: $e');
      }
    }
  }

  /// Obtenir le type d'appareil
  String _getDeviceType() {
    if (kIsWeb) return 'web';
    if (Platform.isAndroid) return 'android';
    if (Platform.isIOS) return 'ios';
    return 'unknown';
  }

  /// Afficher une notification locale (foreground)
  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    const androidDetails = AndroidNotificationDetails(
      'ouaga_chap_channel',
      'OUAGA CHAP Notifications',
      channelDescription: 'Notifications pour les livraisons et commandes',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
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

  /// Gérer la navigation après tap sur notification
  void _handleNotificationNavigation(Map<String, dynamic> data) {
    final type = data['type'] as String?;
    final orderId = data['order_id'] as String?;

    debugPrint('🧭 Navigation: type=$type, orderId=$orderId');

    // TODO: Implémenter la navigation selon le type de notification
    // Exemples:
    // - 'order_assigned' -> Aller à la page de commande
    // - 'order_picked_up' -> Aller au suivi
    // - 'order_delivered' -> Aller à la confirmation
    // - 'incoming_order' -> Aller aux colis entrants
    // - 'wallet_credited' -> Aller au wallet
  }

  /// S'abonner à un topic (ex: pour les promotions)
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
}
