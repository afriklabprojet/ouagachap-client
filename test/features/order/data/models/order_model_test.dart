import 'package:flutter_test/flutter_test.dart';
import 'package:ouaga_chap_client/features/order/data/models/order_model.dart';
import 'package:ouaga_chap_client/features/order/domain/entities/order.dart';

void main() {
  group('OrderModel', () {
    group('fromJson', () {
      test('should create OrderModel from complete JSON', () {
        // Arrange
        final json = {
          'id': 1,
          'tracking_number': 'OCH-001',
          'pickup_address': '123 Rue A',
          'pickup_latitude': 12.3456,
          'pickup_longitude': -1.2345,
          'pickup_contact_name': 'Jean',
          'pickup_contact_phone': '+22670000000',
          'delivery_address': '456 Rue B',
          'delivery_latitude': 12.4567,
          'delivery_longitude': -1.3456,
          'recipient_name': 'Marie',
          'recipient_phone': '+22671234567',
          'package_description': 'Documents',
          'package_size': 'small',
          'distance': 5.5,
          'price': 2500.0,
          'status': 'pending',
          'created_at': '2024-01-15T10:30:00.000Z',
        };

        // Act
        final order = OrderModel.fromJson(json);

        // Assert
        expect(order.id, equals(1));
        expect(order.trackingNumber, equals('OCH-001'));
        expect(order.pickupAddress, equals('123 Rue A'));
        expect(order.pickupLatitude, equals(12.3456));
        expect(order.deliveryAddress, equals('456 Rue B'));
        expect(order.recipientName, equals('Marie'));
        expect(order.distance, equals(5.5));
        expect(order.price, equals(2500.0));
        expect(order.status, equals(OrderStatus.pending));
      });

      test('should handle all status values', () {
        final statuses = {
          'pending': OrderStatus.pending,
          'accepted': OrderStatus.accepted,
          'pickingUp': OrderStatus.pickingUp,
          'inTransit': OrderStatus.inTransit,
          'delivered': OrderStatus.delivered,
          'cancelled': OrderStatus.cancelled,
        };

        for (final entry in statuses.entries) {
          final json = {
            'id': 1,
            'pickup_address': 'A',
            'pickup_latitude': 0.0,
            'pickup_longitude': 0.0,
            'delivery_address': 'B',
            'delivery_latitude': 0.0,
            'delivery_longitude': 0.0,
            'recipient_name': 'Test',
            'recipient_phone': '+226',
            'distance': 1.0,
            'price': 1000.0,
            'status': entry.key,
            'created_at': '2024-01-15T10:30:00.000Z',
          };

          final order = OrderModel.fromJson(json);
          expect(order.status, equals(entry.value));
        }
      });

      test('should parse coordinates from different types', () {
        // Test with string values
        final jsonString = {
          'id': 1,
          'pickup_address': 'A',
          'pickup_latitude': '12.3456',
          'pickup_longitude': '-1.2345',
          'delivery_address': 'B',
          'delivery_latitude': '12.4567',
          'delivery_longitude': '-1.3456',
          'recipient_name': 'Test',
          'recipient_phone': '+226',
          'distance': '5.5',
          'price': '2500',
          'status': 'pending',
          'created_at': '2024-01-15T10:30:00.000Z',
        };

        final order = OrderModel.fromJson(jsonString);
        expect(order.pickupLatitude, equals(12.3456));
        expect(order.price, equals(2500.0));
      });

      test('should handle integer coordinates', () {
        final json = {
          'id': 1,
          'pickup_address': 'A',
          'pickup_latitude': 12,
          'pickup_longitude': -1,
          'delivery_address': 'B',
          'delivery_latitude': 13,
          'delivery_longitude': -2,
          'recipient_name': 'Test',
          'recipient_phone': '+226',
          'distance': 5,
          'price': 2500,
          'status': 'pending',
          'created_at': '2024-01-15T10:30:00.000Z',
        };

        final order = OrderModel.fromJson(json);
        expect(order.pickupLatitude, equals(12.0));
        expect(order.price, equals(2500.0));
      });

      test('should handle null optional fields', () {
        final json = {
          'id': 1,
          'pickup_address': 'A',
          'pickup_latitude': 0.0,
          'pickup_longitude': 0.0,
          'delivery_address': 'B',
          'delivery_latitude': 0.0,
          'delivery_longitude': 0.0,
          'recipient_name': 'Test',
          'recipient_phone': '+226',
          'distance': 1.0,
          'price': 1000.0,
          'status': 'pending',
          'created_at': '2024-01-15T10:30:00.000Z',
        };

        final order = OrderModel.fromJson(json);
        expect(order.pickupContactName, isNull);
        expect(order.pickupContactPhone, isNull);
        expect(order.packageDescription, isNull);
        expect(order.courier, isNull);
      });

      test('should parse courier when present', () {
        final json = {
          'id': 1,
          'pickup_address': 'A',
          'pickup_latitude': 0.0,
          'pickup_longitude': 0.0,
          'delivery_address': 'B',
          'delivery_latitude': 0.0,
          'delivery_longitude': 0.0,
          'recipient_name': 'Test',
          'recipient_phone': '+226',
          'distance': 1.0,
          'price': 1000.0,
          'status': 'inTransit',
          'created_at': '2024-01-15T10:30:00.000Z',
          'courier': {
            'id': 5,
            'name': 'Kofi',
            'phone': '+22675555555',
          },
        };

        final order = OrderModel.fromJson(json);
        expect(order.courier, isNotNull);
        expect(order.courier!.name, equals('Kofi'));
      });

      test('should handle missing tracking number', () {
        final json = {
          'id': 1,
          'pickup_address': 'A',
          'pickup_latitude': 0.0,
          'pickup_longitude': 0.0,
          'delivery_address': 'B',
          'delivery_latitude': 0.0,
          'delivery_longitude': 0.0,
          'recipient_name': 'Test',
          'recipient_phone': '+226',
          'distance': 1.0,
          'price': 1000.0,
          'status': 'pending',
          'created_at': '2024-01-15T10:30:00.000Z',
        };

        final order = OrderModel.fromJson(json);
        expect(order.trackingNumber, equals(''));
      });
    });

    group('toJson', () {
      test('should convert OrderModel to JSON', () {
        final order = OrderModel(
          id: 1,
          trackingNumber: 'OCH-001',
          pickupAddress: '123 Rue A',
          pickupLatitude: 12.3456,
          pickupLongitude: -1.2345,
          deliveryAddress: '456 Rue B',
          deliveryLatitude: 12.4567,
          deliveryLongitude: -1.3456,
          recipientName: 'Marie',
          recipientPhone: '+22671234567',
          distance: 5.5,
          price: 2500.0,
          status: OrderStatus.pending,
          createdAt: DateTime(2024, 1, 15, 10, 30),
        );

        final json = order.toJson();

        expect(json['id'], equals(1));
        expect(json['tracking_number'], equals('OCH-001'));
        expect(json['pickup_address'], equals('123 Rue A'));
        expect(json['status'], equals('pending'));
        expect(json['price'], equals(2500.0));
      });
    });

    group('Inheritance', () {
      test('OrderModel should extend Order', () {
        final order = OrderModel(
          id: 1,
          trackingNumber: 'OCH-001',
          pickupAddress: 'A',
          pickupLatitude: 0,
          pickupLongitude: 0,
          deliveryAddress: 'B',
          deliveryLatitude: 0,
          deliveryLongitude: 0,
          recipientName: 'Test',
          recipientPhone: '+226',
          distance: 1,
          price: 1000,
          status: OrderStatus.pending,
          createdAt: DateTime.now(),
        );

        expect(order, isA<Order>());
      });

      test('should inherit canCancel property', () {
        final pendingOrder = OrderModel(
          id: 1,
          trackingNumber: 'OCH-001',
          pickupAddress: 'A',
          pickupLatitude: 0,
          pickupLongitude: 0,
          deliveryAddress: 'B',
          deliveryLatitude: 0,
          deliveryLongitude: 0,
          recipientName: 'Test',
          recipientPhone: '+226',
          distance: 1,
          price: 1000,
          status: OrderStatus.pending,
          createdAt: DateTime.now(),
        );

        final deliveredOrder = OrderModel(
          id: 2,
          trackingNumber: 'OCH-002',
          pickupAddress: 'A',
          pickupLatitude: 0,
          pickupLongitude: 0,
          deliveryAddress: 'B',
          deliveryLatitude: 0,
          deliveryLongitude: 0,
          recipientName: 'Test',
          recipientPhone: '+226',
          distance: 1,
          price: 1000,
          status: OrderStatus.delivered,
          createdAt: DateTime.now(),
        );

        expect(pendingOrder.canCancel, isTrue);
        expect(deliveredOrder.canCancel, isFalse);
      });

      test('should inherit statusLabel property', () {
        final order = OrderModel(
          id: 1,
          trackingNumber: 'OCH-001',
          pickupAddress: 'A',
          pickupLatitude: 0,
          pickupLongitude: 0,
          deliveryAddress: 'B',
          deliveryLatitude: 0,
          deliveryLongitude: 0,
          recipientName: 'Test',
          recipientPhone: '+226',
          distance: 1,
          price: 1000,
          status: OrderStatus.inTransit,
          createdAt: DateTime.now(),
        );

        expect(order.statusLabel, equals('En cours'));
      });
    });
  });

  group('CourierModel._parseDouble edge cases', () {
    test('parses int value as double for coordinates', () {
      final json = {
        'id': 1,
        'name': 'Courier',
        'phone': '+226',
        'current_latitude': 12, // int value
        'current_longitude': -1, // int value
      };

      final courier = CourierModel.fromJson(json);

      expect(courier.currentLatitude, equals(12.0));
      expect(courier.currentLongitude, equals(-1.0));
      expect(courier.currentLatitude, isA<double>());
    });

    test('parses String value as double for coordinates', () {
      final json = {
        'id': 1,
        'name': 'Courier',
        'phone': '+226',
        'current_latitude': '12.345', // String value
        'current_longitude': '-1.234', // String value
      };

      final courier = CourierModel.fromJson(json);

      expect(courier.currentLatitude, equals(12.345));
      expect(courier.currentLongitude, equals(-1.234));
    });

    test('parses rating as int to double', () {
      final json = {
        'id': 1,
        'name': 'Courier',
        'phone': '+226',
        'rating': 4, // int value
      };

      final courier = CourierModel.fromJson(json);

      expect(courier.rating, equals(4.0));
    });

    test('parses rating as String to double', () {
      final json = {
        'id': 1,
        'name': 'Courier',
        'phone': '+226',
        'rating': '4.5', // String value
      };

      final courier = CourierModel.fromJson(json);

      expect(courier.rating, equals(4.5));
    });

    test('returns null for invalid String coordinate', () {
      final json = {
        'id': 1,
        'name': 'Courier',
        'phone': '+226',
        'current_latitude': 'invalid', // invalid String
      };

      final courier = CourierModel.fromJson(json);

      expect(courier.currentLatitude, isNull);
    });
  });
}
