/// Configuration par environnement pour OUAGA CHAP Client.
///
/// Usage:
///   flutter run -t lib/main_dev.dart
///   flutter run -t lib/main_staging.dart
///   flutter run -t lib/main_prod.dart
enum Environment { dev, staging, prod }

class AppConfig {
  static late Environment environment;
  static late String baseUrl;
  static late String wsBaseUrl;
  static late String wsAppKey;

  /// Pusher cluster (eu, us2, ap1…). Null = Reverb (self-hosted).
  static String? pusherCluster;

  static void init(Environment env) {
    environment = env;
    switch (env) {
      case Environment.dev:
        baseUrl = 'http://127.0.0.1:8000/api/v1';
        wsBaseUrl = 'http://127.0.0.1:8080';
        wsAppKey = 'e7b5f178d516c3fa13e17256148b6ac4';
        pusherCluster = null; // Reverb en dev
      case Environment.staging:
        baseUrl = 'https://staging.ouagachap.com/api/v1';
        wsBaseUrl = 'https://ws-eu.pusher.com';
        wsAppKey = const String.fromEnvironment('PUSHER_KEY', defaultValue: 'dd76a202f692b343f0f8');
        pusherCluster = 'eu';
      case Environment.prod:
        baseUrl = 'https://ouagachap.com/api/v1';
        wsBaseUrl = 'https://ws-eu.pusher.com';
        wsAppKey = const String.fromEnvironment('PUSHER_KEY', defaultValue: 'dd76a202f692b343f0f8');
        pusherCluster = 'eu';
    }
  }

  static bool get isDev => environment == Environment.dev;
  static bool get isStaging => environment == Environment.staging;
  static bool get isProd => environment == Environment.prod;
}
