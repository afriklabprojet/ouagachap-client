import '../../../../core/network/api_client.dart';
import '../../domain/entities/order.dart';
import '../models/order_model.dart';

abstract class OrderRemoteDataSource {
  Future<OrderModel> createOrder({
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
    String paymentMethod = 'cash',
  });

  Future<List<OrderModel>> getOrders({
    int page = 1,
    int perPage = 10,
    OrderStatus? status,
  });

  Future<OrderModel> getOrderDetails(String orderId);

  Future<void> cancelOrder(String orderId, {String? reason});

  Future<Map<String, double>> calculatePrice({
    required double pickupLatitude,
    required double pickupLongitude,
    required double deliveryLatitude,
    required double deliveryLongitude,
  });

  Future<OrderModel> rateCourier({
    required String orderId,
    required int rating,
    String? review,
    List<String>? tags,
  });
}

class OrderRemoteDataSourceImpl implements OrderRemoteDataSource {
  final ApiClient _apiClient;

  OrderRemoteDataSourceImpl(this._apiClient);

  @override
  Future<OrderModel> createOrder({
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
    String paymentMethod = 'cash',
  }) async {
    final response = await _apiClient.post(
      'orders',
      data: {
        'pickup_address': pickupAddress,
        'pickup_latitude': pickupLatitude,
        'pickup_longitude': pickupLongitude,
        'pickup_contact_name': pickupContactName ?? '',
        'pickup_contact_phone': pickupContactPhone ?? '',
        'dropoff_address': deliveryAddress,
        'dropoff_latitude': deliveryLatitude,
        'dropoff_longitude': deliveryLongitude,
        'dropoff_contact_name': recipientName,
        'dropoff_contact_phone': recipientPhone,
        if (packageDescription != null) 'package_description': packageDescription,
        if (packageSize != null) 'package_size': packageSize,
        'payment_method': paymentMethod,
      },
    );

    final data = response.data['data'] ?? response.data;
    return OrderModel.fromJson(data as Map<String, dynamic>);
  }

  @override
  Future<List<OrderModel>> getOrders({
    int page = 1,
    int perPage = 10,
    OrderStatus? status,
  }) async {
    final response = await _apiClient.get(
      'orders',
      queryParameters: {
        'page': page,
        'per_page': perPage,
        if (status != null) 'status': status.name,
      },
    );

    final data = response.data['data'] as List<dynamic>?;
    if (data == null) return [];
    
    return data
        .map((json) => OrderModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<OrderModel> getOrderDetails(String orderId) async {
    final response = await _apiClient.get('/orders/$orderId');
    final data = response.data['data'] ?? response.data;
    return OrderModel.fromJson(data as Map<String, dynamic>);
  }

  @override
  Future<void> cancelOrder(String orderId, {String? reason}) async {
    await _apiClient.post(
      '/orders/$orderId/cancel',
      data: {
        if (reason != null) 'reason': reason,
      },
    );
  }

  @override
  Future<Map<String, double>> calculatePrice({
    required double pickupLatitude,
    required double pickupLongitude,
    required double deliveryLatitude,
    required double deliveryLongitude,
  }) async {
    final response = await _apiClient.post(
      '/orders/estimate',
      data: {
        'pickup_latitude': pickupLatitude,
        'pickup_longitude': pickupLongitude,
        'dropoff_latitude': deliveryLatitude,
        'dropoff_longitude': deliveryLongitude,
      },
    );

    final data = response.data['data'] ?? response.data;
    return {
      'total_price': ((data['total_price'] ?? 0) as num).toDouble(),
      'distance_km': ((data['distance_km'] ?? 0) as num).toDouble(),
      'base_price': ((data['base_price'] ?? 0) as num).toDouble(),
      'distance_price': ((data['distance_price'] ?? 0) as num).toDouble(),
      'commission_amount': ((data['commission_amount'] ?? 0) as num).toDouble(),
      'courier_earnings': ((data['courier_earnings'] ?? 0) as num).toDouble(),
    };
  }

  @override
  Future<OrderModel> rateCourier({
    required String orderId,
    required int rating,
    String? review,
    List<String>? tags,
  }) async {
    final response = await _apiClient.post(
      'orders/$orderId/rate-courier',
      data: {
        'rating': rating,
        if (review != null && review.isNotEmpty) 'review': review,
        if (tags != null && tags.isNotEmpty) 'tags': tags,
      },
    );

    final data = response.data['data'] ?? response.data;
    return OrderModel.fromJson(data as Map<String, dynamic>);
  }
}
