import 'package:flutter/foundation.dart';

/// Logger sécurisé pour la production.
/// Les messages ne sont affichés qu'en mode debug (kDebugMode).
/// En release, aucun log n'est émis.
class AppLogger {
  AppLogger._();

  /// Log un message de debug (visible uniquement en mode debug)
  static void debug(String message) {
    if (kDebugMode) {
      debugPrint(message);
    }
  }

  /// Log une erreur (visible uniquement en mode debug)
  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      debugPrint('❌ $message');
      if (error != null) debugPrint('  Error: $error');
      if (stackTrace != null) debugPrint('  Stack: $stackTrace');
    }
  }

  /// Log un warning (visible uniquement en mode debug)
  static void warning(String message) {
    if (kDebugMode) {
      debugPrint('⚠️ $message');
    }
  }

  /// Log un succès (visible uniquement en mode debug)
  static void success(String message) {
    if (kDebugMode) {
      debugPrint('✅ $message');
    }
  }

  /// Log une info (visible uniquement en mode debug)
  static void info(String message) {
    if (kDebugMode) {
      debugPrint('ℹ️ $message');
    }
  }
}
