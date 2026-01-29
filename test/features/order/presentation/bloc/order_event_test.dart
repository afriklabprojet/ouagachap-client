import 'package:flutter_test/flutter_test.dart';
import 'package:ouaga_chap_client/features/order/domain/entities/order.dart';
import 'package:ouaga_chap_client/features/order/presentation/bloc/order_event.dart';

void main() {
  group('OrderEvent', () {
    group('CreateOrderRequested', () {
      test('props should contain key fields', () {
        const event = CreateOrderRequested(
          pickupAddress: '123 Rue Test',
          pickupLatitude: 12.34,
          pickupLongitude: -1.56,
          deliveryAddress: '456 Avenue Test',
          deliveryLatitude: 12.45,
          deliveryLongitude: -1.67,
          recipientName: 'John Doe',
          recipientPhone: '+22670000000',
        );
        expect(event.props, [
          '123 Rue Test',
          '456 Avenue Test',
          'John Doe',
          '+22670000000',
        ]);
      });

      test('stores all addresses and coordinates', () {
        const event = CreateOrderRequested(
          pickupAddress: '123 Rue Test',
          pickupLatitude: 12.34,
          pickupLongitude: -1.56,
          deliveryAddress: '456 Avenue Test',
          deliveryLatitude: 12.45,
          deliveryLongitude: -1.67,
          recipientName: 'John Doe',
          recipientPhone: '+22670000000',
        );
        
        expect(event.pickupAddress, '123 Rue Test');
        expect(event.pickupLatitude, 12.34);
        expect(event.pickupLongitude, -1.56);
        expect(event.deliveryAddress, '456 Avenue Test');
        expect(event.deliveryLatitude, 12.45);
        expect(event.deliveryLongitude, -1.67);
        expect(event.recipientName, 'John Doe');
        expect(event.recipientPhone, '+22670000000');
      });

      test('optional fields are nullable', () {
        const event = CreateOrderRequested(
          pickupAddress: '123 Rue',
          pickupLatitude: 12.0,
          pickupLongitude: -1.0,
          deliveryAddress: '456 Avenue',
          deliveryLatitude: 13.0,
          deliveryLongitude: -2.0,
          recipientName: 'John',
          recipientPhone: '+22670000000',
        );
        
        expect(event.pickupContactName, isNull);
        expect(event.pickupContactPhone, isNull);
        expect(event.packageDescription, isNull);
        expect(event.packageSize, isNull);
      });

      test('two events with same data are equal', () {
        const event1 = CreateOrderRequested(
          pickupAddress: '123 Rue',
          pickupLatitude: 12.0,
          pickupLongitude: -1.0,
          deliveryAddress: '456 Avenue',
          deliveryLatitude: 13.0,
          deliveryLongitude: -2.0,
          recipientName: 'John',
          recipientPhone: '+22670000000',
        );
        const event2 = CreateOrderRequested(
          pickupAddress: '123 Rue',
          pickupLatitude: 12.0,
          pickupLongitude: -1.0,
          deliveryAddress: '456 Avenue',
          deliveryLatitude: 13.0,
          deliveryLongitude: -2.0,
          recipientName: 'John',
          recipientPhone: '+22670000000',
        );
        
        expect(event1, event2);
      });
    });

    group('GetOrdersRequested', () {
      test('props should contain page, perPage, status, refresh', () {
        const event = GetOrdersRequested(
          page: 2,
          perPage: 20,
          status: OrderStatus.pending,
          refresh: true,
        );
        expect(event.props, [2, 20, OrderStatus.pending, true]);
      });

      test('default values are correct', () {
        const event = GetOrdersRequested();
        
        expect(event.page, 1);
        expect(event.perPage, 10);
        expect(event.status, isNull);
        expect(event.refresh, false);
      });

      test('two events with same data are equal', () {
        const event1 = GetOrdersRequested(page: 1, perPage: 10);
        const event2 = GetOrdersRequested(page: 1, perPage: 10);
        
        expect(event1, event2);
      });

      test('two events with different data are not equal', () {
        const event1 = GetOrdersRequested(page: 1);
        const event2 = GetOrdersRequested(page: 2);
        
        expect(event1, isNot(event2));
      });
    });

    group('GetOrderDetailsRequested', () {
      test('props should contain orderId', () {
        const event = GetOrderDetailsRequested(orderId: 123);
        expect(event.props, [123]);
      });

      test('stores orderId', () {
        const event = GetOrderDetailsRequested(orderId: 456);
        expect(event.orderId, 456);
      });

      test('two events with same orderId are equal', () {
        const event1 = GetOrderDetailsRequested(orderId: 1);
        const event2 = GetOrderDetailsRequested(orderId: 1);
        
        expect(event1, event2);
      });

      test('two events with different orderId are not equal', () {
        const event1 = GetOrderDetailsRequested(orderId: 1);
        const event2 = GetOrderDetailsRequested(orderId: 2);
        
        expect(event1, isNot(event2));
      });
    });

    group('CancelOrderRequested', () {
      test('props should contain orderId and reason', () {
        const event = CancelOrderRequested(orderId: 1, reason: 'Changed mind');
        expect(event.props, [1, 'Changed mind']);
      });

      test('reason is optional', () {
        const event = CancelOrderRequested(orderId: 1);
        expect(event.reason, isNull);
      });

      test('stores orderId and reason', () {
        const event = CancelOrderRequested(orderId: 123, reason: 'Test reason');
        expect(event.orderId, 123);
        expect(event.reason, 'Test reason');
      });

      test('two events with same data are equal', () {
        const event1 = CancelOrderRequested(orderId: 1, reason: 'test');
        const event2 = CancelOrderRequested(orderId: 1, reason: 'test');
        
        expect(event1, event2);
      });
    });

    group('CalculatePriceRequested', () {
      test('props should contain coordinates', () {
        const event = CalculatePriceRequested(
          pickupLatitude: 12.0,
          pickupLongitude: -1.0,
          deliveryLatitude: 13.0,
          deliveryLongitude: -2.0,
        );
        expect(event.props, [12.0, -1.0, 13.0, -2.0]);
      });

      test('stores all coordinates', () {
        const event = CalculatePriceRequested(
          pickupLatitude: 12.34,
          pickupLongitude: -1.56,
          deliveryLatitude: 12.45,
          deliveryLongitude: -1.67,
        );
        
        expect(event.pickupLatitude, 12.34);
        expect(event.pickupLongitude, -1.56);
        expect(event.deliveryLatitude, 12.45);
        expect(event.deliveryLongitude, -1.67);
      });
    });

    group('StartOrderTrackingRequested', () {
      test('props should contain orderId', () {
        const event = StartOrderTrackingRequested(orderId: 1);
        expect(event.props, [1]);
      });

      test('stores orderId', () {
        const event = StartOrderTrackingRequested(orderId: 123);
        expect(event.orderId, 123);
      });
    });

    group('StopOrderTrackingRequested', () {
      test('props should be empty', () {
        final event = StopOrderTrackingRequested();
        expect(event.props, isEmpty);
      });

      test('two instances are equal', () {
        final event1 = StopOrderTrackingRequested();
        final event2 = StopOrderTrackingRequested();
        
        expect(event1, event2);
      });
    });
  });
}
