import 'package:dio/dio.dart';

/// Extrait un message d'erreur lisible par l'utilisateur.
/// Remplace e.toString() qui affiche des messages techniques incompréhensibles.
String extractUserFriendlyError(dynamic error) {
  if (error is DioException) {
    final response = error.response;
    final statusCode = response?.statusCode;

    // Extraire le message du serveur si disponible
    String? serverMessage;
    if (response?.data is Map) {
      serverMessage = response?.data['message'] ??
          response?.data['error']?['message'];
    }

    switch (statusCode) {
      case 401:
        return serverMessage ?? 'Session expirée. Veuillez vous reconnecter.';
      case 403:
        return serverMessage ?? 'Accès refusé.';
      case 404:
        return serverMessage ?? 'Ressource introuvable.';
      case 422:
        return serverMessage ?? 'Données invalides. Vérifiez vos informations.';
      case 429:
        return 'Trop de requêtes. Patientez quelques instants.';
      case 500:
      case 502:
      case 503:
        return 'Erreur serveur temporaire. Réessayez dans quelques instants.';
      default:
        if (error.type == DioExceptionType.connectionTimeout ||
            error.type == DioExceptionType.sendTimeout) {
          return 'Délai de connexion dépassé. Vérifiez votre connexion internet.';
        }
        if (error.type == DioExceptionType.receiveTimeout) {
          return 'Le serveur met trop de temps à répondre. Réessayez.';
        }
        if (error.type == DioExceptionType.connectionError) {
          return 'Impossible de se connecter. Vérifiez votre connexion internet.';
        }
        return serverMessage ?? 'Une erreur est survenue. Réessayez.';
    }
  }

  final msg = error.toString();
  // Ne jamais afficher de messages techniques longs
  if (msg.length > 80 || msg.contains('Exception') || msg.contains('Error:')) {
    return 'Une erreur est survenue. Réessayez.';
  }
  return msg;
}
