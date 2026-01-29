import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
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
  
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';
  static const String _onboardingKey = 'has_seen_onboarding';

  AuthLocalDataSourceImpl(this._prefs);

  @override
  Future<void> saveToken(String token) async {
    await _prefs.setString(_tokenKey, token);
  }

  @override
  Future<String?> getToken() async {
    return _prefs.getString(_tokenKey);
  }

  @override
  Future<void> deleteToken() async {
    await _prefs.remove(_tokenKey);
  }

  @override
  Future<void> saveUser(UserModel user) async {
    final userJson = jsonEncode(user.toJson());
    await _prefs.setString(_userKey, userJson);
  }

  @override
  Future<UserModel?> getUser() async {
    final userJson = _prefs.getString(_userKey);
    if (userJson == null) return null;
    
    try {
      final userData = jsonDecode(userJson) as Map<String, dynamic>;
      return UserModel.fromJson(userData);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> deleteUser() async {
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
