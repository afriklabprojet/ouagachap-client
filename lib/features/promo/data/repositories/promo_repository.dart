import '../../../../core/network/api_client.dart';
import '../../domain/entities/promo_code.dart';

class PromoRepository {
  final ApiClient _apiClient;

  PromoRepository(this._apiClient);

  Future<List<PromoCode>> getAvailablePromoCodes() async {
    final response = await _apiClient.get('promo-codes/available');
    final data = response.data;
    if (data['success'] == true) {
      final List<dynamic> list = data['data'] ?? [];
      return list
          .map((json) => PromoCode.fromJson(json as Map<String, dynamic>))
          .toList();
    }
    throw Exception(data['message'] ?? 'Impossible de charger les promotions');
  }

  Future<Map<String, dynamic>> validatePromoCode({
    required String code,
    required double orderAmount,
    int? zoneId,
  }) async {
    final response = await _apiClient.post('promo-codes/validate', data: {
      'code': code,
      'order_amount': orderAmount,
      if (zoneId != null) 'zone_id': zoneId,
    });
    final data = response.data;
    if (data['success'] == true) {
      return data['data'] as Map<String, dynamic>;
    }
    throw Exception(data['message'] ?? 'Code promo invalide');
  }

  Future<Map<String, dynamic>> applyPromoCode({
    required String code,
    required String orderId,
  }) async {
    final response = await _apiClient.post('promo-codes/apply', data: {
      'code': code,
      'order_id': orderId,
    });
    final data = response.data;
    if (data['success'] == true) {
      return data['data'] as Map<String, dynamic>;
    }
    throw Exception(data['message'] ?? 'Impossible d\'appliquer le code promo');
  }
}
