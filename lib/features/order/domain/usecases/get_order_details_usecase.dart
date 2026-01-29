import '../entities/order.dart';
import '../repositories/order_repository.dart';

class GetOrderDetailsUseCase {
  final OrderRepository _repository;

  GetOrderDetailsUseCase(this._repository);

  Future<Order> call(String orderId) async {
    return await _repository.getOrderDetails(orderId);
  }
}
