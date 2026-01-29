import 'package:flutter_test/flutter_test.dart';
import 'package:ouaga_chap_client/features/incoming/presentation/bloc/incoming_order_event.dart';

void main() {
  group('IncomingOrderEvent', () {
    group('LoadIncomingOrders', () {
      test('creates instance without status', () {
        const event = LoadIncomingOrders();
        expect(event, isA<IncomingOrderEvent>());
        expect(event.status, isNull);
      });

      test('creates instance with status', () {
        const event = LoadIncomingOrders(status: 'pending');
        expect(event.status, 'pending');
      });

      test('props contains status', () {
        const event = LoadIncomingOrders(status: 'pending');
        expect(event.props, ['pending']);
      });

      test('props contains null when no status', () {
        const event = LoadIncomingOrders();
        expect(event.props, [null]);
      });

      test('two events with same status are equal', () {
        const event1 = LoadIncomingOrders(status: 'pending');
        const event2 = LoadIncomingOrders(status: 'pending');
        expect(event1, equals(event2));
      });

      test('two events with different status are not equal', () {
        const event1 = LoadIncomingOrders(status: 'pending');
        const event2 = LoadIncomingOrders(status: 'delivered');
        expect(event1, isNot(equals(event2)));
      });

      test('two events without status are equal', () {
        const event1 = LoadIncomingOrders();
        const event2 = LoadIncomingOrders();
        expect(event1, equals(event2));
      });
    });

    group('LoadIncomingOrderDetails', () {
      test('creates instance with orderId', () {
        const event = LoadIncomingOrderDetails('order-123');
        expect(event, isA<IncomingOrderEvent>());
        expect(event.orderId, 'order-123');
      });

      test('props contains orderId', () {
        const event = LoadIncomingOrderDetails('order-456');
        expect(event.props, ['order-456']);
      });

      test('two events with same orderId are equal', () {
        const event1 = LoadIncomingOrderDetails('order-1');
        const event2 = LoadIncomingOrderDetails('order-1');
        expect(event1, equals(event2));
      });

      test('two events with different orderId are not equal', () {
        const event1 = LoadIncomingOrderDetails('order-1');
        const event2 = LoadIncomingOrderDetails('order-2');
        expect(event1, isNot(equals(event2)));
      });
    });

    group('TrackIncomingOrder', () {
      test('creates instance with orderId', () {
        const event = TrackIncomingOrder('track-123');
        expect(event, isA<IncomingOrderEvent>());
        expect(event.orderId, 'track-123');
      });

      test('props contains orderId', () {
        const event = TrackIncomingOrder('track-456');
        expect(event.props, ['track-456']);
      });

      test('two events with same orderId are equal', () {
        const event1 = TrackIncomingOrder('track-1');
        const event2 = TrackIncomingOrder('track-1');
        expect(event1, equals(event2));
      });

      test('two events with different orderId are not equal', () {
        const event1 = TrackIncomingOrder('track-1');
        const event2 = TrackIncomingOrder('track-2');
        expect(event1, isNot(equals(event2)));
      });
    });

    group('ConfirmIncomingOrderReceipt', () {
      test('creates instance with orderId and confirmationCode', () {
        const event = ConfirmIncomingOrderReceipt(
          orderId: 'order-123',
          confirmationCode: 'ABC123',
        );
        expect(event, isA<IncomingOrderEvent>());
        expect(event.orderId, 'order-123');
        expect(event.confirmationCode, 'ABC123');
      });

      test('props contains orderId and confirmationCode', () {
        const event = ConfirmIncomingOrderReceipt(
          orderId: 'order-456',
          confirmationCode: 'XYZ789',
        );
        expect(event.props, ['order-456', 'XYZ789']);
      });

      test('two events with same props are equal', () {
        const event1 = ConfirmIncomingOrderReceipt(
          orderId: 'order-1',
          confirmationCode: 'CODE1',
        );
        const event2 = ConfirmIncomingOrderReceipt(
          orderId: 'order-1',
          confirmationCode: 'CODE1',
        );
        expect(event1, equals(event2));
      });

      test('two events with different orderId are not equal', () {
        const event1 = ConfirmIncomingOrderReceipt(
          orderId: 'order-1',
          confirmationCode: 'CODE1',
        );
        const event2 = ConfirmIncomingOrderReceipt(
          orderId: 'order-2',
          confirmationCode: 'CODE1',
        );
        expect(event1, isNot(equals(event2)));
      });

      test('two events with different confirmationCode are not equal', () {
        const event1 = ConfirmIncomingOrderReceipt(
          orderId: 'order-1',
          confirmationCode: 'CODE1',
        );
        const event2 = ConfirmIncomingOrderReceipt(
          orderId: 'order-1',
          confirmationCode: 'CODE2',
        );
        expect(event1, isNot(equals(event2)));
      });
    });

    group('RefreshIncomingOrders', () {
      test('creates instance', () {
        const event = RefreshIncomingOrders();
        expect(event, isA<IncomingOrderEvent>());
      });

      test('props is empty (inherited from base class)', () {
        const event = RefreshIncomingOrders();
        expect(event.props, isEmpty);
      });

      test('two instances are equal', () {
        const event1 = RefreshIncomingOrders();
        const event2 = RefreshIncomingOrders();
        expect(event1, equals(event2));
      });
    });

    group('Base IncomingOrderEvent', () {
      test('LoadIncomingOrders extends IncomingOrderEvent', () {
        const event = LoadIncomingOrders();
        expect(event, isA<IncomingOrderEvent>());
      });

      test('LoadIncomingOrderDetails extends IncomingOrderEvent', () {
        const event = LoadIncomingOrderDetails('id');
        expect(event, isA<IncomingOrderEvent>());
      });

      test('TrackIncomingOrder extends IncomingOrderEvent', () {
        const event = TrackIncomingOrder('id');
        expect(event, isA<IncomingOrderEvent>());
      });

      test('ConfirmIncomingOrderReceipt extends IncomingOrderEvent', () {
        const event = ConfirmIncomingOrderReceipt(
          orderId: 'id',
          confirmationCode: 'code',
        );
        expect(event, isA<IncomingOrderEvent>());
      });

      test('RefreshIncomingOrders extends IncomingOrderEvent', () {
        const event = RefreshIncomingOrders();
        expect(event, isA<IncomingOrderEvent>());
      });
    });
  });
}
