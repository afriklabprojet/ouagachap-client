import 'package:flutter_test/flutter_test.dart';
import 'package:ouaga_chap_client/features/notification/presentation/bloc/notification_event.dart';

void main() {
  group('NotificationEvent', () {
    group('LoadNotifications', () {
      test('should be a NotificationEvent', () {
        const event = LoadNotifications();
        expect(event, isA<NotificationEvent>());
      });

      test('default refresh should be false', () {
        const event = LoadNotifications();
        expect(event.refresh, isFalse);
      });

      test('creates instance with refresh true', () {
        const event = LoadNotifications(refresh: true);
        expect(event.refresh, isTrue);
      });

      test('props should be empty (inherited)', () {
        const event = LoadNotifications();
        expect(event.props, isEmpty);
      });

      test('two instances with same refresh are equal', () {
        const event1 = LoadNotifications(refresh: true);
        const event2 = LoadNotifications(refresh: true);
        expect(event1, equals(event2));
      });

      test('two instances with different refresh are still equal (props is empty)', () {
        const event1 = LoadNotifications(refresh: false);
        const event2 = LoadNotifications(refresh: true);
        // Since props is empty from base class, they are equal
        expect(event1, equals(event2));
      });
    });

    group('MarkAsRead', () {
      test('should be a NotificationEvent', () {
        const event = MarkAsRead('notif-1');
        expect(event, isA<NotificationEvent>());
      });

      test('creates instance with id', () {
        const event = MarkAsRead('notif-123');
        expect(event.id, 'notif-123');
      });

      test('props should be empty (inherited)', () {
        const event = MarkAsRead('notif-1');
        expect(event.props, isEmpty);
      });

      test('two instances with same id are equal', () {
        const event1 = MarkAsRead('notif-1');
        const event2 = MarkAsRead('notif-1');
        expect(event1, equals(event2));
      });

      test('two instances with different id are still equal (props is empty)', () {
        const event1 = MarkAsRead('notif-1');
        const event2 = MarkAsRead('notif-2');
        // Since props is empty from base class, they are equal
        expect(event1, equals(event2));
      });
    });

    group('MarkAllAsRead', () {
      test('should be a NotificationEvent', () {
        final event = MarkAllAsRead();
        expect(event, isA<NotificationEvent>());
      });

      test('props should be empty', () {
        final event = MarkAllAsRead();
        expect(event.props, isEmpty);
      });

      test('two instances are equal', () {
        final event1 = MarkAllAsRead();
        final event2 = MarkAllAsRead();
        expect(event1, equals(event2));
      });
    });

    group('NotificationEvent base class', () {
      test('default props is empty list', () {
        // Test via concrete implementation
        const event = LoadNotifications();
        expect(event.props, isA<List<Object?>>());
        expect(event.props, isEmpty);
      });
    });
  });
}
