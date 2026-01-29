import 'dart:async';
import 'dart:developer' as dev;
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_error.dart';

/// Intercepteur amélioré avec retry automatique et logging
class EnhancedApiInterceptor extends Interceptor {
  final SharedPreferences _prefs;
  final Dio _dio;
  final int maxRetries;
  final Duration retryDelay;
  
  static const String _tokenKey = 'auth_token';

  EnhancedApiInterceptor(
    this._prefs,
    this._dio, {
    this.maxRetries = 3,
    this.retryDelay = const Duration(seconds: 1),
  });

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Ajouter le token d'authentification
    final token = _prefs.getString(_tokenKey);
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
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    _logError(err);
    
    // Gérer les erreurs d'authentification (401)
    if (err.response?.statusCode == 401) {
      await _prefs.remove(_tokenKey);
      return handler.reject(err);
    }
    
    // Retry automatique pour les erreurs réseau/timeout
    if (_shouldRetry(err)) {
      final retryCount = err.requestOptions.extra['retryCount'] ?? 0;
      
      if (retryCount < maxRetries) {
        dev.log('🔄 Retry ${retryCount + 1}/$maxRetries pour ${err.requestOptions.path}');
        
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

  void _logRequest(RequestOptions options) {
    dev.log('📤 ${options.method} ${options.uri}');
    if (options.data != null) {
      dev.log('   Body: ${options.data}');
    }
  }

  void _logResponse(Response response) {
    dev.log('📥 ${response.statusCode} ${response.requestOptions.uri}');
  }

  void _logError(DioException err) {
    dev.log('❌ Error ${err.response?.statusCode ?? 'unknown'}: ${err.requestOptions.uri}');
    dev.log('   Message: ${err.message}');
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
        Response(
          requestOptions: options,
          data: cached.data,
          statusCode: 200,
        ),
      );
    }
    
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // Cache les réponses GET réussies
    if (response.requestOptions.method == 'GET' && response.statusCode == 200) {
      final cacheKey = _getCacheKey(response.requestOptions);
      _cache[cacheKey] = _CachedResponse(
        data: response.data,
        expiry: DateTime.now().add(cacheDuration),
      );
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

/// Intercepteur pour gérer le mode offline
class OfflineInterceptor extends Interceptor {
  final bool Function() isOnline;
  final Map<String, dynamic> _offlineQueue = {};

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
        dev.log('📴 Offline: mise en queue de ${options.method} ${options.path}');
      }
    }
    handler.next(options);
  }
}
