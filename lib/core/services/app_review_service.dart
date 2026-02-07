import 'package:flutter/foundation.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service pour demander une note sur les stores
/// Utilise des heuristiques pour ne pas être intrusif
class AppReviewService {
  final SharedPreferences _prefs;
  final InAppReview _inAppReview = InAppReview.instance;

  // Clés de stockage
  static const String _keyDeliveryCount = 'review_delivery_count';
  static const String _keyLastPromptDate = 'review_last_prompt';
  static const String _keyHasReviewed = 'review_has_reviewed';
  static const String _keyPromptCount = 'review_prompt_count';
  static const String _keyNeverAsk = 'review_never_ask';

  // Configuration
  static const int minDeliveriesBeforePrompt = 3;
  static const int daysBetweenPrompts = 30;
  static const int maxPrompts = 3;

  AppReviewService(this._prefs);

  /// Incrémente le compteur de livraisons réussies
  Future<void> recordSuccessfulDelivery() async {
    final count = _prefs.getInt(_keyDeliveryCount) ?? 0;
    await _prefs.setInt(_keyDeliveryCount, count + 1);
    debugPrint('📊 Livraisons réussies: ${count + 1}');
  }

  /// Vérifie si on peut demander une review
  Future<bool> canRequestReview() async {
    // Vérifier si l'utilisateur a dit "ne plus demander"
    if (_prefs.getBool(_keyNeverAsk) ?? false) {
      debugPrint('⭐ Review: Utilisateur a demandé de ne plus demander');
      return false;
    }

    // Vérifier si déjà reviewé
    if (_prefs.getBool(_keyHasReviewed) ?? false) {
      debugPrint('⭐ Review: Déjà noté');
      return false;
    }

    // Vérifier le nombre de prompts
    final promptCount = _prefs.getInt(_keyPromptCount) ?? 0;
    if (promptCount >= maxPrompts) {
      debugPrint('⭐ Review: Nombre max de demandes atteint');
      return false;
    }

    // Vérifier le nombre minimum de livraisons
    final deliveryCount = _prefs.getInt(_keyDeliveryCount) ?? 0;
    if (deliveryCount < minDeliveriesBeforePrompt) {
      debugPrint('⭐ Review: Pas assez de livraisons ($deliveryCount/$minDeliveriesBeforePrompt)');
      return false;
    }

    // Vérifier le délai depuis la dernière demande
    final lastPromptStr = _prefs.getString(_keyLastPromptDate);
    if (lastPromptStr != null) {
      final lastPrompt = DateTime.tryParse(lastPromptStr);
      if (lastPrompt != null) {
        final daysSince = DateTime.now().difference(lastPrompt).inDays;
        if (daysSince < daysBetweenPrompts) {
          debugPrint('⭐ Review: Trop tôt ($daysSince/$daysBetweenPrompts jours)');
          return false;
        }
      }
    }

    // Vérifier si la fonctionnalité est disponible
    final isAvailable = await _inAppReview.isAvailable();
    if (!isAvailable) {
      debugPrint('⭐ Review: In-app review non disponible');
      return false;
    }

    return true;
  }

  /// Demande une review si les conditions sont remplies
  /// Retourne true si la review a été demandée
  Future<bool> requestReviewIfEligible() async {
    if (!await canRequestReview()) {
      return false;
    }

    try {
      debugPrint('⭐ Demande de review...');
      await _inAppReview.requestReview();
      
      // Mettre à jour les compteurs
      await _prefs.setString(_keyLastPromptDate, DateTime.now().toIso8601String());
      final promptCount = _prefs.getInt(_keyPromptCount) ?? 0;
      await _prefs.setInt(_keyPromptCount, promptCount + 1);
      
      debugPrint('⭐ Review demandée avec succès');
      return true;
    } catch (e) {
      debugPrint('❌ Erreur demande review: $e');
      return false;
    }
  }

  /// Force l'ouverture de la page store (pour un bouton "Noter l'app")
  Future<void> openStoreListing() async {
    try {
      // Remplacer par votre App ID réel
      await _inAppReview.openStoreListing(
        appStoreId: 'com.ouagachap.client', // iOS
      );
    } catch (e) {
      debugPrint('❌ Erreur ouverture store: $e');
    }
  }

  /// Marque comme "a donné une note"
  Future<void> markAsReviewed() async {
    await _prefs.setBool(_keyHasReviewed, true);
    debugPrint('⭐ Marqué comme noté');
  }

  /// Marque comme "ne plus demander"
  Future<void> neverAskAgain() async {
    await _prefs.setBool(_keyNeverAsk, true);
    debugPrint('⭐ Ne plus demander');
  }

  /// Réinitialise les compteurs (pour debug)
  Future<void> reset() async {
    await _prefs.remove(_keyDeliveryCount);
    await _prefs.remove(_keyLastPromptDate);
    await _prefs.remove(_keyHasReviewed);
    await _prefs.remove(_keyPromptCount);
    await _prefs.remove(_keyNeverAsk);
    debugPrint('⭐ Review service réinitialisé');
  }

  /// Stats pour debug
  Map<String, dynamic> getStats() {
    return {
      'deliveryCount': _prefs.getInt(_keyDeliveryCount) ?? 0,
      'promptCount': _prefs.getInt(_keyPromptCount) ?? 0,
      'hasReviewed': _prefs.getBool(_keyHasReviewed) ?? false,
      'neverAsk': _prefs.getBool(_keyNeverAsk) ?? false,
      'lastPrompt': _prefs.getString(_keyLastPromptDate),
    };
  }
}
