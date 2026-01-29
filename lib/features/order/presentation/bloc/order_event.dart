import 'package:equatable/equatable.dart';
import '../../domain/entities/order.dart';

abstract class OrderEvent extends Equatable {
  const OrderEvent();

  @override
  List<Object?> get props => [];
}

class CreateOrderRequested extends OrderEvent {
  final String pickupAddress;
  final double pickupLatitude;
  final double pickupLongitude;
  final String? pickupContactName;
  final String? pickupContactPhone;
  final String deliveryAddress;
  final double deliveryLatitude;
  final double deliveryLongitude;
  final String recipientName;
  final String recipientPhone;
  final String? packageDescription;
  final String? packageSize;

  const CreateOrderRequested({
    required this.pickupAddress,
    required this.pickupLatitude,
    required this.pickupLongitude,
    this.pickupContactName,
    this.pickupContactPhone,
    required this.deliveryAddress,
    required this.deliveryLatitude,
    required this.deliveryLongitude,
    required this.recipientName,
    required this.recipientPhone,
    this.packageDescription,
    this.packageSize,
  });

  @override
  List<Object?> get props => [
        pickupAddress,
        deliveryAddress,
        recipientName,
        recipientPhone,
      ];
}

class GetOrdersRequested extends OrderEvent {
  final int page;
  final int perPage;
  final OrderStatus? status;
  final bool refresh;

  const GetOrdersRequested({
    this.page = 1,
    this.perPage = 10,
    this.status,
    this.refresh = false,
  });

  @override
  List<Object?> get props => [page, perPage, status, refresh];
}

class GetOrderDetailsRequested extends OrderEvent {
  final String orderId;

  const GetOrderDetailsRequested({required this.orderId});

  @override
  List<Object?> get props => [orderId];
}

class CancelOrderRequested extends OrderEvent {
  final String orderId;
  final String? reason;

  const CancelOrderRequested({
    required this.orderId,
    this.reason,
  });

  @override
  List<Object?> get props => [orderId, reason];
}

class CalculatePriceRequested extends OrderEvent {
  final double pickupLatitude;
  final double pickupLongitude;
  final double deliveryLatitude;
  final double deliveryLongitude;

  const CalculatePriceRequested({
    required this.pickupLatitude,
    required this.pickupLongitude,
    required this.deliveryLatitude,
    required this.deliveryLongitude,
  });

  @override
  List<Object?> get props => [
        pickupLatitude,
        pickupLongitude,
        deliveryLatitude,
        deliveryLongitude,
      ];
}

class StartOrderTrackingRequested extends OrderEvent {
  final String orderId;

  const StartOrderTrackingRequested({required this.orderId});

  @override
  List<Object?> get props => [orderId];
}

class StopOrderTrackingRequested extends OrderEvent {}

class RateCourierRequested extends OrderEvent {
  final String orderId;
  final int rating;
  final String? review;
  final List<String> tags;

  const RateCourierRequested({
    required this.orderId,
    required this.rating,
    this.review,
    this.tags = const [],
  });

  @override
  List<Object?> get props => [orderId, rating, review, tags];
}
