import '../../../../core/network/api_client.dart';
import '../../domain/entities/incoming_order.dart';

class IncomingOrderRemoteDataSource {
  final ApiClient _apiClient;

  IncomingOrderRemoteDataSource(this._apiClient);

  /// Récupérer la liste des colis entrants
  Future<Map<String, dynamic>> getIncomingOrders({String? status}) async {
    final queryParams = <String, dynamic>{};
    if (status != null) queryParams['status'] = status;
    
    final response = await _apiClient.get(
      '/incoming-orders',
      queryParameters: queryParams,
    );
    
    final data = response.data['data'] as Map<String, dynamic>;
    final orders = (data['orders'] as List)
        .map((json) => IncomingOrder.fromJson(json as Map<String, dynamic>))
        .toList();
    
    final stats = IncomingOrderStats.fromJson(
      data['stats'] as Map<String, dynamic>? ?? {},
    );
    
    return {
      'orders': orders,
      'stats': stats,
      'pagination': data['pagination'],
    };
  }

  /// Récupérer les détails d'un colis entrant
  Future<IncomingOrder> getIncomingOrderDetails(String orderId) async {
    final response = await _apiClient.get('/incoming-orders/$orderId');
    final data = response.data['data'] as Map<String, dynamic>;
    return IncomingOrder.fromJson(data['order'] as Map<String, dynamic>);
  }

  /// Suivre un colis en temps réel (position du coursier)
  Future<Map<String, dynamic>> trackOrder(String orderId) async {
    final response = await _apiClient.get('/incoming-orders/$orderId/track');
    return response.data['data'] as Map<String, dynamic>;
  }

  /// Confirmer la réception d'un colis
  Future<void> confirmReceipt(String orderId, String confirmationCode) async {
    await _apiClient.post(
      '/incoming-orders/$orderId/confirm',
      data: {'confirmation_code': confirmationCode},
    );
  }

  /// Rechercher un colis par numéro (public, sans auth)
  Future<Map<String, dynamic>> searchByOrderNumber({
    required String orderNumber,
    required String phone,
  }) async {
    final response = await _apiClient.post(
      '/track-order',
      data: {
        'order_number': orderNumber,
        'phone': phone,
      },
    );
    return response.data['data'] as Map<String, dynamic>;
  }
}
