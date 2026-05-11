import '../datasources/incoming_order_remote_datasource.dart';
import '../../domain/entities/incoming_order.dart';
import '../../domain/repositories/incoming_order_repository.dart';

class IncomingOrderRepository implements IncomingOrderRepositoryInterface {
  final IncomingOrderRemoteDataSource _remoteDataSource;

  IncomingOrderRepository(this._remoteDataSource);

  /// Récupérer la liste des colis entrants
  @override
  Future<Map<String, dynamic>> getIncomingOrders({String? status}) {
    return _remoteDataSource.getIncomingOrders(status: status);
  }

  /// Récupérer les détails d'un colis entrant
  @override
  Future<IncomingOrder> getIncomingOrderDetails(String orderId) {
    return _remoteDataSource.getIncomingOrderDetails(orderId);
  }

  /// Suivre un colis en temps réel
  @override
  Future<Map<String, dynamic>> trackOrder(String orderId) {
    return _remoteDataSource.trackOrder(orderId);
  }

  /// Confirmer la réception d'un colis
  @override
  Future<void> confirmReceipt(String orderId, String confirmationCode) {
    return _remoteDataSource.confirmReceipt(orderId, confirmationCode);
  }

  /// Rechercher un colis par numéro (public)
  @override
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
