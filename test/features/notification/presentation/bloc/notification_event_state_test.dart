import 'package:flutter_test/flutter_test.dart';
import 'package:ouaga_chap_client/features/notification/domain/entities/notification.dart';
import 'package:ouaga_chap_client/features/notification/presentation/bloc/notification_event.dart';
import 'package:ouaga_chap_client/features/notification/presentation/bloc/notification_state.dart';

void main() {
  group('NotificationEvent', () {
    group('LoadNotifications', () {
      test('creates instance with default refresh false', () {
        const event = LoadNotifications();
        expect(event.refresh, isFalse);
      });

      test('creates instance with refresh true', () {
        const event = LoadNotifications(refresh: true);
        expect(event.refresh, isTrue);
      });

      test('props is empty (refresh not in props)', () {
        const event = LoadNotifications(refresh: true);
        expect(event.props, isEmpty);
      });

      test('is a NotificationEvent', () {
        const event = LoadNotifications();
        expect(event, isA<NotificationEvent>());
      });
    });

    group('MarkAsRead', () {
      test('creates instance with id', () {
        const event = MarkAsRead('123');
        expect(event.id, '123');
      });

      test('props is empty (id not in props)', () {
        const event = MarkAsRead('123');
        expect(event.props, isEmpty);
      });

      test('is a NotificationEvent', () {
        const event = MarkAsRead('1');
        expect(event, isA<NotificationEvent>());
      });
    });

    group('MarkAllAsRead', () {
      test('creates instance', () {
        final event = MarkAllAsRead();
        expect(event, isA<NotificationEvent>());
      });

      test('props is empty', () {
        final event = MarkAllAsRead();
        expect(event.props, isEmpty);
      });

      test('two instances are equal', () {
        final event1 = MarkAllAsRead();
        final event2 = MarkAllAsRead();
        expect(event1, equals(event2));
      });
    });
  });

  group('NotificationState', () {
    group('NotificationInitial', () {
      test('creates instance', () {
        final state = NotificationInitial();
        expect(state, isA<NotificationState>());
      });

      test('props is empty', () {
        final state = NotificationInitial();
        expect(state.props, isEmpty);
      });

      test('two instances are equal', () {
        final state1 = NotificationInitial();
        final state2 = NotificationInitial();
        expect(state1, equals(state2));
      });
    });

    group('NotificationLoading', () {
      test('creates instance', () {
        final state = NotificationLoading();
        expect(state, isA<NotificationState>());
      });

      test('props is empty', () {
        final state = NotificationLoading();
        expect(state.props, isEmpty);
      });

      test('two instances are equal', () {
        final state1 = NotificationLoading();
        final state2 = NotificationLoading();
        expect(state1, equals(state2));
      });
    });

    group('NotificationLoaded', () {
      test('creates instance with notifications and unreadCount', () {
        final notifications = [
          Notification(
            id: '1',
            title: 'Test',
            body: 'Body',
            isRead: false,
            createdAt: DateTime(2024, 1, 15),
          ),
        ];

        final state = NotificationLoaded(
          notifications: notifications,
          unreadCount: 1,
        );

        expect(state.notifications, notifications);
        expect(state.unreadCount, 1);
      });

      test('props contains notifications and unreadCount', () {
        final notifications = [
          Notification(
            id: '1',
            title: 'Test',
            body: 'Body',
            isRead: false,
            createdAt: DateTime(2024, 1, 15),
          ),
        ];

        final state = NotificationLoaded(
          notifications: notifications,
          unreadCount: 1,
        );

        expect(state.props, [notifications, 1]);
      });

      test('two states with same props are equal', () {
        final notifications = <Notification>[];

        const state1 = NotificationLoaded(
          notifications: [],
          unreadCount: 0,
        );
        const state2 = NotificationLoaded(
          notifications: [],
          unreadCount: 0,
        );

        expect(state1, equals(state2));
      });

      test('two states with different props are not equal', () {
        const state1 = NotificationLoaded(
          notifications: [],
          unreadCount: 0,
        );
        const state2 = NotificationLoaded(
          notifications: [],
          unreadCount: 5,
        );

        expect(state1, isNot(equals(state2)));
      });
    });

    group('NotificationError', () {
      test('creates instance with message', () {
        const state = NotificationError('Error occurred');
        expect(state.message, 'Error occurred');
      });

      test('props contains message', () {
        const state = NotificationError('Error');
        expect(state.props, ['Error']);
      });

      test('two states with same message are equal', () {
        const state1 = NotificationError('Error');
        const state2 = NotificationError('Error');
        expect(state1, equals(state2));
      });

      test('two states with different message are not equal', () {
        const state1 = NotificationError('Error 1');
        const state2 = NotificationError('Error 2');
        expect(state1, isNot(equals(state2)));
      });

      test('is a NotificationState', () {
        const state = NotificationError('Error');
        expect(state, isA<NotificationState>());
      });
    });
  });
}
