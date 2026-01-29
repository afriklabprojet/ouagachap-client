import 'package:flutter_test/flutter_test.dart';
import 'package:ouaga_chap_client/features/incoming/domain/entities/incoming_order.dart';
import 'package:ouaga_chap_client/features/incoming/presentation/bloc/incoming_order_event.dart';
import 'package:ouaga_chap_client/features/incoming/presentation/bloc/incoming_order_state.dart';

void main() {
  group('IncomingOrderEvent', () {
    group('LoadIncomingOrders', () {
      test('creates instance without status', () {
        const event = LoadIncomingOrders();
        expect(event.status, isNull);
      });

      test('creates instance with status', () {
        const event = LoadIncomingOrders(status: 'pending');
        expect(event.status, 'pending');
      });

      test('props contains status', () {
        const event = LoadIncomingOrders(status: 'delivered');
        expect(event.props, ['delivered']);
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
    });

    group('LoadIncomingOrderDetails', () {
      test('creates instance with orderId', () {
        const event = LoadIncomingOrderDetails('order123');
        expect(event.orderId, 'order123');
      });

      test('props contains orderId', () {
        const event = LoadIncomingOrderDetails('order456');
        expect(event.props, ['order456']);
      });

      test('two events with same orderId are equal', () {
        const event1 = LoadIncomingOrderDetails('order1');
        const event2 = LoadIncomingOrderDetails('order1');
        expect(event1, equals(event2));
      });
    });

    group('TrackIncomingOrder', () {
      test('creates instance with orderId', () {
        const event = TrackIncomingOrder('track123');
        expect(event.orderId, 'track123');
      });

      test('props contains orderId', () {
        const event = TrackIncomingOrder('track456');
        expect(event.props, ['track456']);
      });
    });

    group('ConfirmIncomingOrderReceipt', () {
      test('creates instance with orderId and confirmationCode', () {
        const event = ConfirmIncomingOrderReceipt(
          orderId: 'order123',
          confirmationCode: 'ABC123',
        );

        expect(event.orderId, 'order123');
        expect(event.confirmationCode, 'ABC123');
      });

      test('props contains orderId and confirmationCode', () {
        const event = ConfirmIncomingOrderReceipt(
          orderId: 'order1',
          confirmationCode: 'CODE1',
        );
        expect(event.props, ['order1', 'CODE1']);
      });

      test('two events with same props are equal', () {
        const event1 = ConfirmIncomingOrderReceipt(
          orderId: 'order1',
          confirmationCode: 'CODE1',
        );
        const event2 = ConfirmIncomingOrderReceipt(
          orderId: 'order1',
          confirmationCode: 'CODE1',
        );
        expect(event1, equals(event2));
      });

      test('two events with different props are not equal', () {
        const event1 = ConfirmIncomingOrderReceipt(
          orderId: 'order1',
          confirmationCode: 'CODE1',
        );
        const event2 = ConfirmIncomingOrderReceipt(
          orderId: 'order2',
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

      test('props is empty', () {
        const event = RefreshIncomingOrders();
        expect(event.props, isEmpty);
      });

      test('two instances are equal', () {
        const event1 = RefreshIncomingOrders();
        const event2 = RefreshIncomingOrders();
        expect(event1, equals(event2));
      });
    });
  });

  group('IncomingOrderState', () {
    group('IncomingOrderInitial', () {
      test('creates instance', () {
        const state = IncomingOrderInitial();
        expect(state, isA<IncomingOrderState>());
      });

      test('props is empty', () {
        const state = IncomingOrderInitial();
        expect(state.props, isEmpty);
      });

      test('two instances are equal', () {
        const state1 = IncomingOrderInitial();
        const state2 = IncomingOrderInitial();
        expect(state1, equals(state2));
      });
    });

    group('IncomingOrderLoading', () {
      test('creates instance', () {
        const state = IncomingOrderLoading();
        expect(state, isA<IncomingOrderState>());
      });

      test('props is empty', () {
        const state = IncomingOrderLoading();
        expect(state.props, isEmpty);
      });
    });

    group('IncomingOrderLoaded', () {
      test('creates instance with orders and stats', () {
        const stats = IncomingOrderStats(
          total: 5,
          pending: 2,
          inTransit: 1,
          delivered: 2,
        );

        final state = IncomingOrderLoaded(
          orders: const [],
          stats: stats,
        );

        expect(state.orders, isEmpty);
        expect(state.stats, stats);
        expect(state.activeFilter, isNull);
      });

      test('creates instance with activeFilter', () {
        const stats = IncomingOrderStats(
          total: 0,
          pending: 0,
          inTransit: 0,
          delivered: 0,
        );

        final state = IncomingOrderLoaded(
          orders: const [],
          stats: stats,
          activeFilter: 'pending',
        );

        expect(state.activeFilter, 'pending');
      });

      test('props contains orders, stats and activeFilter', () {
        const stats = IncomingOrderStats(
          total: 0,
          pending: 0,
          inTransit: 0,
          delivered: 0,
        );

        final state = IncomingOrderLoaded(
          orders: const [],
          stats: stats,
          activeFilter: 'all',
        );

        expect(state.props, [const [], stats, 'all']);
      });

      test('two states with same props are equal', () {
        const stats = IncomingOrderStats(
          total: 0,
          pending: 0,
          inTransit: 0,
          delivered: 0,
        );

        final state1 = IncomingOrderLoaded(
          orders: const [],
          stats: stats,
        );
        final state2 = IncomingOrderLoaded(
          orders: const [],
          stats: stats,
        );

        expect(state1, equals(state2));
      });
    });

    group('IncomingOrderDetailsLoaded', () {
      test('creates instance with order', () {
        final order = IncomingOrder(
          id: '1',
          orderNumber: 'ORD001',
          status: 'pending',
          statusLabel: 'En attente',
          senderName: 'John',
          senderPhone: '70123456',
          dropoffAddress: 'Address B',
          dropoffLatitude: 12.3,
          dropoffLongitude: -1.5,
          packageSize: 'small',
          totalPrice: 1500.0,
          recipientConfirmed: false,
          createdAt: DateTime(2024, 1, 15),
        );

        final state = IncomingOrderDetailsLoaded(order);

        expect(state.order, order);
      });

      test('props contains order', () {
        final order = IncomingOrder(
          id: '1',
          orderNumber: 'ORD001',
          status: 'pending',
          statusLabel: 'En attente',
          senderName: 'John',
          senderPhone: '70123456',
          dropoffAddress: 'Address B',
          dropoffLatitude: 12.3,
          dropoffLongitude: -1.5,
          packageSize: 'small',
          totalPrice: 1500.0,
          recipientConfirmed: false,
          createdAt: DateTime(2024, 1, 15),
        );

        final state = IncomingOrderDetailsLoaded(order);

        expect(state.props, [order]);
      });
    });

    group('IncomingOrderTrackingLoaded', () {
      test('creates instance with all fields', () {
        const state = IncomingOrderTrackingLoaded(
          orderId: 'order1',
          orderNumber: 'ORD001',
          status: 'in_transit',
          statusLabel: 'En cours',
          courier: {'name': 'Jean', 'phone': '70000000'},
          destination: {'lat': 12.3, 'lng': -1.5},
          etaMinutes: 15,
          etaText: '15 min',
        );

        expect(state.orderId, 'order1');
        expect(state.orderNumber, 'ORD001');
        expect(state.status, 'in_transit');
        expect(state.statusLabel, 'En cours');
        expect(state.courier['name'], 'Jean');
        expect(state.destination['lat'], 12.3);
        expect(state.etaMinutes, 15);
        expect(state.etaText, '15 min');
      });

      test('etaMinutes can be null', () {
        const state = IncomingOrderTrackingLoaded(
          orderId: 'order1',
          orderNumber: 'ORD001',
          status: 'pending',
          statusLabel: 'En attente',
          courier: {},
          destination: {},
          etaMinutes: null,
          etaText: '-',
        );

        expect(state.etaMinutes, isNull);
      });

      test('props contains key tracking fields', () {
        const state = IncomingOrderTrackingLoaded(
          orderId: 'order1',
          orderNumber: 'ORD001',
          status: 'in_transit',
          statusLabel: 'En cours',
          courier: {'name': 'Jean'},
          destination: {'lat': 12.3},
          etaMinutes: 15,
          etaText: '15 min',
        );

        expect(state.props, [
          'order1',
          'ORD001',
          'in_transit',
          {'name': 'Jean'},
          {'lat': 12.3},
          15,
        ]);
      });

      test('two states with same props are equal', () {
        const state1 = IncomingOrderTrackingLoaded(
          orderId: 'order1',
          orderNumber: 'ORD001',
          status: 'in_transit',
          statusLabel: 'En cours',
          courier: {},
          destination: {},
          etaMinutes: 15,
          etaText: '15 min',
        );
        const state2 = IncomingOrderTrackingLoaded(
          orderId: 'order1',
          orderNumber: 'ORD001',
          status: 'in_transit',
          statusLabel: 'En cours',
          courier: {},
          destination: {},
          etaMinutes: 15,
          etaText: '15 min',
        );

        expect(state1, equals(state2));
      });
    });

    group('IncomingOrderReceiptConfirmed', () {
      test('creates instance with message', () {
        const state = IncomingOrderReceiptConfirmed('Réception confirmée');
        expect(state.message, 'Réception confirmée');
      });

      test('props contains message', () {
        const state = IncomingOrderReceiptConfirmed('Success');
        expect(state.props, ['Success']);
      });

      test('two states with same message are equal', () {
        const state1 = IncomingOrderReceiptConfirmed('OK');
        const state2 = IncomingOrderReceiptConfirmed('OK');
        expect(state1, equals(state2));
      });

      test('two states with different messages are not equal', () {
        const state1 = IncomingOrderReceiptConfirmed('OK');
        const state2 = IncomingOrderReceiptConfirmed('Confirmed');
        expect(state1, isNot(equals(state2)));
      });
    });

    group('IncomingOrderError', () {
      test('creates instance with message', () {
        const state = IncomingOrderError('Une erreur est survenue');
        expect(state.message, 'Une erreur est survenue');
      });

      test('props contains message', () {
        const state = IncomingOrderError('Erreur');
        expect(state.props, ['Erreur']);
      });

      test('two states with same message are equal', () {
        const state1 = IncomingOrderError('Error');
        const state2 = IncomingOrderError('Error');
        expect(state1, equals(state2));
      });

      test('two states with different messages are not equal', () {
        const state1 = IncomingOrderError('Error 1');
        const state2 = IncomingOrderError('Error 2');
        expect(state1, isNot(equals(state2)));
      });

      test('is instance of IncomingOrderState', () {
        const state = IncomingOrderError('Test');
        expect(state, isA<IncomingOrderState>());
      });
    });
  });
}
