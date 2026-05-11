import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'enhanced_notification_service.dart';

/// Service dédié à l'affichage des notifications locales et la gestion des canaux
class NotificationDisplayService {
  final FlutterLocalNotificationsPlugin _localNotifications;

  /// Callback quand l'utilisateur tape sur une notification foreground
  final void Function(Map<String, dynamic> data)? onNotificationTapped;

  NotificationDisplayService(
    this._localNotifications, {
    this.onNotificationTapped,
  });

  /// Configurer les notifications locales avec canaux multiples
  Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/launcher_icon',
    );

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
      onDidReceiveBackgroundNotificationResponse:
          _onBackgroundNotificationTapped,
    );

    if (!kIsWeb && Platform.isAndroid) {
      await _createAndroidChannels();
    }
  }

  /// Afficher une notification locale
  Future<void> showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    final channelId = _getChannelForType(message.data['type'] as String?);

    final androidDetails = AndroidNotificationDetails(
      channelId,
      _getChannelName(channelId),
      channelDescription: _getChannelDescription(channelId),
      importance: _getImportanceForChannel(channelId),
      priority: Priority.high,
      showWhen: true,
      icon: '@mipmap/launcher_icon',
      largeIcon: message.notification?.android?.imageUrl != null
          ? const DrawableResourceAndroidBitmap('@mipmap/launcher_icon')
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

  /// Annuler toutes les notifications affichées
  Future<void> cancelAll() async {
    await _localNotifications.cancelAll();
  }

  // ---------------------------------------------------------------------------
  // Notification tap callbacks
  // ---------------------------------------------------------------------------

  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('🔔 Notification tapped: ${response.payload}');
    if (response.payload != null && onNotificationTapped != null) {
      try {
        final data = json.decode(response.payload!) as Map<String, dynamic>;
        onNotificationTapped!(data);
      } catch (e) {
        debugPrint('Erreur parsing payload: $e');
      }
    }
  }

  @pragma('vm:entry-point')
  static void _onBackgroundNotificationTapped(NotificationResponse response) {
    debugPrint('🔔 [Background] Notification tapped: ${response.payload}');
  }

  // ---------------------------------------------------------------------------
  // Android channel creation
  // ---------------------------------------------------------------------------

  Future<void> _createAndroidChannels() async {
    final androidPlugin = _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidPlugin == null) return;

    const channels = [
      AndroidNotificationChannel(
        'order_status',
        'Statut des commandes',
        description: 'Mises à jour sur vos livraisons',
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
      ),
      AndroidNotificationChannel(
        'payments',
        'Paiements',
        description: 'Confirmations de paiement',
        importance: Importance.high,
        playSound: true,
      ),
      AndroidNotificationChannel(
        'chat',
        'Messages',
        description: 'Messages des coursiers',
        importance: Importance.high,
        playSound: true,
      ),
      AndroidNotificationChannel(
        'promotions',
        'Promotions',
        description: 'Offres et réductions',
        importance: Importance.defaultImportance,
      ),
      AndroidNotificationChannel(
        'general',
        'Général',
        description: 'Notifications générales',
        importance: Importance.defaultImportance,
      ),
    ];

    for (final channel in channels) {
      await androidPlugin.createNotificationChannel(channel);
    }
  }

  // ---------------------------------------------------------------------------
  // Channel helpers
  // ---------------------------------------------------------------------------

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
        .firstWhere(
          (c) => c.id == channelId,
          orElse: () => NotificationChannel.general,
        )
        .name;
  }

  String _getChannelDescription(String channelId) {
    return NotificationChannel.values
        .firstWhere(
          (c) => c.id == channelId,
          orElse: () => NotificationChannel.general,
        )
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
