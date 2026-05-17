import 'dart:async';
import 'dart:developer' as dev;
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import '../router/app_router.dart';
import '../services/secure_token_service.dart';

/// Intercepteur amélioré avec retry automatique, token refresh et logging
class EnhancedApiInterceptor extends Interceptor {
  final SecureTokenService _tokenService;
  final Dio _dio;
  final int maxRetries;
  final Duration retryDelay;
  bool _isRefreshing = false;
  final List<_QueuedRequest> _pendingRequests = [];

  EnhancedApiInterceptor(
    this._tokenService,
    this._dio, {
    this.maxRetries = 3,
    this.retryDelay = const Duration(seconds: 1),
  });

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Ajouter le token d'authentification
    final token = _tokenService.token;
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    // Ajouter les headers par défaut
    options.headers['Accept'] = 'application/json';
    options.headers['Content-Type'] = 'application/json';

    // Logging en mode debug
    _logRequest(options);

    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _logResponse(response);
    super.onResponse(response, handler);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    _logError(err);

    // Gérer les erreurs d'authentification (401) avec token refresh
    if (err.response?.statusCode == 401) {
      // Ne pas refresh pour les routes d'auth elles-mêmes
      final path = err.requestOptions.path;
      if (path.contains('auth/otp') ||
          path.contains('auth/register') ||
          path.contains('auth/refresh-token') ||
          path.contains('auth/logout')) {
        await _tokenService.deleteToken();
        _redirectToLogin();
        return handler.reject(err);
      }

      // Tenter un refresh si on n'est pas déjà en train d'en faire un
      if (!_isRefreshing) {
        _isRefreshing = true;
        try {
          final refreshed = await _refreshToken();
          _isRefreshing = false;

          if (refreshed) {
            // Rejouer la requête originale avec le nouveau token
            final opts = err.requestOptions;
            opts.headers['Authorization'] = 'Bearer ${_tokenService.token}';
            final response = await _dio.fetch(opts);

            // Rejouer les requêtes en file d'attente
            _resolvePendingRequests();

            return handler.resolve(response);
          } else {
            _rejectPendingRequests(err);
            _redirectToLogin();
            return handler.reject(err);
          }
        } catch (e) {
          _isRefreshing = false;
          _rejectPendingRequests(err);
          _redirectToLogin();
          return handler.reject(err);
        }
      } else {
        // Un refresh est déjà en cours, mettre en file d'attente
        final completer = Completer<Response>();
        _pendingRequests.add(_QueuedRequest(err.requestOptions, completer));
        try {
          final response = await completer.future;
          return handler.resolve(response);
        } catch (e) {
          return handler.reject(err);
        }
      }
    }

    // Ne pas retry les mutations (POST/PUT/PATCH/DELETE) — risque de double traitement
    // (double paiement, double création de commande, etc.)
    final method = err.requestOptions.method.toUpperCase();
    final isSafeMethod = method == 'GET' || method == 'HEAD';

    // Retry automatique pour les erreurs réseau/timeout (GET/HEAD uniquement)
    if (isSafeMethod && _shouldRetry(err)) {
      final retryCount = err.requestOptions.extra['retryCount'] ?? 0;

      if (retryCount < maxRetries) {
        dev.log(
          '🔄 Retry ${retryCount + 1}/$maxRetries pour ${err.requestOptions.path}',
        );

        // Attendre avant de réessayer (backoff exponentiel)
        await Future.delayed(retryDelay * (retryCount + 1));

        // Réessayer la requête
        try {
          final options = err.requestOptions;
          options.extra['retryCount'] = retryCount + 1;

          final response = await _dio.fetch(options);
          return handler.resolve(response);
        } catch (e) {
          // Si le retry échoue aussi, continuer avec l'erreur originale
        }
      }
    }

