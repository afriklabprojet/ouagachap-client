import 'package:flutter_test/flutter_test.dart';
import 'package:ouaga_chap_client/features/order/domain/entities/order.dart';

void main() {
  group('Order Entity', () {
    late Order order;
    late DateTime createdAt;

    setUp(() {
      createdAt = DateTime(2024, 1, 15, 10, 30);
      order = Order(
        id: 1,
        trackingNumber: 'TRK-001',
        pickupAddress: '123 Rue de Test',
        pickupLatitude: 12.3456,
        pickupLongitude: -1.2345,
        pickupContactName: 'Expéditeur',
        pickupContactPhone: '70111111',
        deliveryAddress: '456 Rue Livraison',
        deliveryLatitude: 12.4567,
        deliveryLongitude: -1.3456,
        recipientName: 'Destinataire',
        recipientPhone: '70222222',
        packageDescription: 'Colis fragile',
        packageSize: 'medium',
        distance: 5.5,
        price: 2500,
        status: OrderStatus.pending,
        createdAt: createdAt,
      );
    });

    group('Constructor', () {
      test('creates order with required fields', () {
        final minimalOrder = Order(
          id: 1,
          trackingNumber: 'TRK-001',
          pickupAddress: 'Pickup',
          pickupLatitude: 0,
          pickupLongitude: 0,
          deliveryAddress: 'Delivery',
          deliveryLatitude: 0,
          deliveryLongitude: 0,
          recipientName: 'Recipient',
          recipientPhone: '70000000',
          distance: 1.0,
          price: 1000,
          status: OrderStatus.pending,
          createdAt: createdAt,
        );

        expect(minimalOrder.id, 1);
        expect(minimalOrder.trackingNumber, 'TRK-001');
        expect(minimalOrder.pickupContactName, isNull);
        expect(minimalOrder.packageDescription, isNull);
        expect(minimalOrder.courier, isNull);
      });

      test('creates order with all fields', () {
        expect(order.id, 1);
        expect(order.trackingNumber, 'TRK-001');
        expect(order.pickupAddress, '123 Rue de Test');
        expect(order.pickupLatitude, 12.3456);
        expect(order.pickupLongitude, -1.2345);
        expect(order.pickupContactName, 'Expéditeur');
        expect(order.pickupContactPhone, '70111111');
        expect(order.deliveryAddress, '456 Rue Livraison');
        expect(order.recipientName, 'Destinataire');
        expect(order.recipientPhone, '70222222');
        expect(order.packageDescription, 'Colis fragile');
        expect(order.packageSize, 'medium');
        expect(order.distance, 5.5);
        expect(order.price, 2500);
        expect(order.status, OrderStatus.pending);
        expect(order.createdAt, createdAt);
      });
    });

    group('OrderStatus', () {
      test('all statuses are defined', () {
        expect(OrderStatus.values.length, 6);
        expect(OrderStatus.values, contains(OrderStatus.pending));
        expect(OrderStatus.values, contains(OrderStatus.accepted));
        expect(OrderStatus.values, contains(OrderStatus.pickingUp));
        expect(OrderStatus.values, contains(OrderStatus.inTransit));
        expect(OrderStatus.values, contains(OrderStatus.delivered));
        expect(OrderStatus.values, contains(OrderStatus.cancelled));
      });
    });

    group('statusLabel', () {
      test('returns correct label for pending', () {
        expect(order.statusLabel, 'En attente');
      });

      test('returns correct label for accepted', () {
        final acceptedOrder = Order(
          id: 1,
          trackingNumber: 'TRK',
          pickupAddress: 'A',
          pickupLatitude: 0,
          pickupLongitude: 0,
          deliveryAddress: 'B',
          deliveryLatitude: 0,
          deliveryLongitude: 0,
          recipientName: 'R',
          recipientPhone: '70000000',
          distance: 1,
          price: 1000,
          status: OrderStatus.accepted,
          createdAt: createdAt,
        );
        expect(acceptedOrder.statusLabel, 'Acceptée');
      });

      test('returns correct label for pickingUp', () {
        final pickingUpOrder = Order(
          id: 1,
          trackingNumber: 'TRK',
          pickupAddress: 'A',
          pickupLatitude: 0,
          pickupLongitude: 0,
          deliveryAddress: 'B',
          deliveryLatitude: 0,
          deliveryLongitude: 0,
          recipientName: 'R',
          recipientPhone: '70000000',
          distance: 1,
          price: 1000,
          status: OrderStatus.pickingUp,
          createdAt: createdAt,
        );
        expect(pickingUpOrder.statusLabel, 'Récupération');
      });

      test('returns correct label for inTransit', () {
        final inTransitOrder = Order(
          id: 1,
          trackingNumber: 'TRK',
          pickupAddress: 'A',
          pickupLatitude: 0,
          pickupLongitude: 0,
          deliveryAddress: 'B',
          deliveryLatitude: 0,
          deliveryLongitude: 0,
          recipientName: 'R',
          recipientPhone: '70000000',
          distance: 1,
          price: 1000,
          status: OrderStatus.inTransit,
          createdAt: createdAt,
        );
        expect(inTransitOrder.statusLabel, 'En cours');
      });

      test('returns correct label for delivered', () {
        final deliveredOrder = Order(
          id: 1,
          trackingNumber: 'TRK',
          pickupAddress: 'A',
          pickupLatitude: 0,
          pickupLongitude: 0,
          deliveryAddress: 'B',
          deliveryLatitude: 0,
          deliveryLongitude: 0,
          recipientName: 'R',
          recipientPhone: '70000000',
          distance: 1,
          price: 1000,
          status: OrderStatus.delivered,
          createdAt: createdAt,
        );
        expect(deliveredOrder.statusLabel, 'Livrée');
      });

      test('returns correct label for cancelled', () {
        final cancelledOrder = Order(
          id: 1,
          trackingNumber: 'TRK',
          pickupAddress: 'A',
          pickupLatitude: 0,
          pickupLongitude: 0,
          deliveryAddress: 'B',
          deliveryLatitude: 0,
          deliveryLongitude: 0,
          recipientName: 'R',
          recipientPhone: '70000000',
          distance: 1,
          price: 1000,
          status: OrderStatus.cancelled,
          createdAt: createdAt,
        );
        expect(cancelledOrder.statusLabel, 'Annulée');
      });
    });

    group('canCancel', () {
      test('returns true for pending orders', () {
        expect(order.canCancel, isTrue);
      });

      test('returns true for accepted orders', () {
        final acceptedOrder = Order(
          id: 1,
          trackingNumber: 'TRK',
          pickupAddress: 'A',
          pickupLatitude: 0,
          pickupLongitude: 0,
          deliveryAddress: 'B',
          deliveryLatitude: 0,
          deliveryLongitude: 0,
          recipientName: 'R',
          recipientPhone: '70000000',
          distance: 1,
          price: 1000,
          status: OrderStatus.accepted,
          createdAt: createdAt,
        );
        expect(acceptedOrder.canCancel, isTrue);
      });

      test('returns false for in transit orders', () {
        final inTransitOrder = Order(
          id: 1,
          trackingNumber: 'TRK',
          pickupAddress: 'A',
          pickupLatitude: 0,
          pickupLongitude: 0,
          deliveryAddress: 'B',
          deliveryLatitude: 0,
          deliveryLongitude: 0,
          recipientName: 'R',
          recipientPhone: '70000000',
          distance: 1,
          price: 1000,
          status: OrderStatus.inTransit,
          createdAt: createdAt,
        );
        expect(inTransitOrder.canCancel, isFalse);
      });

      test('returns false for delivered orders', () {
        final deliveredOrder = Order(
          id: 1,
          trackingNumber: 'TRK',
          pickupAddress: 'A',
          pickupLatitude: 0,
          pickupLongitude: 0,
          deliveryAddress: 'B',
          deliveryLatitude: 0,
          deliveryLongitude: 0,
          recipientName: 'R',
          recipientPhone: '70000000',
          distance: 1,
          price: 1000,
          status: OrderStatus.delivered,
          createdAt: createdAt,
        );
        expect(deliveredOrder.canCancel, isFalse);
      });

      test('returns false for cancelled orders', () {
        final cancelledOrder = Order(
          id: 1,
          trackingNumber: 'TRK',
          pickupAddress: 'A',
          pickupLatitude: 0,
          pickupLongitude: 0,
          deliveryAddress: 'B',
          deliveryLatitude: 0,
          deliveryLongitude: 0,
          recipientName: 'R',
          recipientPhone: '70000000',
          distance: 1,
          price: 1000,
          status: OrderStatus.cancelled,
          createdAt: createdAt,
        );
        expect(cancelledOrder.canCancel, isFalse);
      });
    });

    group('isActive', () {
      test('returns true for pending orders', () {
        expect(order.isActive, isTrue);
      });

      test('returns true for accepted orders', () {
        final acceptedOrder = Order(
          id: 1,
          trackingNumber: 'TRK',
          pickupAddress: 'A',
          pickupLatitude: 0,
          pickupLongitude: 0,
          deliveryAddress: 'B',
          deliveryLatitude: 0,
          deliveryLongitude: 0,
          recipientName: 'R',
          recipientPhone: '70000000',
          distance: 1,
          price: 1000,
          status: OrderStatus.accepted,
          createdAt: createdAt,
        );
        expect(acceptedOrder.isActive, isTrue);
      });

      test('returns true for in transit orders', () {
        final inTransitOrder = Order(
          id: 1,
          trackingNumber: 'TRK',
          pickupAddress: 'A',
          pickupLatitude: 0,
          pickupLongitude: 0,
          deliveryAddress: 'B',
          deliveryLatitude: 0,
          deliveryLongitude: 0,
          recipientName: 'R',
          recipientPhone: '70000000',
          distance: 1,
          price: 1000,
          status: OrderStatus.inTransit,
          createdAt: createdAt,
        );
        expect(inTransitOrder.isActive, isTrue);
      });

      test('returns false for delivered orders', () {
        final deliveredOrder = Order(
          id: 1,
          trackingNumber: 'TRK',
          pickupAddress: 'A',
          pickupLatitude: 0,
          pickupLongitude: 0,
          deliveryAddress: 'B',
          deliveryLatitude: 0,
          deliveryLongitude: 0,
          recipientName: 'R',
          recipientPhone: '70000000',
          distance: 1,
          price: 1000,
          status: OrderStatus.delivered,
          createdAt: createdAt,
        );
        expect(deliveredOrder.isActive, isFalse);
      });

      test('returns false for cancelled orders', () {
        final cancelledOrder = Order(
          id: 1,
          trackingNumber: 'TRK',
          pickupAddress: 'A',
          pickupLatitude: 0,
          pickupLongitude: 0,
          deliveryAddress: 'B',
          deliveryLatitude: 0,
          deliveryLongitude: 0,
          recipientName: 'R',
          recipientPhone: '70000000',
          distance: 1,
          price: 1000,
          status: OrderStatus.cancelled,
          createdAt: createdAt,
        );
        expect(cancelledOrder.isActive, isFalse);
      });
    });

    group('Equatable', () {
      test('orders with same data are equal', () {
        final order1 = Order(
          id: 1,
          trackingNumber: 'TRK-001',
          pickupAddress: 'A',
          pickupLatitude: 0,
          pickupLongitude: 0,
          deliveryAddress: 'B',
          deliveryLatitude: 0,
          deliveryLongitude: 0,
          recipientName: 'R',
          recipientPhone: '70000000',
          distance: 1,
          price: 1000,
          status: OrderStatus.pending,
          createdAt: createdAt,
        );

        final order2 = Order(
          id: 1,
          trackingNumber: 'TRK-001',
          pickupAddress: 'A',
          pickupLatitude: 0,
          pickupLongitude: 0,
          deliveryAddress: 'B',
          deliveryLatitude: 0,
          deliveryLongitude: 0,
          recipientName: 'R',
          recipientPhone: '70000000',
          distance: 1,
          price: 1000,
          status: OrderStatus.pending,
          createdAt: createdAt,
        );

        expect(order1, equals(order2));
      });

      test('orders with different id are not equal', () {
        final order1 = Order(
          id: 1,
          trackingNumber: 'TRK-001',
          pickupAddress: 'A',
          pickupLatitude: 0,
          pickupLongitude: 0,
          deliveryAddress: 'B',
          deliveryLatitude: 0,
          deliveryLongitude: 0,
          recipientName: 'R',
          recipientPhone: '70000000',
          distance: 1,
          price: 1000,
          status: OrderStatus.pending,
          createdAt: createdAt,
        );

        final order2 = Order(
          id: 2,
          trackingNumber: 'TRK-001',
          pickupAddress: 'A',
          pickupLatitude: 0,
          pickupLongitude: 0,
          deliveryAddress: 'B',
          deliveryLatitude: 0,
          deliveryLongitude: 0,
          recipientName: 'R',
          recipientPhone: '70000000',
          distance: 1,
          price: 1000,
          status: OrderStatus.pending,
          createdAt: createdAt,
        );

        expect(order1, isNot(equals(order2)));
      });
    });
  });

  group('Courier Entity', () {
    test('creates courier with required fields', () {
      const courier = Courier(
        id: 1,
        name: 'Ali Coursier',
        phone: '70333333',
      );

      expect(courier.id, 1);
      expect(courier.name, 'Ali Coursier');
      expect(courier.phone, '70333333');
      expect(courier.avatar, isNull);
      expect(courier.rating, isNull);
      expect(courier.vehicleType, isNull);
      expect(courier.vehiclePlate, isNull);
    });

    test('creates courier with all fields', () {
      const courier = Courier(
        id: 1,
        name: 'Ali Coursier',
        phone: '70333333',
        avatar: 'avatar.png',
        rating: 4.5,
        vehicleType: 'moto',
        vehiclePlate: 'AB-1234',
        currentLatitude: 12.345,
        currentLongitude: -1.234,
      );

      expect(courier.id, 1);
      expect(courier.name, 'Ali Coursier');
      expect(courier.phone, '70333333');
      expect(courier.avatar, 'avatar.png');
      expect(courier.rating, 4.5);
      expect(courier.vehicleType, 'moto');
      expect(courier.vehiclePlate, 'AB-1234');
      expect(courier.currentLatitude, 12.345);
      expect(courier.currentLongitude, -1.234);
    });

    test('couriers with same data are equal', () {
      const courier1 = Courier(
        id: 1,
        name: 'Test',
        phone: '70000000',
      );
      const courier2 = Courier(
        id: 1,
        name: 'Test',
        phone: '70000000',
      );

      expect(courier1, equals(courier2));
    });

    test('couriers with different id are not equal', () {
      const courier1 = Courier(
        id: 1,
        name: 'Test',
        phone: '70000000',
      );
      const courier2 = Courier(
        id: 2,
        name: 'Test',
        phone: '70000000',
      );

      expect(courier1, isNot(equals(courier2)));
    });

    test('couriers with different name are not equal', () {
      const courier1 = Courier(
        id: 1,
        name: 'Test1',
        phone: '70000000',
      );
      const courier2 = Courier(
        id: 1,
        name: 'Test2',
        phone: '70000000',
      );

      expect(courier1, isNot(equals(courier2)));
    });

    test('couriers with different phone are not equal', () {
      const courier1 = Courier(
        id: 1,
        name: 'Test',
        phone: '70000001',
      );
      const courier2 = Courier(
        id: 1,
        name: 'Test',
        phone: '70000002',
      );

      expect(courier1, isNot(equals(courier2)));
    });

    test('props contains id, name, phone', () {
      const courier = Courier(
        id: 1,
        name: 'Test',
        phone: '70000000',
      );

      expect(courier.props, [1, 'Test', '70000000']);
    });

    test('props is consistent for equality check', () {
      const courier = Courier(
        id: 1,
        name: 'Test',
        phone: '70000000',
        avatar: 'avatar.png',
        rating: 4.5,
      );

      // Props only include id, name, phone - not avatar or rating
      expect(courier.props, [1, 'Test', '70000000']);
    });
  });
}
