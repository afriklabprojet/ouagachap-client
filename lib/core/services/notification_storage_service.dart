import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'enhanced_notification_service.dart';

/// Service dédié au stockage et à la gestion de l'historique des notifications
class NotificationStorageService {
  static const String _storageKey = 'pending_notifications';
  static const int _maxNotifications = 100;

  final FlutterLocalNotificationsPlugin _localNotifications;

  final List<AppNotification> _notifications = [];

  final _badgeCountController = StreamController<int>.broadcast();

  /// Stream du compteur de badges
  Stream<int> get onBadgeCountChange => _badgeCountController.stream;

  /// Liste des notifications (immutable)
  List<AppNotification> get notifications =>
      List.unmodifiable(_notifications);

  /// Nombre de notifications non lues
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  NotificationStorageService(this._localNotifications);

  /// Charger les notifications en attente depuis le stockage local
  Future<void> loadPendingNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getStringList(_storageKey) ?? [];

      for (final item in stored) {
        try {
          final json = jsonDecode(item) as Map<String, dynamic>;
          _notifications.add(AppNotification.fromJson(json));
        } catch (e) {
          debugPrint('Erreur parsing notification: $e');
        }
      }

      _notifications.sort((a, b) => b.receivedAt.compareTo(a.receivedAt));
      _badgeCountController.add(unreadCount);
    } catch (e) {
      debugPrint('Erreur chargement notifications: $e');
    }
  }

  /// Sauvegarder une nouvelle notification
  Future<void> saveNotification(AppNotification notification) async {
    _notifications.insert(0, notification);

    if (_notifications.length > _maxNotifications) {
      _notifications.removeRange(_maxNotifications, _notifications.length);
    }

    await _persistNotifications();
  }

  /// Marquer une notification comme lue
  Future<void> markAsRead(String notificationId) async {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      await _persistNotifications();
      await updateBadgeCount();
    }
  }

  /// Marquer toutes les notifications comme lues
  Future<void> markAllAsRead() async {
    for (var i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isRead: true);
    }
    await _persistNotifications();
    await updateBadgeCount();
  }

  /// Supprimer une notification
  Future<void> deleteNotification(String notificationId) async {
    _notifications.removeWhere((n) => n.id == notificationId);
    await _persistNotifications();
    await updateBadgeCount();
  }

  /// Effacer toutes les notifications
  Future<void> clearAllNotifications() async {
    _notifications.clear();
    await _persistNotifications();
    await updateBadgeCount();
  }

  /// Mettre à jour le compteur de badges
  Future<void> updateBadgeCount() async {
    final count = unreadCount;
    _badgeCountController.add(count);

    if (!kIsWeb && Platform.isIOS) {
      await _localNotifications
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(badge: true);
      await _localNotifications
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.getActiveNotifications();
      if (count == 0) {
        await _localNotifications.cancelAll();
      }
    }
  }

  /// Persister les notifications dans SharedPreferences
  Future<void> _persistNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data =
          _notifications.map((n) => json.encode(n.toJson())).toList();
      await prefs.setStringList(_storageKey, data);
    } catch (e) {
      debugPrint('Erreur persistence notifications: $e');
    }
  }

  void dispose() {
    _badgeCountController.close();
  }
}
