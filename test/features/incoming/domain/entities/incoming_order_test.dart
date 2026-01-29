import 'package:flutter_test/flutter_test.dart';
import 'package:ouaga_chap_client/features/incoming/domain/entities/incoming_order.dart';

void main() {
  group('IncomingOrder', () {
    final testDate = DateTime(2024, 1, 15, 10, 30);
    final deliveredDate = DateTime(2024, 1, 15, 14, 30);

    final testOrder = IncomingOrder(
      id: 'order-123',
      orderNumber: 'ORD-001',
      status: 'pending',
      statusLabel: 'En attente',
      senderName: 'John Sender',
      senderPhone: '+22670000000',
      dropoffAddress: '123 Rue de Livraison',
      dropoffLatitude: 12.3456,
      dropoffLongitude: -1.5432,
      packageDescription: 'Petit colis',
      packageSize: 'small',
      totalPrice: 1500.0,
      recipientConfirmed: false,
      createdAt: testDate,
    );

    group('constructor', () {
      test('should create IncomingOrder with required fields', () {
        expect(testOrder.id, 'order-123');
        expect(testOrder.orderNumber, 'ORD-001');
        expect(testOrder.status, 'pending');
        expect(testOrder.statusLabel, 'En attente');
        expect(testOrder.senderName, 'John Sender');
        expect(testOrder.senderPhone, '+22670000000');
        expect(testOrder.dropoffAddress, '123 Rue de Livraison');
        expect(testOrder.dropoffLatitude, 12.3456);
        expect(testOrder.dropoffLongitude, -1.5432);
        expect(testOrder.totalPrice, 1500.0);
        expect(testOrder.recipientConfirmed, false);
      });

      test('should create IncomingOrder with optional fields', () {
        final orderWithCourier = IncomingOrder(
          id: 'order-456',
          orderNumber: 'ORD-002',
          status: 'picked_up',
          statusLabel: 'En cours de livraison',
          senderName: 'Jane Sender',
          senderPhone: '+22670000001',
          dropoffAddress: '456 Avenue Test',
          dropoffLatitude: 12.4567,
          dropoffLongitude: -1.6543,
          packageSize: 'medium',
          courier: const IncomingOrderCourier(
            id: 'courier-1',
            name: 'Courier Name',
            phone: '+22670111111',
          ),
          totalPrice: 2500.0,
          confirmationCode: 'ABC123',
          recipientConfirmed: true,
          createdAt: testDate,
          deliveredAt: deliveredDate,
        );

        expect(orderWithCourier.courier, isNotNull);
        expect(orderWithCourier.courier!.name, 'Courier Name');
        expect(orderWithCourier.confirmationCode, 'ABC123');
        expect(orderWithCourier.deliveredAt, deliveredDate);
      });
    });

    group('status getters', () {
      test('isPending should return true when status is pending', () {
        expect(testOrder.isPending, true);
        expect(testOrder.isInTransit, false);
        expect(testOrder.isDelivered, false);
      });

      test('isInTransit should return true when status is accepted', () {
        final order = IncomingOrder(
          id: '1',
          orderNumber: 'ORD',
          status: 'accepted',
          statusLabel: 'Accepté',
          senderName: 'Sender',
          senderPhone: '123',
          dropoffAddress: 'Addr',
          dropoffLatitude: 12.0,
          dropoffLongitude: -1.0,
          packageSize: 'small',
          totalPrice: 1000,
          recipientConfirmed: false,
          createdAt: testDate,
        );
        
        expect(order.isInTransit, true);
        expect(order.isPending, false);
      });

      test('isInTransit should return true when status is picked_up', () {
        final order = IncomingOrder(
          id: '1',
          orderNumber: 'ORD',
          status: 'picked_up',
          statusLabel: 'En livraison',
          senderName: 'Sender',
          senderPhone: '123',
          dropoffAddress: 'Addr',
          dropoffLatitude: 12.0,
          dropoffLongitude: -1.0,
          packageSize: 'small',
          totalPrice: 1000,
          recipientConfirmed: false,
          createdAt: testDate,
        );
        
        expect(order.isInTransit, true);
      });

      test('isDelivered should return true when status is delivered', () {
        final order = IncomingOrder(
          id: '1',
          orderNumber: 'ORD',
          status: 'delivered',
          statusLabel: 'Livré',
          senderName: 'Sender',
          senderPhone: '123',
          dropoffAddress: 'Addr',
          dropoffLatitude: 12.0,
          dropoffLongitude: -1.0,
          packageSize: 'small',
          totalPrice: 1000,
          recipientConfirmed: true,
          createdAt: testDate,
          deliveredAt: deliveredDate,
        );
        
        expect(order.isDelivered, true);
        expect(order.isInTransit, false);
      });
    });

    group('canTrack', () {
      test('should return true when isInTransit', () {
        final order = IncomingOrder(
          id: '1',
          orderNumber: 'ORD',
          status: 'picked_up',
          statusLabel: 'En livraison',
          senderName: 'Sender',
          senderPhone: '123',
          dropoffAddress: 'Addr',
          dropoffLatitude: 12.0,
          dropoffLongitude: -1.0,
          packageSize: 'small',
          totalPrice: 1000,
          recipientConfirmed: false,
          createdAt: testDate,
        );
        
        expect(order.canTrack, true);
      });

      test('should return false when pending', () {
        expect(testOrder.canTrack, false);
      });

      test('should return false when delivered', () {
        final order = IncomingOrder(
          id: '1',
          orderNumber: 'ORD',
          status: 'delivered',
          statusLabel: 'Livré',
          senderName: 'Sender',
          senderPhone: '123',
          dropoffAddress: 'Addr',
          dropoffLatitude: 12.0,
          dropoffLongitude: -1.0,
          packageSize: 'small',
          totalPrice: 1000,
          recipientConfirmed: true,
          createdAt: testDate,
        );
        
        expect(order.canTrack, false);
      });
    });

    group('fromJson', () {
      test('should create IncomingOrder from complete JSON', () {
        final json = {
          'id': 'json-order-1',
          'order_number': 'ORD-JSON-001',
          'status': 'pending',
          'status_label': 'En attente',
          'pickup_contact_name': 'JSON Sender',
          'pickup_contact_phone': '+22670333333',
          'dropoff_address': 'JSON Address',
          'dropoff_latitude': 12.789,
          'dropoff_longitude': -1.234,
          'package_description': 'Description',
          'package_size': 'large',
          'total_price': 3000,
          'recipient_confirmation_code': 'XYZ789',
          'recipient_confirmed': true,
          'created_at': '2024-01-15T10:30:00.000Z',
          'delivered_at': '2024-01-15T14:30:00.000Z',
        };

        final order = IncomingOrder.fromJson(json);

        expect(order.id, 'json-order-1');
        expect(order.orderNumber, 'ORD-JSON-001');
        expect(order.senderName, 'JSON Sender');
        expect(order.senderPhone, '+22670333333');
        expect(order.packageSize, 'large');
        expect(order.totalPrice, 3000.0);
        expect(order.confirmationCode, 'XYZ789');
        expect(order.recipientConfirmed, true);
        expect(order.deliveredAt, isNotNull);
      });

      test('should parse courier from JSON', () {
        final json = {
          'id': 'order-1',
          'order_number': 'ORD-001',
          'status': 'picked_up',
          'dropoff_address': 'Addr',
          'dropoff_latitude': 12.0,
          'dropoff_longitude': -1.0,
          'total_price': 1500,
          'created_at': '2024-01-15T10:30:00.000Z',
          'courier': {
            'id': 123,
            'name': 'Courier Name',
            'phone': '+22670444444',
            'vehicle_type': 'moto',
            'current_latitude': 12.111,
            'current_longitude': -1.222,
          },
        };

        final order = IncomingOrder.fromJson(json);

        expect(order.courier, isNotNull);
        expect(order.courier!.id, '123');
        expect(order.courier!.name, 'Courier Name');
        expect(order.courier!.vehicleType, 'moto');
        expect(order.courier!.latitude, 12.111);
        expect(order.courier!.longitude, -1.222);
      });

      test('should handle missing optional fields', () {
        final json = {
          'id': 'order-1',
          'order_number': 'ORD-001',
          'status': 'pending',
          'dropoff_address': 'Addr',
          'dropoff_latitude': 12.0,
          'dropoff_longitude': -1.0,
          'total_price': 1000,
          'created_at': '2024-01-15T10:30:00.000Z',
        };

        final order = IncomingOrder.fromJson(json);

        expect(order.senderName, 'Expéditeur');
        expect(order.senderPhone, '');
        expect(order.packageDescription, isNull);
        expect(order.packageSize, 'small');
        expect(order.courier, isNull);
        expect(order.confirmationCode, isNull);
        expect(order.recipientConfirmed, false);
        expect(order.deliveredAt, isNull);
      });

      test('should generate statusLabel from status if not provided', () {
        final jsonPending = {
          'id': '1',
          'order_number': 'ORD',
          'status': 'pending',
          'dropoff_address': 'Addr',
          'dropoff_latitude': 12.0,
          'dropoff_longitude': -1.0,
          'total_price': 1000,
          'created_at': '2024-01-15T10:30:00.000Z',
        };

        final order = IncomingOrder.fromJson(jsonPending);
        expect(order.statusLabel, 'En attente');
      });

      test('should generate statusLabel for accepted status', () {
        final json = {
          'id': '1',
          'order_number': 'ORD',
          'status': 'accepted',
          'dropoff_address': 'Addr',
          'dropoff_latitude': 12.0,
          'dropoff_longitude': -1.0,
          'total_price': 1000,
          'created_at': '2024-01-15T10:30:00.000Z',
        };

        final order = IncomingOrder.fromJson(json);
        expect(order.statusLabel, 'Coursier en route vers expéditeur');
      });

      test('should generate statusLabel for picked_up status', () {
        final json = {
          'id': '1',
          'order_number': 'ORD',
          'status': 'picked_up',
          'dropoff_address': 'Addr',
          'dropoff_latitude': 12.0,
          'dropoff_longitude': -1.0,
          'total_price': 1000,
          'created_at': '2024-01-15T10:30:00.000Z',
        };

        final order = IncomingOrder.fromJson(json);
        expect(order.statusLabel, 'En cours de livraison');
      });

      test('should generate statusLabel for delivered status', () {
        final json = {
          'id': '1',
          'order_number': 'ORD',
          'status': 'delivered',
          'dropoff_address': 'Addr',
          'dropoff_latitude': 12.0,
          'dropoff_longitude': -1.0,
          'total_price': 1000,
          'created_at': '2024-01-15T10:30:00.000Z',
        };

        final order = IncomingOrder.fromJson(json);
        expect(order.statusLabel, 'Livré');
      });

      test('should generate statusLabel for cancelled status', () {
        final json = {
          'id': '1',
          'order_number': 'ORD',
          'status': 'cancelled',
          'dropoff_address': 'Addr',
          'dropoff_latitude': 12.0,
          'dropoff_longitude': -1.0,
          'total_price': 1000,
          'created_at': '2024-01-15T10:30:00.000Z',
        };

        final order = IncomingOrder.fromJson(json);
        expect(order.statusLabel, 'Annulé');
      });

      test('should use status as statusLabel for unknown status', () {
        final json = {
          'id': '1',
          'order_number': 'ORD',
          'status': 'unknown_status',
          'dropoff_address': 'Addr',
          'dropoff_latitude': 12.0,
          'dropoff_longitude': -1.0,
          'total_price': 1000,
          'created_at': '2024-01-15T10:30:00.000Z',
        };

        final order = IncomingOrder.fromJson(json);
        expect(order.statusLabel, 'unknown_status');
      });
    });

    group('Equatable', () {
      test('props should contain key fields', () {
        expect(testOrder.props.length, 9);
        expect(testOrder.props, contains('order-123'));
        expect(testOrder.props, contains('ORD-001'));
        expect(testOrder.props, contains('pending'));
      });

      test('two orders with same key props should be equal', () {
        final order1 = IncomingOrder(
          id: 'order-1',
          orderNumber: 'ORD-001',
          status: 'pending',
          statusLabel: 'En attente',
          senderName: 'Sender 1',
          senderPhone: '123',
          dropoffAddress: 'Addr 1',
          dropoffLatitude: 12.0,
          dropoffLongitude: -1.0,
          packageSize: 'small',
          totalPrice: 1000,
          recipientConfirmed: false,
          createdAt: testDate,
        );
        
        final order2 = IncomingOrder(
          id: 'order-1',
          orderNumber: 'ORD-001',
          status: 'pending',
          statusLabel: 'Different label',
          senderName: 'Sender 1',
          senderPhone: 'Different phone',
          dropoffAddress: 'Addr 1',
          dropoffLatitude: 99.0,
          dropoffLongitude: -99.0,
          packageSize: 'large',
          totalPrice: 1000,
          recipientConfirmed: false,
          createdAt: testDate,
        );
        
        expect(order1, equals(order2));
      });
    });
  });

  group('IncomingOrderCourier', () {
    group('constructor', () {
      test('should create IncomingOrderCourier with required fields', () {
        const courier = IncomingOrderCourier(
          id: 'courier-1',
          name: 'John Courier',
          phone: '+22670555555',
        );

        expect(courier.id, 'courier-1');
        expect(courier.name, 'John Courier');
        expect(courier.phone, '+22670555555');
        expect(courier.vehicleType, isNull);
        expect(courier.latitude, isNull);
        expect(courier.longitude, isNull);
      });

      test('should create IncomingOrderCourier with all fields', () {
        const courier = IncomingOrderCourier(
          id: 'courier-2',
          name: 'Jane Courier',
          phone: '+22670666666',
          vehicleType: 'moto',
          latitude: 12.345,
          longitude: -1.234,
        );

        expect(courier.vehicleType, 'moto');
        expect(courier.latitude, 12.345);
        expect(courier.longitude, -1.234);
      });
    });

    group('hasLocation', () {
      test('should return true when both latitude and longitude are set', () {
        const courier = IncomingOrderCourier(
          id: '1',
          name: 'Courier',
          phone: '123',
          latitude: 12.0,
          longitude: -1.0,
        );
        
        expect(courier.hasLocation, true);
      });

      test('should return false when latitude is null', () {
        const courier = IncomingOrderCourier(
          id: '1',
          name: 'Courier',
          phone: '123',
          longitude: -1.0,
        );
        
        expect(courier.hasLocation, false);
      });

      test('should return false when longitude is null', () {
        const courier = IncomingOrderCourier(
          id: '1',
          name: 'Courier',
          phone: '123',
          latitude: 12.0,
        );
        
        expect(courier.hasLocation, false);
      });

      test('should return false when both are null', () {
        const courier = IncomingOrderCourier(
          id: '1',
          name: 'Courier',
          phone: '123',
        );
        
        expect(courier.hasLocation, false);
      });
    });

    group('fromJson', () {
      test('should create from complete JSON', () {
        final json = {
          'id': 456,
          'name': 'JSON Courier',
          'phone': '+22670777777',
          'vehicle_type': 'car',
          'current_latitude': 12.999,
          'current_longitude': -1.888,
        };

        final courier = IncomingOrderCourier.fromJson(json);

        expect(courier.id, '456');
        expect(courier.name, 'JSON Courier');
        expect(courier.phone, '+22670777777');
        expect(courier.vehicleType, 'car');
        expect(courier.latitude, 12.999);
        expect(courier.longitude, -1.888);
      });

      test('should handle missing optional fields', () {
        final json = {
          'id': 789,
        };

        final courier = IncomingOrderCourier.fromJson(json);

        expect(courier.id, '789');
        expect(courier.name, 'Coursier');
        expect(courier.phone, '');
        expect(courier.vehicleType, isNull);
        expect(courier.latitude, isNull);
        expect(courier.longitude, isNull);
      });
    });

    group('Equatable', () {
      test('props should contain all fields', () {
        const courier = IncomingOrderCourier(
          id: '1',
          name: 'Courier',
          phone: '123',
          vehicleType: 'moto',
          latitude: 12.0,
          longitude: -1.0,
        );

        expect(courier.props, ['1', 'Courier', '123', 'moto', 12.0, -1.0]);
      });
    });
  });

  group('IncomingOrderStats', () {
    group('constructor', () {
      test('should create IncomingOrderStats', () {
        const stats = IncomingOrderStats(
          pending: 5,
          inTransit: 3,
          delivered: 10,
          total: 18,
        );

        expect(stats.pending, 5);
        expect(stats.inTransit, 3);
        expect(stats.delivered, 10);
        expect(stats.total, 18);
      });
    });

    group('fromJson', () {
      test('should create from JSON', () {
        final json = {
          'pending': 2,
          'in_transit': 4,
          'delivered': 15,
          'total': 21,
        };

        final stats = IncomingOrderStats.fromJson(json);

        expect(stats.pending, 2);
        expect(stats.inTransit, 4);
        expect(stats.delivered, 15);
        expect(stats.total, 21);
      });

      test('should handle missing values with defaults', () {
        final json = <String, dynamic>{};

        final stats = IncomingOrderStats.fromJson(json);

        expect(stats.pending, 0);
        expect(stats.inTransit, 0);
        expect(stats.delivered, 0);
        expect(stats.total, 0);
      });
    });

    group('Equatable', () {
      test('props should contain all stats', () {
        const stats = IncomingOrderStats(
          pending: 1,
          inTransit: 2,
          delivered: 3,
          total: 6,
        );

        expect(stats.props, [1, 2, 3, 6]);
      });
    });
  });
}
