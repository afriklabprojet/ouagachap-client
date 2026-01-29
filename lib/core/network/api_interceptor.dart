import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiInterceptor extends Interceptor {
  final SharedPreferences _prefs;
  static const String _tokenKey = 'auth_token';

  ApiInterceptor(this._prefs);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = _prefs.getString(_tokenKey);
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // Gérer les tokens dans les réponses si nécessaire
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Gérer les erreurs d'authentification (401)
    if (err.response?.statusCode == 401) {
      // Token expiré - on pourrait déclencher une déconnexion automatique
      _prefs.remove(_tokenKey);
    }
    super.onError(err, handler);
  }
}
