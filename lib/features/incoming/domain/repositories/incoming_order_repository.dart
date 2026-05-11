import '../entities/incoming_order.dart';

abstract class IncomingOrderRepositoryInterface {
  Future<Map<String, dynamic>> getIncomingOrders({String? status});
  Future<IncomingOrder> getIncomingOrderDetails(String orderId);
  Future<Map<String, dynamic>> trackOrder(String orderId);
  Future<void> confirmReceipt(String orderId, String confirmationCode);
  Future<Map<String, dynamic>> searchByOrderNumber({
    required String orderNumber,
    required String phone,
  });
}
