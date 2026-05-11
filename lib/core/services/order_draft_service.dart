import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persiste le brouillon de commande pour éviter la perte de données
/// en cas d'interruption (appel, notification, perte réseau).
class OrderDraftService {
  static const String _key = 'order_draft';
  final SharedPreferences _prefs;

  OrderDraftService(this._prefs);

  /// Sauvegarde le brouillon de la commande en cours
  Future<void> saveDraft({
    String? pickupAddress,
    double? pickupLatitude,
    double? pickupLongitude,
    String? pickupContactName,
    String? pickupContactPhone,
    String? deliveryAddress,
    double? deliveryLatitude,
    double? deliveryLongitude,
    String? recipientName,
    String? recipientPhone,
    String? packageDescription,
    String? packageSize,
    String? paymentMethod,
    int? currentStep,
  }) async {
    final draft = <String, dynamic>{
      if (pickupAddress != null) 'pickupAddress': pickupAddress,
      if (pickupLatitude != null) 'pickupLatitude': pickupLatitude,
      if (pickupLongitude != null) 'pickupLongitude': pickupLongitude,
      if (pickupContactName != null) 'pickupContactName': pickupContactName,
      if (pickupContactPhone != null) 'pickupContactPhone': pickupContactPhone,
      if (deliveryAddress != null) 'deliveryAddress': deliveryAddress,
      if (deliveryLatitude != null) 'deliveryLatitude': deliveryLatitude,
      if (deliveryLongitude != null) 'deliveryLongitude': deliveryLongitude,
      if (recipientName != null) 'recipientName': recipientName,
      if (recipientPhone != null) 'recipientPhone': recipientPhone,
      if (packageDescription != null) 'packageDescription': packageDescription,
      if (packageSize != null) 'packageSize': packageSize,
      if (paymentMethod != null) 'paymentMethod': paymentMethod,
      if (currentStep != null) 'currentStep': currentStep,
      'savedAt': DateTime.now().toIso8601String(),
    };
    await _prefs.setString(_key, jsonEncode(draft));
  }

  /// Charge le brouillon sauvegardé, ou null s'il n'existe pas
  Map<String, dynamic>? loadDraft() {
    final json = _prefs.getString(_key);
    if (json == null) return null;
    try {
      final draft = jsonDecode(json) as Map<String, dynamic>;
      // Expirer les brouillons de plus de 24h
      final savedAt = DateTime.tryParse(draft['savedAt'] as String? ?? '');
      if (savedAt != null && DateTime.now().difference(savedAt).inHours > 24) {
        clearDraft();
        return null;
      }
      return draft;
    } catch (e) {
      debugPrint('[OrderDraft] Failed to parse draft, clearing: $e');
      clearDraft();
      return null;
    }
  }

  /// Vérifie si un brouillon existe
  bool hasDraft() => _prefs.containsKey(_key);

  /// Supprime le brouillon
  Future<void> clearDraft() => _prefs.remove(_key);
}
