import '../entities/promo_code.dart';

abstract class PromoRepositoryInterface {
  Future<List<PromoCode>> getAvailablePromoCodes();
  Future<Map<String, dynamic>> validatePromoCode({
    required String code,
    required double orderAmount,
    int? zoneId,
  });
  Future<Map<String, dynamic>> applyPromoCode({
    required String code,
    required String orderId,
  });
}
