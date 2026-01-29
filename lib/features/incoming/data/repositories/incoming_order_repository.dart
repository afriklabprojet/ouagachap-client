import '../datasources/incoming_order_remote_datasource.dart';
import '../../domain/entities/incoming_order.dart';

class IncomingOrderRepository {
  final IncomingOrderRemoteDataSource _remoteDataSource;

  IncomingOrderRepository(this._remoteDataSource);

  /// Récupérer la liste des colis entrants
  Future<Map<String, dynamic>> getIncomingOrders({String? status}) {
    return _remoteDataSource.getIncomingOrders(status: status);
  }

  /// Récupérer les détails d'un colis entrant
  Future<IncomingOrder> getIncomingOrderDetails(String orderId) {
    return _remoteDataSource.getIncomingOrderDetails(orderId);
  }

  /// Suivre un colis en temps réel
  Future<Map<String, dynamic>> trackOrder(String orderId) {
    return _remoteDataSource.trackOrder(orderId);
  }

  /// Confirmer la réception d'un colis
  Future<void> confirmReceipt(String orderId, String confirmationCode) {
    return _remoteDataSource.confirmReceipt(orderId, confirmationCode);
  }

  /// Rechercher un colis par numéro (public)
  Future<Map<String, dynamic>> searchByOrderNumber({
    required String orderNumber,
    required String phone,
  }) {
    return _remoteDataSource.searchByOrderNumber(
      orderNumber: orderNumber,
      phone: phone,
    );
  }
}
