import 'dart:async';
import 'package:dio/dio.dart';
import '../services/secure_token_service.dart';
import '../di/injection.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';

/// Intercepteur avec refresh token automatique sur 401
class ApiInterceptor extends QueuedInterceptor {
  final SecureTokenService _tokenService;

  bool _isRefreshing = false;
  final List<Completer<void>> _pendingRequests = [];

  ApiInterceptor(this._tokenService);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = _tokenService.token;
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    super.onRequest(options, handler);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Gérer les erreurs d'authentification (401)
    if (err.response?.statusCode == 401 &&
        !err.requestOptions.path.contains('refresh-token')) {
      // Ne pas tenter de refresh si on est déjà sur l'endpoint refresh-token
      if (err.requestOptions.path.contains('logout')) {
        // Ne pas refresh si on est en train de logout
        return super.onError(err, handler);
      }

      try {
        // Attendre si un refresh est déjà en cours
        if (_isRefreshing) {
          final completer = Completer<void>();
          _pendingRequests.add(completer);
          await completer.future;

          // Re-tenter la requête avec le nouveau token
          final options = err.requestOptions;
          final newToken = _tokenService.token;
          if (newToken != null) {
            options.headers['Authorization'] = 'Bearer $newToken';
            final response = await Dio().fetch(options);
            return handler.resolve(response);
          }
        }

        // Tenter le refresh token
        _isRefreshing = true;

        final authRepo = getIt<AuthRepository>();
        final newToken = await authRepo.refreshToken();

        // Refresh réussi - compléter toutes les requêtes en attente
        _isRefreshing = false;
        for (final completer in _pendingRequests) {
          completer.complete();
        }
        _pendingRequests.clear();

        // Re-tenter la requête originale avec le nouveau token
        final options = err.requestOptions;
        options.headers['Authorization'] = 'Bearer $newToken';
        final response = await Dio().fetch(options);
        return handler.resolve(response);
      } catch (e) {
        // Refresh token échoué : nettoyer la session puis laisser l'erreur
        // HTTP d'origine remonter jusqu'au call-site.
        _isRefreshing = false;
        for (final completer in _pendingRequests) {
          if (!completer.isCompleted) {
            completer.completeError(e);
          }
        }
        _pendingRequests.clear();

        try {
          await _tokenService.deleteToken();
          await _tokenService.deleteUserData();
        } catch (_) {
          // Ne pas masquer l'erreur réseau/origine si le nettoyage local échoue.
        }

        return super.onError(err, handler);
      }
    }

    return super.onError(err, handler);
  }
}
