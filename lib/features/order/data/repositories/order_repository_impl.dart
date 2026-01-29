import 'dart:async';
import '../../domain/entities/order.dart';
import '../../domain/repositories/order_repository.dart';
import '../datasources/order_remote_datasource.dart';

class OrderRepositoryImpl implements OrderRepository {
  final OrderRemoteDataSource remoteDataSource;

  OrderRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Order> createOrder({
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
    return await remoteDataSource.createOrder(
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

  @override
  Future<List<Order>> getOrders({
    int page = 1,
    int perPage = 10,
    OrderStatus? status,
  }) async {
    return await remoteDataSource.getOrders(
      page: page,
      perPage: perPage,
      status: status,
    );
  }

  @override
  Future<Order> getOrderDetails(String orderId) async {
    return await remoteDataSource.getOrderDetails(orderId);
  }

  @override
  Future<void> cancelOrder(String orderId, {String? reason}) async {
    await remoteDataSource.cancelOrder(orderId, reason: reason);
  }

  @override
  Future<double> calculatePrice({
    required double pickupLatitude,
    required double pickupLongitude,
    required double deliveryLatitude,
    required double deliveryLongitude,
  }) async {
    return await remoteDataSource.calculatePrice(
      pickupLatitude: pickupLatitude,
      pickupLongitude: pickupLongitude,
      deliveryLatitude: deliveryLatitude,
      deliveryLongitude: deliveryLongitude,
    );
  }

  @override
  Future<Order> rateCourier({
    required String orderId,
    required int rating,
    String? review,
    List<String>? tags,
  }) async {
    return await remoteDataSource.rateCourier(
      orderId: orderId,
      rating: rating,
      review: review,
      tags: tags,
    );
  }

  @override
  Stream<Order> trackOrder(String orderId) {
    // Polling toutes les 5 secondes pour le suivi en temps réel
    // Peut être remplacé par WebSocket ou Firebase Realtime DB
    return Stream.periodic(const Duration(seconds: 5)).asyncMap((_) async {
      return await getOrderDetails(orderId);
    });
  }
}
