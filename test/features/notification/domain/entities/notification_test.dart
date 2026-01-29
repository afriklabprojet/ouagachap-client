import 'package:flutter_test/flutter_test.dart';
import 'package:ouaga_chap_client/features/notification/domain/entities/notification.dart';
import 'package:ouaga_chap_client/features/notification/data/models/notification_model.dart';

void main() {
  group('Notification', () {
    group('Constructor', () {
      test('creates instance with required fields', () {
        final notification = Notification(
          id: '1',
          title: 'Test Title',
          body: 'Test Body',
          isRead: false,
          createdAt: DateTime(2024, 1, 15),
        );

        expect(notification.id, '1');
        expect(notification.title, 'Test Title');
        expect(notification.body, 'Test Body');
        expect(notification.isRead, isFalse);
        expect(notification.createdAt, DateTime(2024, 1, 15));
        expect(notification.type, isNull);
        expect(notification.data, isNull);
      });

      test('creates instance with all fields', () {
        final notification = Notification(
          id: '1',
          title: 'Test Title',
          body: 'Test Body',
          isRead: true,
          type: 'order_update',
          createdAt: DateTime(2024, 1, 15),
          data: {'orderId': 123},
        );

        expect(notification.type, 'order_update');
        expect(notification.data, {'orderId': 123});
        expect(notification.isRead, isTrue);
      });
    });

    group('type values', () {
      test('accepts order_update type', () {
        final notification = Notification(
          id: '1',
          title: 'Order Update',
          body: 'Your order status changed',
          isRead: false,
          type: 'order_update',
          createdAt: DateTime(2024, 1, 15),
        );

        expect(notification.type, 'order_update');
      });

      test('accepts promo type', () {
        final notification = Notification(
          id: '2',
          title: 'Promotion',
          body: 'Special discount!',
          isRead: false,
          type: 'promo',
          createdAt: DateTime(2024, 1, 15),
        );

        expect(notification.type, 'promo');
      });

      test('accepts system type', () {
        final notification = Notification(
          id: '3',
          title: 'System',
          body: 'System maintenance',
          isRead: false,
          type: 'system',
          createdAt: DateTime(2024, 1, 15),
        );

        expect(notification.type, 'system');
      });
    });
  });

  group('NotificationModel', () {
    group('Constructor', () {
      test('creates instance with required fields', () {
        final model = NotificationModel(
          id: '1',
          title: 'Title',
          body: 'Body',
          isRead: false,
          createdAt: DateTime(2024, 1, 15),
        );

        expect(model.id, '1');
        expect(model.title, 'Title');
        expect(model.body, 'Body');
        expect(model.isRead, isFalse);
      });

      test('extends Notification', () {
        final model = NotificationModel(
          id: '1',
          title: 'Title',
          body: 'Body',
          isRead: false,
          createdAt: DateTime(2024, 1, 15),
        );

        expect(model, isA<Notification>());
      });
    });

    group('fromJson', () {
      test('creates from complete JSON', () {
        final json = {
          'id': 1,
          'title': 'Order Delivered',
          'message': 'Your order has been delivered',
          'is_read': true,
          'type': 'order_update',
          'created_at': '2024-01-15T10:30:00.000Z',
          'data': {'orderId': 123},
        };

        final model = NotificationModel.fromJson(json);

        expect(model.id, '1');
        expect(model.title, 'Order Delivered');
        expect(model.body, 'Your order has been delivered');
        expect(model.isRead, isTrue);
        expect(model.type, 'order_update');
        expect(model.data, {'orderId': 123});
      });

      test('uses body field if message not present', () {
        final json = {
          'id': 1,
          'title': 'Title',
          'body': 'Body content',
          'is_read': false,
          'created_at': '2024-01-15T10:30:00.000Z',
        };

        final model = NotificationModel.fromJson(json);

        expect(model.body, 'Body content');
      });

      test('uses title from data if present', () {
        final json = {
          'id': 1,
          'title': 'Default Title',
          'message': 'Default message',
          'is_read': false,
          'created_at': '2024-01-15T10:30:00.000Z',
          'data': {
            'title': 'Data Title',
            'body': 'Data Body',
          },
        };

        final model = NotificationModel.fromJson(json);

        expect(model.title, 'Data Title');
        expect(model.body, 'Data Body');
      });

      test('uses message from data if body not present', () {
        final json = {
          'id': 1,
          'title': 'Title',
          'message': 'Default message',
          'is_read': false,
          'created_at': '2024-01-15T10:30:00.000Z',
          'data': {
            'message': 'Data Message',
          },
        };

        final model = NotificationModel.fromJson(json);

        expect(model.body, 'Data Message');
      });

      test('handles read_at for isRead', () {
        final json = {
          'id': 1,
          'title': 'Title',
          'message': 'Message',
          'is_read': false,
          'read_at': '2024-01-15T11:00:00.000Z',
          'created_at': '2024-01-15T10:30:00.000Z',
        };

        final model = NotificationModel.fromJson(json);

        expect(model.isRead, isTrue);
      });

      test('handles missing title with default', () {
        final json = {
          'id': 1,
          'message': 'Message',
          'is_read': false,
          'created_at': '2024-01-15T10:30:00.000Z',
        };

        final model = NotificationModel.fromJson(json);

        expect(model.title, 'Notification');
      });

      test('handles missing message with empty string', () {
        final json = {
          'id': 1,
          'title': 'Title',
          'is_read': false,
          'created_at': '2024-01-15T10:30:00.000Z',
        };

        final model = NotificationModel.fromJson(json);

        expect(model.body, '');
      });

      test('handles non-map data field', () {
        final json = {
          'id': 1,
          'title': 'Title',
          'message': 'Message',
          'is_read': false,
          'created_at': '2024-01-15T10:30:00.000Z',
          'data': 'not a map',
        };

        final model = NotificationModel.fromJson(json);

        expect(model.data, isNull);
      });

      test('converts numeric id to string', () {
        final json = {
          'id': 123,
          'title': 'Title',
          'message': 'Message',
          'is_read': false,
          'created_at': '2024-01-15T10:30:00.000Z',
        };

        final model = NotificationModel.fromJson(json);

        expect(model.id, '123');
      });

      test('converts type to string', () {
        final json = {
          'id': 1,
          'title': 'Title',
          'message': 'Message',
          'is_read': false,
          'type': 123,
          'created_at': '2024-01-15T10:30:00.000Z',
        };

        final model = NotificationModel.fromJson(json);

        expect(model.type, '123');
      });
    });
  });
}
