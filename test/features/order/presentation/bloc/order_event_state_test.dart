import 'package:flutter_test/flutter_test.dart';
import 'package:ouaga_chap_client/features/order/domain/entities/order.dart';
import 'package:ouaga_chap_client/features/order/presentation/bloc/order_state.dart';
import 'package:ouaga_chap_client/features/order/presentation/bloc/order_event.dart';

void main() {
  group('OrderEvent', () {
    group('CreateOrderRequested', () {
      test('creates instance with required fields', () {
        const event = CreateOrderRequested(
          pickupAddress: 'Pickup Address',
          pickupLatitude: 12.3456,
          pickupLongitude: -1.2345,
          deliveryAddress: 'Delivery Address',
          deliveryLatitude: 12.4567,
          deliveryLongitude: -1.3456,
          recipientName: 'John Doe',
          recipientPhone: '70123456',
        );

        expect(event.pickupAddress, 'Pickup Address');
        expect(event.pickupLatitude, 12.3456);
        expect(event.pickupLongitude, -1.2345);
        expect(event.deliveryAddress, 'Delivery Address');
        expect(event.deliveryLatitude, 12.4567);
        expect(event.deliveryLongitude, -1.3456);
        expect(event.recipientName, 'John Doe');
        expect(event.recipientPhone, '70123456');
        expect(event.pickupContactName, isNull);
        expect(event.pickupContactPhone, isNull);
        expect(event.packageDescription, isNull);
        expect(event.packageSize, isNull);
      });

      test('creates instance with all fields', () {
        const event = CreateOrderRequested(
          pickupAddress: 'Pickup Address',
          pickupLatitude: 12.3456,
          pickupLongitude: -1.2345,
          pickupContactName: 'Jane',
          pickupContactPhone: '70111111',
          deliveryAddress: 'Delivery Address',
          deliveryLatitude: 12.4567,
          deliveryLongitude: -1.3456,
          recipientName: 'John Doe',
          recipientPhone: '70123456',
          packageDescription: 'Small package',
          packageSize: 'small',
        );

        expect(event.pickupContactName, 'Jane');
        expect(event.pickupContactPhone, '70111111');
        expect(event.packageDescription, 'Small package');
        expect(event.packageSize, 'small');
      });

      test('props contains key fields', () {
        const event = CreateOrderRequested(
          pickupAddress: 'Pickup Address',
          pickupLatitude: 12.3456,
          pickupLongitude: -1.2345,
          deliveryAddress: 'Delivery Address',
          deliveryLatitude: 12.4567,
          deliveryLongitude: -1.3456,
          recipientName: 'John Doe',
          recipientPhone: '70123456',
        );

        expect(
          event.props,
          ['Pickup Address', 'Delivery Address', 'John Doe', '70123456'],
        );
      });

      test('two events with same props are equal', () {
        const event1 = CreateOrderRequested(
          pickupAddress: 'Pickup',
          pickupLatitude: 12.0,
          pickupLongitude: -1.0,
          deliveryAddress: 'Delivery',
          deliveryLatitude: 12.1,
          deliveryLongitude: -1.1,
          recipientName: 'John',
          recipientPhone: '70000000',
        );
        const event2 = CreateOrderRequested(
          pickupAddress: 'Pickup',
          pickupLatitude: 12.0,
          pickupLongitude: -1.0,
          deliveryAddress: 'Delivery',
          deliveryLatitude: 12.1,
          deliveryLongitude: -1.1,
          recipientName: 'John',
          recipientPhone: '70000000',
        );

        expect(event1, equals(event2));
      });
    });

    group('GetOrdersRequested', () {
      test('creates instance with default values', () {
        const event = GetOrdersRequested();

        expect(event.page, 1);
        expect(event.perPage, 10);
        expect(event.status, isNull);
        expect(event.refresh, false);
      });

      test('creates instance with custom values', () {
        const event = GetOrdersRequested(
          page: 2,
          perPage: 20,
          status: OrderStatus.pending,
          refresh: true,
        );

        expect(event.page, 2);
        expect(event.perPage, 20);
        expect(event.status, OrderStatus.pending);
        expect(event.refresh, true);
      });

      test('props contains all fields', () {
        const event = GetOrdersRequested(
          page: 1,
          perPage: 10,
          status: OrderStatus.delivered,
          refresh: true,
        );

        expect(event.props, [1, 10, OrderStatus.delivered, true]);
      });

      test('two events with same props are equal', () {
        const event1 = GetOrdersRequested(page: 1, perPage: 10);
        const event2 = GetOrdersRequested(page: 1, perPage: 10);

        expect(event1, equals(event2));
      });
    });

    group('GetOrderDetailsRequested', () {
      test('creates instance with orderId', () {
        const event = GetOrderDetailsRequested(orderId: 123);

        expect(event.orderId, 123);
      });

      test('props contains orderId', () {
        const event = GetOrderDetailsRequested(orderId: 123);

        expect(event.props, [123]);
      });

      test('two events with same orderId are equal', () {
        const event1 = GetOrderDetailsRequested(orderId: 123);
        const event2 = GetOrderDetailsRequested(orderId: 123);

        expect(event1, equals(event2));
      });

      test('two events with different orderId are not equal', () {
        const event1 = GetOrderDetailsRequested(orderId: 123);
        const event2 = GetOrderDetailsRequested(orderId: 456);

        expect(event1, isNot(equals(event2)));
      });
    });

    group('CancelOrderRequested', () {
      test('creates instance with required orderId', () {
        const event = CancelOrderRequested(orderId: 123);

        expect(event.orderId, 123);
        expect(event.reason, isNull);
      });

      test('creates instance with reason', () {
        const event = CancelOrderRequested(
          orderId: 123,
          reason: 'Changed my mind',
        );

        expect(event.orderId, 123);
        expect(event.reason, 'Changed my mind');
      });

      test('props contains orderId and reason', () {
        const event = CancelOrderRequested(orderId: 123, reason: 'Test');

        expect(event.props, [123, 'Test']);
      });
    });

    group('CalculatePriceRequested', () {
      test('creates instance with coordinates', () {
        const event = CalculatePriceRequested(
          pickupLatitude: 12.3456,
          pickupLongitude: -1.2345,
          deliveryLatitude: 12.4567,
          deliveryLongitude: -1.3456,
        );

        expect(event.pickupLatitude, 12.3456);
        expect(event.pickupLongitude, -1.2345);
        expect(event.deliveryLatitude, 12.4567);
        expect(event.deliveryLongitude, -1.3456);
      });

      test('props contains all coordinates', () {
        const event = CalculatePriceRequested(
          pickupLatitude: 12.0,
          pickupLongitude: -1.0,
          deliveryLatitude: 13.0,
          deliveryLongitude: -2.0,
        );

        expect(event.props, [12.0, -1.0, 13.0, -2.0]);
      });
    });

    group('StartOrderTrackingRequested', () {
      test('creates instance with orderId', () {
        const event = StartOrderTrackingRequested(orderId: 123);

        expect(event.orderId, 123);
      });

      test('props contains orderId', () {
        const event = StartOrderTrackingRequested(orderId: 123);

        expect(event.props, [123]);
      });
    });

    group('StopOrderTrackingRequested', () {
      test('creates instance', () {
        final event = StopOrderTrackingRequested();

        expect(event, isA<OrderEvent>());
      });

      test('props is empty', () {
        final event = StopOrderTrackingRequested();

        expect(event.props, isEmpty);
      });
    });
  });

  group('OrderState', () {
    final testOrder = Order(
      id: 1,
      trackingNumber: 'TRK001',
      pickupAddress: 'Pickup',
      pickupLatitude: 12.0,
      pickupLongitude: -1.0,
      deliveryAddress: 'Delivery',
      deliveryLatitude: 12.1,
      deliveryLongitude: -1.1,
      recipientName: 'John',
      recipientPhone: '70000000',
      distance: 5.0,
      price: 1500.0,
      status: OrderStatus.pending,
      createdAt: DateTime(2024, 1, 15),
    );

    group('OrderInitial', () {
      test('creates instance', () {
        final state = OrderInitial();

        expect(state, isA<OrderState>());
      });

      test('props is empty', () {
        final state = OrderInitial();

        expect(state.props, isEmpty);
      });

      test('two instances are equal', () {
        final state1 = OrderInitial();
        final state2 = OrderInitial();

        expect(state1, equals(state2));
      });
    });

    group('OrderLoading', () {
      test('creates instance', () {
        final state = OrderLoading();

        expect(state, isA<OrderState>());
      });

      test('props is empty', () {
        final state = OrderLoading();

        expect(state.props, isEmpty);
      });

      test('two instances are equal', () {
        final state1 = OrderLoading();
        final state2 = OrderLoading();

        expect(state1, equals(state2));
      });
    });

    group('OrderCreated', () {
      test('creates instance with order', () {
        final state = OrderCreated(order: testOrder);

        expect(state.order, testOrder);
      });

      test('props contains order', () {
        final state = OrderCreated(order: testOrder);

        expect(state.props, [testOrder]);
      });

      test('two states with same order are equal', () {
        final state1 = OrderCreated(order: testOrder);
        final state2 = OrderCreated(order: testOrder);

        expect(state1, equals(state2));
      });
    });

    group('OrdersLoaded', () {
      test('creates instance with orders', () {
        final state = OrdersLoaded(orders: [testOrder]);

        expect(state.orders, [testOrder]);
        expect(state.hasMore, false);
        expect(state.currentPage, 1);
      });

      test('creates instance with all fields', () {
        final state = OrdersLoaded(
          orders: [testOrder],
          hasMore: true,
          currentPage: 2,
        );

        expect(state.orders, [testOrder]);
        expect(state.hasMore, true);
        expect(state.currentPage, 2);
      });

      test('props contains orders, hasMore and currentPage', () {
        final state = OrdersLoaded(
          orders: [testOrder],
          hasMore: true,
          currentPage: 2,
        );

        expect(state.props, [[testOrder], true, 2]);
      });

      test('copyWith creates new instance with updated values', () {
        final state = OrdersLoaded(
          orders: [testOrder],
          hasMore: false,
          currentPage: 1,
        );

        final copied = state.copyWith(
          hasMore: true,
          currentPage: 2,
        );

        expect(copied.orders, state.orders);
        expect(copied.hasMore, true);
        expect(copied.currentPage, 2);
      });

      test('copyWith preserves values when not provided', () {
        final state = OrdersLoaded(
          orders: [testOrder],
          hasMore: true,
          currentPage: 3,
        );

        final copied = state.copyWith();

        expect(copied.orders, state.orders);
        expect(copied.hasMore, state.hasMore);
        expect(copied.currentPage, state.currentPage);
      });
    });

    group('OrderDetailsLoaded', () {
      test('creates instance with order', () {
        final state = OrderDetailsLoaded(order: testOrder);

        expect(state.order, testOrder);
      });

      test('props contains order', () {
        final state = OrderDetailsLoaded(order: testOrder);

        expect(state.props, [testOrder]);
      });
    });

    group('OrderCancelled', () {
      test('creates instance with orderId', () {
        const state = OrderCancelled(orderId: 123);

        expect(state.orderId, 123);
      });

      test('props contains orderId', () {
        const state = OrderCancelled(orderId: 123);

        expect(state.props, [123]);
      });

      test('two states with same orderId are equal', () {
        const state1 = OrderCancelled(orderId: 123);
        const state2 = OrderCancelled(orderId: 123);

        expect(state1, equals(state2));
      });
    });

    group('PriceCalculated', () {
      test('creates instance with price and distance', () {
        const state = PriceCalculated(price: 1500.0, distance: 5.5);

        expect(state.price, 1500.0);
        expect(state.distance, 5.5);
      });

      test('props contains price and distance', () {
        const state = PriceCalculated(price: 1500.0, distance: 5.5);

        expect(state.props, [1500.0, 5.5]);
      });

      test('two states with same values are equal', () {
        const state1 = PriceCalculated(price: 1500.0, distance: 5.5);
        const state2 = PriceCalculated(price: 1500.0, distance: 5.5);

        expect(state1, equals(state2));
      });
    });

    group('OrderError', () {
      test('creates instance with message', () {
        const state = OrderError(message: 'Error occurred');

        expect(state.message, 'Error occurred');
      });

      test('props contains message', () {
        const state = OrderError(message: 'Error occurred');

        expect(state.props, ['Error occurred']);
      });

      test('two states with same message are equal', () {
        const state1 = OrderError(message: 'Error');
        const state2 = OrderError(message: 'Error');

        expect(state1, equals(state2));
      });

      test('two states with different messages are not equal', () {
        const state1 = OrderError(message: 'Error 1');
        const state2 = OrderError(message: 'Error 2');

        expect(state1, isNot(equals(state2)));
      });
    });

    group('OrderTracking', () {
      test('creates instance with order', () {
        final state = OrderTracking(order: testOrder);

        expect(state.order, testOrder);
      });

      test('props contains order status and courier location', () {
        final orderWithCourier = Order(
          id: 1,
          trackingNumber: 'TRK001',
          pickupAddress: 'Pickup',
          pickupLatitude: 12.0,
          pickupLongitude: -1.0,
          deliveryAddress: 'Delivery',
          deliveryLatitude: 12.1,
          deliveryLongitude: -1.1,
          recipientName: 'John',
          recipientPhone: '70000000',
          distance: 5.0,
          price: 1500.0,
          status: OrderStatus.inTransit,
          createdAt: DateTime(2024, 1, 15),
          courier: const Courier(
            id: 1,
            name: 'Courier',
            phone: '70111111',
            currentLatitude: 12.05,
            currentLongitude: -1.05,
          ),
        );

        final state = OrderTracking(order: orderWithCourier);

        expect(state.props, [orderWithCourier, OrderStatus.inTransit, 12.05]);
      });

      test('props handles null courier location', () {
        final state = OrderTracking(order: testOrder);

        expect(state.props, [testOrder, OrderStatus.pending, null]);
      });
    });
  });
}
