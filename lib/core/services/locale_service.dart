import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/app_localizations.dart';

/// Service de gestion de la langue de l'application
class LocaleService extends ChangeNotifier {
  static const String _localeKey = 'app_locale';
  
  Locale _currentLocale = const Locale('fr', 'FR');
  
  Locale get currentLocale => _currentLocale;
  
  LocaleService() {
    _loadLocale();
  }
  
  /// Charge la langue sauvegardée depuis les préférences
  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString(_localeKey);
    
    if (languageCode != null) {
      _currentLocale = Locale(languageCode);
      notifyListeners();
    }
  }
  
  /// Change la langue de l'application
  Future<void> setLocale(Locale locale) async {
    if (!AppLocalizations.supportedLocales.any((l) => l.languageCode == locale.languageCode)) {
      return;
    }
    
    _currentLocale = locale;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, locale.languageCode);
    
    notifyListeners();
  }
  
  /// Change vers le français
  Future<void> setFrench() async {
    await setLocale(const Locale('fr', 'FR'));
  }
  
  /// Change vers l'anglais
  Future<void> setEnglish() async {
    await setLocale(const Locale('en', 'US'));
  }
  
  /// Vérifie si la langue actuelle est le français
  bool get isFrench => _currentLocale.languageCode == 'fr';
  
  /// Vérifie si la langue actuelle est l'anglais
  bool get isEnglish => _currentLocale.languageCode == 'en';
  
  /// Retourne le nom de la langue actuelle
  String get currentLanguageName => isFrench ? 'Français' : 'English';
  
  /// Retourne le drapeau emoji de la langue actuelle
  String get currentLanguageFlag => isFrench ? '🇧🇫' : '🇺🇸';
}
