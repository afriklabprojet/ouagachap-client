import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Service de cache local pour le mode offline
class CacheService {
  static const Duration _defaultCacheDuration = Duration(hours: 1);
  
  final SharedPreferences _prefs;
  
  CacheService(this._prefs);
  
  /// Sauvegarder des données avec une clé et une durée d'expiration
  Future<void> cache<T>({
    required String key,
    required T data,
    Duration? duration,
  }) async {
    final cacheData = _CacheEntry(
      data: data,
      timestamp: DateTime.now(),
      expiresAt: DateTime.now().add(duration ?? _defaultCacheDuration),
    );
    
    await _prefs.setString(key, jsonEncode(cacheData.toJson()));
  }
  
  /// Récupérer des données du cache
  T? get<T>({
    required String key,
    T Function(Map<String, dynamic>)? fromJson,
  }) {
    final cached = _prefs.getString(key);
    if (cached == null) return null;
    
    try {
      final entry = _CacheEntry.fromJson(jsonDecode(cached));
      
      // Vérifier si le cache a expiré
      if (entry.isExpired) {
        remove(key);
        return null;
      }
      
      if (fromJson != null && entry.data is Map<String, dynamic>) {
        return fromJson(entry.data as Map<String, dynamic>);
      }
      
      return entry.data as T?;
    } catch (e) {
      remove(key);
      return null;
    }
  }
  
  /// Récupérer une liste du cache
  List<T>? getList<T>({
    required String key,
    T Function(Map<String, dynamic>)? fromJson,
  }) {
    final cached = _prefs.getString(key);
    if (cached == null) return null;
    
    try {
      final entry = _CacheEntry.fromJson(jsonDecode(cached));
      
      if (entry.isExpired) {
        remove(key);
        return null;
      }
      
      if (entry.data is List) {
        final list = entry.data as List;
        if (fromJson != null) {
          return list
              .whereType<Map<String, dynamic>>()
              .map((item) => fromJson(item))
              .toList();
        }
        return list.cast<T>();
      }
      
      return null;
    } catch (e) {
      remove(key);
      return null;
    }
  }
  
  /// Vérifier si une clé existe et n'a pas expiré
  bool has(String key) {
    final cached = _prefs.getString(key);
    if (cached == null) return false;
    
    try {
      final entry = _CacheEntry.fromJson(jsonDecode(cached));
      return !entry.isExpired;
    } catch (e) {
      return false;
    }
  }
  
  /// Supprimer une entrée du cache
  Future<void> remove(String key) async {
    await _prefs.remove(key);
  }
  
  /// Vider tout le cache
  Future<void> clear() async {
    final keys = _prefs.getKeys().where((key) => key.startsWith('cache_'));
    for (final key in keys) {
      await _prefs.remove(key);
    }
  }
  
  /// Nettoyer les entrées expirées
  Future<void> cleanExpired() async {
    final keys = _prefs.getKeys().toList();
    
    for (final key in keys) {
      final cached = _prefs.getString(key);
      if (cached == null) continue;
      
      try {
        final entry = _CacheEntry.fromJson(jsonDecode(cached));
        if (entry.isExpired) {
          await _prefs.remove(key);
        }
      } catch (e) {
        // Ignorer les entrées non-cache
      }
    }
  }
}

/// Clés de cache prédéfinies
class CacheKeys {
  CacheKeys._();
  
  static const String orders = 'cache_orders';
  static const String activeOrders = 'cache_active_orders';
  static const String notifications = 'cache_notifications';
  static const String wallet = 'cache_wallet';
  static const String profile = 'cache_profile';
  static const String zones = 'cache_zones';
  static const String faqs = 'cache_faqs';
  static const String promos = 'cache_promos';
}

/// Entrée de cache interne
class _CacheEntry {
  final dynamic data;
  final DateTime timestamp;
  final DateTime expiresAt;
  
  _CacheEntry({
    required this.data,
    required this.timestamp,
    required this.expiresAt,
  });
  
  bool get isExpired => DateTime.now().isAfter(expiresAt);
  
  Map<String, dynamic> toJson() => {
    'data': data,
    'timestamp': timestamp.toIso8601String(),
    'expiresAt': expiresAt.toIso8601String(),
  };
  
  factory _CacheEntry.fromJson(Map<String, dynamic> json) => _CacheEntry(
    data: json['data'],
    timestamp: DateTime.parse(json['timestamp']),
    expiresAt: DateTime.parse(json['expiresAt']),
  );
}
