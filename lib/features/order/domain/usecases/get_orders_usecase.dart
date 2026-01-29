import '../entities/order.dart';
import '../repositories/order_repository.dart';

class GetOrdersUseCase {
  final OrderRepository _repository;

  GetOrdersUseCase(this._repository);

  Future<List<Order>> call({
    int page = 1,
    int perPage = 10,
    OrderStatus? status,
  }) async {
    return await _repository.getOrders(
      page: page,
      perPage: perPage,
      status: status,
    );
  }
}
