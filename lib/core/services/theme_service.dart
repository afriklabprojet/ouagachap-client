import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service de gestion du thème (clair/sombre)
class ThemeService extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  
  final SharedPreferences _prefs;
  ThemeMode _themeMode = ThemeMode.system;
  
  ThemeService(this._prefs) {
    _loadTheme();
  }
  
  ThemeMode get themeMode => _themeMode;
  
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  
  bool get isLightMode => _themeMode == ThemeMode.light;
  
  bool get isSystemMode => _themeMode == ThemeMode.system;
  
  /// Charger le thème depuis les préférences
  void _loadTheme() {
    final savedTheme = _prefs.getString(_themeKey);
    
    if (savedTheme != null) {
      _themeMode = ThemeMode.values.firstWhere(
        (mode) => mode.name == savedTheme,
        orElse: () => ThemeMode.system,
      );
    }
    notifyListeners();
  }
  
  /// Changer le thème
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    
    _themeMode = mode;
    notifyListeners();
    
    await _prefs.setString(_themeKey, mode.name);
  }
  
  /// Basculer entre clair et sombre
  Future<void> toggleTheme() async {
    final newMode = _themeMode == ThemeMode.dark 
        ? ThemeMode.light 
        : ThemeMode.dark;
    await setThemeMode(newMode);
  }
  
  /// Définir le mode système
  Future<void> useSystemTheme() async {
    await setThemeMode(ThemeMode.system);
  }
}
