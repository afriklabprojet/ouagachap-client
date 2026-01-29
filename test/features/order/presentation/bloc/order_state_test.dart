import 'package:flutter_test/flutter_test.dart';
import 'package:ouaga_chap_client/features/order/domain/entities/order.dart';
import 'package:ouaga_chap_client/features/order/presentation/bloc/order_state.dart';

void main() {
  final testOrder = Order(
    id: 1,
    trackingNumber: 'TRK-123456',
    status: OrderStatus.pending,
    pickupAddress: '123 Rue Test',
    pickupLatitude: 12.34,
    pickupLongitude: -1.56,
    deliveryAddress: '456 Avenue Test',
    deliveryLatitude: 12.45,
    deliveryLongitude: -1.67,
    recipientName: 'John Doe',
    recipientPhone: '+22670000000',
    price: 1500,
    distance: 5.0,
    createdAt: DateTime(2024, 1, 15),
  );

  final testOrders = [
    testOrder,
    Order(
      id: 2,
      trackingNumber: 'TRK-789012',
      status: OrderStatus.delivered,
      pickupAddress: '789 Rue Test',
      pickupLatitude: 12.56,
      pickupLongitude: -1.78,
      deliveryAddress: '012 Avenue Test',
      deliveryLatitude: 12.67,
      deliveryLongitude: -1.89,
      recipientName: 'Jane Doe',
      recipientPhone: '+22670000001',
      price: 2000,
      distance: 8.0,
      createdAt: DateTime(2024, 1, 16),
    ),
  ];

  group('OrderState', () {
    group('OrderInitial', () {
      test('is a subclass of OrderState', () {
        expect(OrderInitial(), isA<OrderState>());
      });

      test('props should be empty', () {
        expect(OrderInitial().props, isEmpty);
      });

      test('two instances are equal', () {
        expect(OrderInitial(), OrderInitial());
      });
    });

    group('OrderLoading', () {
      test('is a subclass of OrderState', () {
        expect(OrderLoading(), isA<OrderState>());
      });

      test('props should be empty', () {
        expect(OrderLoading().props, isEmpty);
      });

      test('two instances are equal', () {
        expect(OrderLoading(), OrderLoading());
      });
    });

    group('OrderCreated', () {
      test('props should contain order', () {
        final state = OrderCreated(order: testOrder);
        expect(state.props, [testOrder]);
      });

      test('stores order', () {
        final state = OrderCreated(order: testOrder);
        expect(state.order, testOrder);
      });

      test('two states with same order are equal', () {
        final state1 = OrderCreated(order: testOrder);
        final state2 = OrderCreated(order: testOrder);
        
        expect(state1, state2);
      });
    });

    group('OrdersLoaded', () {
      test('props should contain orders, hasMore, currentPage', () {
        final state = OrdersLoaded(
          orders: testOrders,
          hasMore: true,
          currentPage: 2,
        );
        expect(state.props, [testOrders, true, 2]);
      });

      test('default values are correct', () {
        final state = OrdersLoaded(orders: testOrders);
        
        expect(state.hasMore, false);
        expect(state.currentPage, 1);
      });

      test('stores orders', () {
        final state = OrdersLoaded(orders: testOrders);
        expect(state.orders, testOrders);
        expect(state.orders.length, 2);
      });

      test('copyWith preserves values when not specified', () {
        final state = OrdersLoaded(
          orders: testOrders,
          hasMore: true,
          currentPage: 2,
        );
        final copied = state.copyWith();
        
        expect(copied.orders, testOrders);
        expect(copied.hasMore, true);
        expect(copied.currentPage, 2);
      });

      test('copyWith changes orders', () {
        final state = OrdersLoaded(orders: testOrders);
        final newOrders = [testOrder];
        final copied = state.copyWith(orders: newOrders);
        
        expect(copied.orders, newOrders);
        expect(copied.orders.length, 1);
      });

      test('copyWith changes hasMore', () {
        final state = OrdersLoaded(orders: testOrders, hasMore: false);
        final copied = state.copyWith(hasMore: true);
        
        expect(copied.hasMore, true);
      });

      test('copyWith changes currentPage', () {
        final state = OrdersLoaded(orders: testOrders, currentPage: 1);
        final copied = state.copyWith(currentPage: 5);
        
        expect(copied.currentPage, 5);
      });

      test('two states with same data are equal', () {
        final state1 = OrdersLoaded(orders: testOrders, hasMore: true, currentPage: 2);
        final state2 = OrdersLoaded(orders: testOrders, hasMore: true, currentPage: 2);
        
        expect(state1, state2);
      });
    });

    group('OrderDetailsLoaded', () {
      test('props should contain order', () {
        final state = OrderDetailsLoaded(order: testOrder);
        expect(state.props, [testOrder]);
      });

      test('stores order', () {
        final state = OrderDetailsLoaded(order: testOrder);
        expect(state.order, testOrder);
      });

      test('two states with same order are equal', () {
        final state1 = OrderDetailsLoaded(order: testOrder);
        final state2 = OrderDetailsLoaded(order: testOrder);
        
        expect(state1, state2);
      });
    });

    group('OrderCancelled', () {
      test('props should contain orderId', () {
        const state = OrderCancelled(orderId: 123);
        expect(state.props, [123]);
      });

      test('stores orderId', () {
        const state = OrderCancelled(orderId: 456);
        expect(state.orderId, 456);
      });

      test('two states with same orderId are equal', () {
        const state1 = OrderCancelled(orderId: 1);
        const state2 = OrderCancelled(orderId: 1);
        
        expect(state1, state2);
      });

      test('two states with different orderId are not equal', () {
        const state1 = OrderCancelled(orderId: 1);
        const state2 = OrderCancelled(orderId: 2);
        
        expect(state1, isNot(state2));
      });
    });

    group('PriceCalculated', () {
      test('props should contain price and distance', () {
        const state = PriceCalculated(price: 1500, distance: 5.0);
        expect(state.props, [1500.0, 5.0]);
      });

      test('stores price and distance', () {
        const state = PriceCalculated(price: 2500, distance: 10.5);
        expect(state.price, 2500);
        expect(state.distance, 10.5);
      });

      test('two states with same data are equal', () {
        const state1 = PriceCalculated(price: 1500, distance: 5.0);
        const state2 = PriceCalculated(price: 1500, distance: 5.0);
        
        expect(state1, state2);
      });

      test('two states with different price are not equal', () {
        const state1 = PriceCalculated(price: 1500, distance: 5.0);
        const state2 = PriceCalculated(price: 2000, distance: 5.0);
        
        expect(state1, isNot(state2));
      });
    });

    group('OrderError', () {
      test('props should contain message', () {
        const state = OrderError(message: 'Test error');
        expect(state.props, ['Test error']);
      });

      test('stores message', () {
        const state = OrderError(message: 'Something went wrong');
        expect(state.message, 'Something went wrong');
      });

      test('two states with same message are equal', () {
        const state1 = OrderError(message: 'Error');
        const state2 = OrderError(message: 'Error');
        
        expect(state1, state2);
      });

      test('two states with different message are not equal', () {
        const state1 = OrderError(message: 'Error 1');
        const state2 = OrderError(message: 'Error 2');
        
        expect(state1, isNot(state2));
      });
    });

    group('OrderTracking', () {
      test('props should contain order and tracking info', () {
        final state = OrderTracking(order: testOrder);
        expect(state.props, [testOrder, testOrder.status, testOrder.courier?.currentLatitude]);
      });

      test('stores order', () {
        final state = OrderTracking(order: testOrder);
        expect(state.order, testOrder);
      });
    });
  });
}
