import '../repositories/order_repository.dart';

class CancelOrderUseCase {
  final OrderRepository _repository;

  CancelOrderUseCase(this._repository);

  Future<void> call(String orderId, {String? reason}) async {
    return await _repository.cancelOrder(orderId, reason: reason);
  }
}
