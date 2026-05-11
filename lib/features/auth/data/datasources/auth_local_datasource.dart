import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/services/secure_token_service.dart';
import '../models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<void> saveToken(String token);
  Future<String?> getToken();
  Future<void> deleteToken();
  Future<void> saveUser(UserModel user);
  Future<UserModel?> getUser();
  Future<void> deleteUser();
  Future<void> clearAll();
  Future<bool> hasSeenOnboarding();
  Future<void> setHasSeenOnboarding(bool value);
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences _prefs;
  final SecureTokenService _tokenService;

  static const String _userKey = 'user_data';
  static const String _onboardingKey = 'has_seen_onboarding';

  AuthLocalDataSourceImpl(this._prefs, this._tokenService);

  @override
  Future<void> saveToken(String token) async {
    await _tokenService.saveToken(token);
  }

  @override
  Future<String?> getToken() async {
    return _tokenService.token;
  }

  @override
  Future<void> deleteToken() async {
    await _tokenService.deleteToken();
  }

  @override
  Future<void> saveUser(UserModel user) async {
    final userJson = jsonEncode(user.toJson());
    await _tokenService.saveUserData(userJson);
  }

  @override
  Future<UserModel?> getUser() async {
    final userJson = _tokenService.userData;
    // Fallback: migrer depuis SharedPreferences si présent
    if (userJson == null) {
      final legacyJson = _prefs.getString(_userKey);
      if (legacyJson != null) {
        try {
          final user = UserModel.fromJson(jsonDecode(legacyJson));
          await _tokenService.saveUserData(legacyJson);
          await _prefs.remove(_userKey);
          return user;
        } on FormatException {
          await _prefs.remove(_userKey);
          return null;
        }
      }
      return null;
    }
    try {
      return UserModel.fromJson(jsonDecode(userJson));
    } on FormatException {
      return null;
    }
  }

  @override
  Future<void> deleteUser() async {
    await _tokenService.deleteUserData();
    // Nettoyer aussi l'ancien stockage si présent
    await _prefs.remove(_userKey);
  }

  @override
  Future<void> clearAll() async {
    await deleteToken();
    await deleteUser();
  }

  @override
  Future<bool> hasSeenOnboarding() async {
    return _prefs.getBool(_onboardingKey) ?? false;
  }

  @override
  Future<void> setHasSeenOnboarding(bool value) async {
    await _prefs.setBool(_onboardingKey, value);
  }
}
