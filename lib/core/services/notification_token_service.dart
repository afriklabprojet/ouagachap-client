import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../network/api_client.dart';

/// Service dédié à la gestion du token FCM
class NotificationTokenService {
  final FirebaseMessaging _messaging;

  String? _fcmToken;

  NotificationTokenService(this._messaging);

  /// Token FCM actuel
  String? get fcmToken => _fcmToken;

  /// Obtenir le token FCM
  Future<String?> getToken() async {
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
      await getToken();
    }

    if (_fcmToken == null) {
      return false;
    }

    try {
      await apiClient.put(
        'auth/fcm-token',
        data: {
          'fcm_token': _fcmToken,
          'device_type': _getDeviceType(),
          'device_name': _getDeviceName(),
        },
      );
      debugPrint('✅ Token FCM enregistré sur le serveur');
      return true;
    } catch (e) {
      debugPrint('❌ Erreur enregistrement token: $e');
      return false;
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

  String _getDeviceType() {
    if (kIsWeb) return 'web';
    if (Platform.isAndroid) return 'android';
    if (Platform.isIOS) return 'ios';
    return 'unknown';
  }

  String _getDeviceName() {
    if (kIsWeb) return 'Web Browser';
    if (Platform.isAndroid) return 'Android Device';
    if (Platform.isIOS) return 'iOS Device';
    return 'Unknown Device';
  }
}
