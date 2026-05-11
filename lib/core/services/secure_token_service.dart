import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Service centralisé pour le stockage sécurisé du token d'authentification.
///
/// Utilise flutter_secure_storage (Keychain sur iOS, EncryptedSharedPreferences
/// sur Android) au lieu de SharedPreferences en clair.
class SecureTokenService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );
  static const _tokenKey = 'auth_token';
  static const _userDataKey = 'user_data';

  /// Cache en mémoire pour les lectures synchrones (interceptors Dio).
  String? _cachedToken;

  /// Cache en mémoire pour les données utilisateur.
  String? _cachedUserData;

  /// Charge le token depuis le stockage sécurisé vers le cache mémoire.
  /// Doit être appelé au démarrage de l'app (injection.dart).
  Future<void> init() async {
    _cachedToken = await _storage.read(key: _tokenKey);
    _cachedUserData = await _storage.read(key: _userDataKey);
  }

  /// Lecture synchrone depuis le cache mémoire (pour Dio interceptors).
  String? get token => _cachedToken;

  /// Sauvegarde le token de façon sécurisée et met à jour le cache.
  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
    _cachedToken = token;
  }

  /// Supprime le token du stockage sécurisé et du cache.
  Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
    _cachedToken = null;
  }

  // === Données utilisateur (PII) ===

  /// Lecture synchrone des données utilisateur depuis le cache mémoire.
  String? get userData => _cachedUserData;

  /// Sauvegarde les données utilisateur de façon sécurisée.
  Future<void> saveUserData(String jsonData) async {
    await _storage.write(key: _userDataKey, value: jsonData);
    _cachedUserData = jsonData;
  }

  /// Supprime les données utilisateur.
  Future<void> deleteUserData() async {
    await _storage.delete(key: _userDataKey);
    _cachedUserData = null;
  }
}
