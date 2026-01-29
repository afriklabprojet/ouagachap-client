import 'dart:async';
import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/create_order_usecase.dart';
import '../../domain/usecases/get_orders_usecase.dart';
import '../../domain/usecases/get_order_details_usecase.dart';
import '../../domain/usecases/cancel_order_usecase.dart';
import '../../domain/usecases/rate_courier.dart';
import 'order_event.dart';
import 'order_state.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final CreateOrderUseCase createOrderUseCase;
  final GetOrdersUseCase getOrdersUseCase;
  final GetOrderDetailsUseCase getOrderDetailsUseCase;
  final CancelOrderUseCase cancelOrderUseCase;
  final RateCourierUseCase rateCourierUseCase;

  StreamSubscription? _trackingSubscription;

  OrderBloc({
    required this.createOrderUseCase,
    required this.getOrdersUseCase,
    required this.getOrderDetailsUseCase,
    required this.cancelOrderUseCase,
    required this.rateCourierUseCase,
  }) : super(OrderInitial()) {
    on<CreateOrderRequested>(_onCreateOrderRequested);
    on<GetOrdersRequested>(_onGetOrdersRequested);
    on<GetOrderDetailsRequested>(_onGetOrderDetailsRequested);
    on<CancelOrderRequested>(_onCancelOrderRequested);
    on<CalculatePriceRequested>(_onCalculatePriceRequested);
    on<StartOrderTrackingRequested>(_onStartOrderTrackingRequested);
    on<StopOrderTrackingRequested>(_onStopOrderTrackingRequested);
    on<RateCourierRequested>(_onRateCourierRequested);
  }

  Future<void> _onCreateOrderRequested(
    CreateOrderRequested event,
    Emitter<OrderState> emit,
  ) async {
    emit(OrderLoading());

    try {
      final order = await createOrderUseCase(
        pickupAddress: event.pickupAddress,
        pickupLatitude: event.pickupLatitude,
        pickupLongitude: event.pickupLongitude,
        pickupContactName: event.pickupContactName,
        pickupContactPhone: event.pickupContactPhone,
        deliveryAddress: event.deliveryAddress,
        deliveryLatitude: event.deliveryLatitude,
        deliveryLongitude: event.deliveryLongitude,
        recipientName: event.recipientName,
        recipientPhone: event.recipientPhone,
        packageDescription: event.packageDescription,
        packageSize: event.packageSize,
      );
      emit(OrderCreated(order: order));
    } catch (e) {
      emit(OrderError(message: _extractErrorMessage(e)));
    }
  }

  Future<void> _onGetOrdersRequested(
    GetOrdersRequested event,
    Emitter<OrderState> emit,
  ) async {
    final currentState = state;

    if (event.refresh || currentState is! OrdersLoaded) {
      emit(OrderLoading());
    }

    try {
      final orders = await getOrdersUseCase(
        page: event.page,
        perPage: event.perPage,
        status: event.status,
      );

      if (event.refresh || event.page == 1) {
        emit(OrdersLoaded(
          orders: orders,
          hasMore: orders.length >= event.perPage,
          currentPage: event.page,
        ));
      } else if (currentState is OrdersLoaded) {
        emit(OrdersLoaded(
          orders: [...currentState.orders, ...orders],
          hasMore: orders.length >= event.perPage,
          currentPage: event.page,
        ));
      }
    } catch (e) {
      emit(OrderError(message: _extractErrorMessage(e)));
    }
  }

  Future<void> _onGetOrderDetailsRequested(
    GetOrderDetailsRequested event,
    Emitter<OrderState> emit,
  ) async {
    emit(OrderLoading());

    try {
      final order = await getOrderDetailsUseCase(event.orderId);
      emit(OrderDetailsLoaded(order: order));
    } catch (e) {
      emit(OrderError(message: _extractErrorMessage(e)));
    }
  }

  Future<void> _onCancelOrderRequested(
    CancelOrderRequested event,
    Emitter<OrderState> emit,
  ) async {
    emit(OrderLoading());

    try {
      await cancelOrderUseCase(event.orderId, reason: event.reason);
      emit(OrderCancelled(orderId: event.orderId));
    } catch (e) {
      emit(OrderError(message: _extractErrorMessage(e)));
    }
  }

  Future<void> _onCalculatePriceRequested(
    CalculatePriceRequested event,
    Emitter<OrderState> emit,
  ) async {
    // Calcul local de la distance et du prix
    // Formule Haversine pour la distance
    const baseFare = 500.0; // 500 FCFA
    const pricePerKm = 200.0; // 200 FCFA/km

    final distance = _calculateDistance(
      event.pickupLatitude,
      event.pickupLongitude,
      event.deliveryLatitude,
      event.deliveryLongitude,
    );

    final price = baseFare + (distance * pricePerKm);

    emit(PriceCalculated(
      price: price,
      distance: distance,
    ));
  }

  Future<void> _onStartOrderTrackingRequested(
    StartOrderTrackingRequested event,
    Emitter<OrderState> emit,
  ) async {
    // Annuler l'ancien tracking
    await _trackingSubscription?.cancel();

    // Charger d'abord les détails actuels
    try {
      final order = await getOrderDetailsUseCase(event.orderId);
      emit(OrderTracking(order: order));
    } catch (e) {
      emit(OrderError(message: _extractErrorMessage(e)));
    }
  }

  Future<void> _onStopOrderTrackingRequested(
    StopOrderTrackingRequested event,
    Emitter<OrderState> emit,
  ) async {
    await _trackingSubscription?.cancel();
    _trackingSubscription = null;
  }

  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const R = 6371.0; // Rayon de la Terre en km
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  double _toRadians(double degrees) {
    return degrees * pi / 180;
  }

  String _extractErrorMessage(dynamic error) {
    if (error.toString().contains('DioException')) {
      if (error.toString().contains('404')) {
        return 'Commande non trouvée';
      }
      if (error.toString().contains('422')) {
        return 'Données invalides';
      }
      if (error.toString().contains('connection')) {
        return 'Erreur de connexion. Vérifiez votre internet.';
      }
    }
    return 'Une erreur est survenue. Réessayez.';
  }

  Future<void> _onRateCourierRequested(
    RateCourierRequested event,
    Emitter<OrderState> emit,
  ) async {
    emit(OrderLoading());

    try {
      final order = await rateCourierUseCase(
        orderId: event.orderId,
        rating: event.rating,
        review: event.review,
        tags: event.tags,
      );
      emit(CourierRated(order: order));
      emit(OrderDetailsLoaded(order: order));
    } catch (e) {
      emit(OrderError(message: _extractErrorMessage(e)));
    }
  }

  @override
  Future<void> close() {
    _trackingSubscription?.cancel();
    return super.close();
  }
}
