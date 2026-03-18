import '../repositories/order_repository.dart';

class CalculatePriceUseCase {
  final OrderRepository _repository;

  CalculatePriceUseCase(this._repository);

  Future<Map<String, double>> call({
    required double pickupLatitude,
    required double pickupLongitude,
    required double deliveryLatitude,
    required double deliveryLongitude,
  }) async {
    return await _repository.calculatePrice(
      pickupLatitude: pickupLatitude,
      pickupLongitude: pickupLongitude,
      deliveryLatitude: deliveryLatitude,
      deliveryLongitude: deliveryLongitude,
    );
  }
}
