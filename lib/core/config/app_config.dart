/// Configuration par environnement pour OUAGA CHAP Client.
///
/// Usage:
///   flutter run -t lib/main_dev.dart
///   flutter run -t lib/main_staging.dart
///   flutter run -t lib/main_prod.dart
enum Environment { dev, staging, prod }

class AppConfig {
  static bool _initialized = false;

  /// Vrai dès qu'[init] a été appelé. Permet de détecter un lancement
  /// via `flutter run` sans `-t lib/main_prod.dart`.
  static bool get initialized => _initialized;

  static late Environment environment;
  static late String baseUrl;
  static late String wsBaseUrl;
  static late String wsAppKey;

  /// Pusher cluster (eu, us2, ap1…). Null = Reverb (self-hosted).
  static String? pusherCluster;

  static void init(Environment env) {
    _initialized = true;
    environment = env;
    switch (env) {
      case Environment.dev:
        baseUrl = 'http://127.0.0.1:8000/api/v1';
        wsBaseUrl = 'http://127.0.0.1:8080';
        wsAppKey = const String.fromEnvironment(
          'PUSHER_KEY',
          defaultValue: 'dev-key',
        );
        pusherCluster = null; // Reverb en dev
      case Environment.staging:
        baseUrl = 'https://staging.ouagachap.pro/api/v1';
        wsBaseUrl = 'https://ws-eu.pusher.com';
        wsAppKey = const String.fromEnvironment('PUSHER_KEY');
        pusherCluster = 'eu';
      case Environment.prod:
        baseUrl = 'https://ouagachap.pro/api/v1';
        wsBaseUrl = 'https://ws-eu.pusher.com';
        wsAppKey = const String.fromEnvironment('PUSHER_KEY');
        pusherCluster = 'eu';
    }
  }

  static bool get isDev => environment == Environment.dev;
  static bool get isStaging => environment == Environment.staging;
  static bool get isProd => environment == Environment.prod;

  /// DSN Sentry — vide en dev (pas de reporting), rempli via
  /// `--dart-define=SENTRY_DSN=https://xxx@sentry.io/yyy` au build.
  static const String sentryDsn = String.fromEnvironment(
    'SENTRY_DSN',
    defaultValue: '',
  );
}