    super.onError(err, handler);
  }

  bool _shouldRetry(DioException err) {
    return err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.connectionError ||
        (err.response?.statusCode != null &&
            err.response!.statusCode! >= 500 &&
            err.response!.statusCode! < 600);
  }

  /// Accède au GoRouter global pour une redirection 401 → login
  GoRouter? _findRouter() {
    try {
      return AppRouter.router;
    } catch (e) {
      debugPrint('[Router] AppRouter.router not available: $e');
      return null;
    }
  }

  void _redirectToLogin() {
    _tokenService.deleteToken();
    try {
      final router = _findRouter();
      router?.go('/login');
    } catch (e) {
      debugPrint('[Interceptor] Router redirect error: $e');
    }
  }

  /// Tente de rafraîchir le token via /auth/refresh-token
  Future<bool> _refreshToken() async {
    try {
      final currentToken = _tokenService.token;
      if (currentToken == null || currentToken.isEmpty) return false;

      final response = await Dio(
        BaseOptions(
          baseUrl: _dio.options.baseUrl,
          headers: {
            'Authorization': 'Bearer $currentToken',
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
        ),
      ).post('auth/refresh-token');

      if (response.statusCode == 200) {
        final data = response.data;
        final newToken = data['data']?['token'] ?? data['token'];
        if (newToken != null && newToken is String && newToken.isNotEmpty) {
          await _tokenService.saveToken(newToken);
          dev.log('🔄 Token refreshed successfully');
          return true;
        }
      }
      return false;
    } catch (e) {
      dev.log('❌ Token refresh failed: $e');
      return false;
    }
  }

  void _resolvePendingRequests() {
    for (final queued in _pendingRequests) {
      queued.options.headers['Authorization'] = 'Bearer ${_tokenService.token}';
      _dio
          .fetch(queued.options)
          .then(
            (response) => queued.completer.complete(response),
            onError: (e) => queued.completer.completeError(e),
          );
    }
    _pendingRequests.clear();
  }

  void _rejectPendingRequests(DioException err) {
    for (final queued in _pendingRequests) {
      queued.completer.completeError(err);
    }
    _pendingRequests.clear();
  }

  void _logRequest(RequestOptions options) {
    dev.log('📤 ${options.method} ${options.uri}');
    if (kDebugMode && options.data != null) {
      dev.log('   Body: ${options.data}');
    }
  }

  void _logResponse(Response response) {
    dev.log('📥 ${response.statusCode} ${response.requestOptions.uri}');
  }

  void _logError(DioException err) {
    dev.log(
      '❌ Error ${err.response?.statusCode ?? 'unknown'}: ${err.requestOptions.uri}',
    );
    if (kDebugMode) {
      dev.log('   Message: ${err.message}');
    }
  }
}

/// Intercepteur de cache pour les requêtes GET
class CacheInterceptor extends Interceptor {
  final Map<String, _CachedResponse> _cache = {};
  final Duration cacheDuration;

  CacheInterceptor({this.cacheDuration = const Duration(minutes: 5)});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Ne cache que les requêtes GET
    if (options.method != 'GET') {
      return handler.next(options);
    }

    // Vérifier si on a un cache valide
    final cacheKey = _getCacheKey(options);
    final cached = _cache[cacheKey];

    if (cached != null && !cached.isExpired) {
      dev.log('📦 Cache hit: ${options.uri}');
      return handler.resolve(
        Response(requestOptions: options, data: cached.data, statusCode: 200),
      );
    }

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final method = response.requestOptions.method.toUpperCase();

    if (method == 'GET' && response.statusCode == 200) {
      // Cache les réponses GET réussies
      final cacheKey = _getCacheKey(response.requestOptions);
      _cache[cacheKey] = _CachedResponse(
        data: response.data,
        expiry: DateTime.now().add(cacheDuration),
      );
    } else if ((method == 'POST' ||
            method == 'PUT' ||
            method == 'PATCH' ||
            method == 'DELETE') &&
        response.statusCode != null &&
        response.statusCode! < 400) {
      // Invalide le cache pour la ressource de base afin d'éviter les données périmées
      final path = response.requestOptions.path;
      // Extrait le chemin de base (ex: /orders/123/cancel → /orders)
      final segments = path.split('/').where((s) => s.isNotEmpty).toList();
      if (segments.isNotEmpty) {
        invalidate('/${segments.first}');
      }
    }

    handler.next(response);
  }

  String _getCacheKey(RequestOptions options) {
    return '${options.method}:${options.uri}';
  }

  /// Vide le cache
  void clearCache() {
    _cache.clear();
  }

  /// Vide le cache pour une URL spécifique
  void invalidate(String url) {
    _cache.removeWhere((key, _) => key.contains(url));
  }
}

class _CachedResponse {
  final dynamic data;
  final DateTime expiry;

  _CachedResponse({required this.data, required this.expiry});

  bool get isExpired => DateTime.now().isAfter(expiry);
}

class _QueuedRequest {
  final RequestOptions options;
  final Completer<Response> completer;

  _QueuedRequest(this.options, this.completer);
}

/// Intercepteur pour gérer le mode offline
class OfflineInterceptor extends Interceptor {
  final bool Function() isOnline;

  OfflineInterceptor({required this.isOnline});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (!isOnline()) {
      // En mode offline, on peut rejeter ou mettre en queue
      if (options.method == 'GET') {
        // Pour les GET, on rejette avec une erreur claire
        return handler.reject(
          DioException(
            requestOptions: options,
            error: 'Pas de connexion internet',
            type: DioExceptionType.connectionError,
          ),
        );
      } else {
        // Pour les POST/PUT/DELETE, on pourrait mettre en queue
        // (implémentation simplifiée)
        dev.log(
          '📴 Offline: mise en queue de ${options.method} ${options.path}',
        );
      }
    }
    handler.next(options);
  }
}
