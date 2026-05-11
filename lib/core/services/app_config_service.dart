import 'package:flutter/foundation.dart';
import '../network/api_client.dart';

/// Service to fetch and cache app configuration from the backend.
class AppConfigService {
  final ApiClient _apiClient;
  Map<String, dynamic>? _cachedConfig;

  AppConfigService(this._apiClient);

  Future<Map<String, dynamic>> getConfig({bool forceRefresh = false}) async {
    if (_cachedConfig != null && !forceRefresh) return _cachedConfig!;

    try {
      final response = await _apiClient.get('config/general');
      final data = response.data;
      if (data['success'] == true) {
        _cachedConfig = data['data'] as Map<String, dynamic>;
        return _cachedConfig!;
      }
    } catch (e) {
      debugPrint('[AppConfig] Failed to fetch remote config: $e');
    }

    return _cachedConfig ?? _defaults;
  }

  List<int> get cachedRechargeAmounts {
    final amounts = _cachedConfig?['recharge_amounts'];
    if (amounts is List) {
      return amounts.map((e) => (e as num).toInt()).toList();
    }
    return _defaultRechargeAmounts;
  }

  int get minRechargeAmount =>
      (_cachedConfig?['min_recharge_amount'] as num?)?.toInt() ?? 100;

  int get maxRechargeAmount =>
      (_cachedConfig?['max_recharge_amount'] as num?)?.toInt() ?? 500000;

  String? get supportPhone => _cachedConfig?['support_phone'] as String?;

  String? get supportEmail => _cachedConfig?['support_email'] as String?;

  String? get termsUrl => _cachedConfig?['terms_url'] as String?;

  String? get privacyUrl => _cachedConfig?['privacy_url'] as String?;

  static const List<int> _defaultRechargeAmounts = [
    500,
    1000,
    2000,
    5000,
    10000,
    20000,
  ];

  static const Map<String, dynamic> _defaults = {
    'app_name': 'OUAGA CHAP',
    'currency': 'XOF',
    'currency_symbol': 'FCFA',
    'min_order_amount': 500,
    'max_order_amount': 100000,
    'min_recharge_amount': 100,
    'max_recharge_amount': 500000,
    'recharge_amounts': _defaultRechargeAmounts,
    'base_fare': 500,
    'price_per_km': 200,
    'min_fare': 500,
  };
}
