import 'package:equatable/equatable.dart';
import '../../domain/entities/order.dart';

abstract class OrderState extends Equatable {
  const OrderState();

  @override
  List<Object?> get props => [];
}

class OrderInitial extends OrderState {}

class OrderLoading extends OrderState {}

class OrderCreated extends OrderState {
  final Order order;

  const OrderCreated({required this.order});

  @override
  List<Object?> get props => [order];
}

class OrdersLoaded extends OrderState {
  final List<Order> orders;
  final bool hasMore;
  final int currentPage;

  const OrdersLoaded({
    required this.orders,
    this.hasMore = false,
    this.currentPage = 1,
  });

  @override
  List<Object?> get props => [orders, hasMore, currentPage];

  OrdersLoaded copyWith({
    List<Order>? orders,
    bool? hasMore,
    int? currentPage,
  }) {
    return OrdersLoaded(
      orders: orders ?? this.orders,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

class OrderDetailsLoaded extends OrderState {
  final Order order;

  const OrderDetailsLoaded({required this.order});

  @override
  List<Object?> get props => [order];
}

class OrderCancelled extends OrderState {
  final String orderId;

  const OrderCancelled({required this.orderId});

  @override
  List<Object?> get props => [orderId];
}

class PriceCalculated extends OrderState {
  final double price;
  final double distance;

  const PriceCalculated({
    required this.price,
    required this.distance,
  });

  @override
  List<Object?> get props => [price, distance];
}

class OrderError extends OrderState {
  final String message;

  const OrderError({required this.message});

  @override
  List<Object?> get props => [message];
}

class OrderTracking extends OrderState {
  final Order order;

  const OrderTracking({required this.order});

  @override
  List<Object?> get props => [order, order.status, order.courier?.currentLatitude];
}

class CourierRated extends OrderState {
  final Order order;

  const CourierRated({required this.order});

  @override
  List<Object?> get props => [order];
}
