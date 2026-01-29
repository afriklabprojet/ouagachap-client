import '../entities/order.dart';
import '../repositories/order_repository.dart';

class CreateOrderUseCase {
  final OrderRepository _repository;

  CreateOrderUseCase(this._repository);

  Future<Order> call({
    required String pickupAddress,
    required double pickupLatitude,
    required double pickupLongitude,
    String? pickupContactName,
    String? pickupContactPhone,
    required String deliveryAddress,
    required double deliveryLatitude,
    required double deliveryLongitude,
    required String recipientName,
    required String recipientPhone,
    String? packageDescription,
    String? packageSize,
  }) async {
    return await _repository.createOrder(
      pickupAddress: pickupAddress,
      pickupLatitude: pickupLatitude,
      pickupLongitude: pickupLongitude,
      pickupContactName: pickupContactName,
      pickupContactPhone: pickupContactPhone,
      deliveryAddress: deliveryAddress,
      deliveryLatitude: deliveryLatitude,
      deliveryLongitude: deliveryLongitude,
      recipientName: recipientName,
      recipientPhone: recipientPhone,
      packageDescription: packageDescription,
      packageSize: packageSize,
    );
  }
}
