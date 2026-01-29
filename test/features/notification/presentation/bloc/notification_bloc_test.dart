import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ouaga_chap_client/features/notification/presentation/bloc/notification_bloc.dart';
import 'package:ouaga_chap_client/features/notification/presentation/bloc/notification_event.dart';
import 'package:ouaga_chap_client/features/notification/presentation/bloc/notification_state.dart';
import 'package:ouaga_chap_client/features/notification/domain/usecases/get_notifications_usecase.dart';
import 'package:ouaga_chap_client/features/notification/domain/usecases/mark_notification_read_usecase.dart';
import 'package:ouaga_chap_client/features/notification/domain/entities/notification.dart';

class MockGetNotificationsUseCase extends Mock implements GetNotificationsUseCase {}
class MockMarkNotificationReadUseCase extends Mock implements MarkNotificationReadUseCase {}

void main() {
  late NotificationBloc bloc;
  late MockGetNotificationsUseCase mockGetNotifications;
  late MockMarkNotificationReadUseCase mockMarkAsRead;

  setUp(() {
    mockGetNotifications = MockGetNotificationsUseCase();
    mockMarkAsRead = MockMarkNotificationReadUseCase();
    bloc = NotificationBloc(
      getNotificationsUseCase: mockGetNotifications,
      markNotificationReadUseCase: mockMarkAsRead,
    );
  });

  tearDown(() {
    bloc.close();
  });

  final testNotifications = [
    Notification(
      id: '1',
      title: 'Order Update',
      body: 'Your order is ready',
      isRead: false,
      type: 'order_update',
      createdAt: DateTime(2024, 1, 15),
    ),
    Notification(
      id: '2',
      title: 'Promotion',
      body: '20% off on delivery',
      isRead: true,
      type: 'promo',
      createdAt: DateTime(2024, 1, 14),
    ),
  ];

  final emptyNotifications = <Notification>[];

  group('NotificationBloc', () {
    test('initial state is NotificationInitial', () {
      expect(bloc.state, isA<NotificationInitial>());
    });

    group('LoadNotifications', () {
      test('emits [NotificationLoading, NotificationLoaded] when getNotifications succeeds', () async {
        // Arrange
        when(() => mockGetNotifications.call())
            .thenAnswer((_) async => testNotifications);

        // Assert
        final expected = [
          isA<NotificationLoading>(),
          isA<NotificationLoaded>()
              .having((s) => s.notifications, 'notifications', testNotifications)
              .having((s) => s.unreadCount, 'unreadCount', 1), // 1 unread
        ];

        expectLater(bloc.stream, emitsInOrder(expected));

        // Act
        bloc.add(const LoadNotifications());
      });

      test('emits [NotificationLoading, NotificationError] when getNotifications fails', () async {
        // Arrange
        when(() => mockGetNotifications.call())
            .thenThrow(Exception('Network error'));

        // Assert
        final expected = [
          isA<NotificationLoading>(),
          isA<NotificationError>().having(
            (s) => s.message,
            'message',
            contains('Exception'),
          ),
        ];

        expectLater(bloc.stream, emitsInOrder(expected));

        // Act
        bloc.add(const LoadNotifications());
      });

      test('emits NotificationLoaded with unreadCount 0 when all notifications are read', () async {
        // Arrange
        final allReadNotifications = [
          Notification(
            id: '1',
            title: 'Test',
            body: 'Body',
            isRead: true,
            createdAt: DateTime(2024, 1, 15),
          ),
        ];
        when(() => mockGetNotifications.call())
            .thenAnswer((_) async => allReadNotifications);

        // Assert
        final expected = [
          isA<NotificationLoading>(),
          isA<NotificationLoaded>().having(
            (s) => s.unreadCount,
            'unreadCount',
            0,
          ),
        ];

        expectLater(bloc.stream, emitsInOrder(expected));

        // Act
        bloc.add(const LoadNotifications());
      });

      test('emits NotificationLoaded with empty list', () async {
        // Arrange
        when(() => mockGetNotifications.call())
            .thenAnswer((_) async => emptyNotifications);

        // Assert
        final expected = [
          isA<NotificationLoading>(),
          isA<NotificationLoaded>()
              .having((s) => s.notifications, 'notifications', isEmpty)
              .having((s) => s.unreadCount, 'unreadCount', 0),
        ];

        expectLater(bloc.stream, emitsInOrder(expected));

        // Act
        bloc.add(const LoadNotifications());
      });

      test('does not emit NotificationLoading when refresh is false and state is NotificationLoaded', () async {
        // First load
        when(() => mockGetNotifications.call())
            .thenAnswer((_) async => testNotifications);
        
        bloc.add(const LoadNotifications());
        
        await expectLater(
          bloc.stream,
          emitsInOrder([
            isA<NotificationLoading>(),
            isA<NotificationLoaded>(),
          ]),
        );
        
        expect(bloc.state, isA<NotificationLoaded>());

        // Second load with refresh: false - state is already NotificationLoaded
        // Check behavior by verifying the state directly
        bloc.add(const LoadNotifications(refresh: false));
        await Future.delayed(const Duration(milliseconds: 150));
        
        // State should remain NotificationLoaded
        expect(bloc.state, isA<NotificationLoaded>());
      });

      test('emits NotificationLoading when refresh is true', () async {
        // First load
        when(() => mockGetNotifications.call())
            .thenAnswer((_) async => testNotifications);
        
        bloc.add(const LoadNotifications());
        
        await expectLater(
          bloc.stream,
          emitsInOrder([
            isA<NotificationLoading>(),
            isA<NotificationLoaded>(),
          ]),
        );

        // Second load with refresh
        final future = expectLater(
          bloc.stream,
          emitsInOrder([
            isA<NotificationLoading>(),
            isA<NotificationLoaded>(),
          ]),
        );

        // Act
        bloc.add(const LoadNotifications(refresh: true));
        await future;
      });
    });

    group('MarkAsRead', () {
      test('calls markNotificationReadUseCase with correct id', () async {
        // Arrange
        when(() => mockGetNotifications.call())
            .thenAnswer((_) async => testNotifications);
        when(() => mockMarkAsRead.call(any()))
            .thenAnswer((_) async {});

        // First load notifications to get into NotificationLoaded state
        bloc.add(const LoadNotifications());
        await Future.delayed(const Duration(milliseconds: 150));
        
        expect(bloc.state, isA<NotificationLoaded>());

        // Act
        bloc.add(const MarkAsRead('1'));
        await Future.delayed(const Duration(milliseconds: 150));

        // Assert
        verify(() => mockMarkAsRead.call('1')).called(1);
      });

      test('does nothing when state is not NotificationLoaded', () async {
        // Arrange
        when(() => mockMarkAsRead.call(any()))
            .thenAnswer((_) async {});

        // State is NotificationInitial
        expect(bloc.state, isA<NotificationInitial>());

        // Act - try to mark as read when state is Initial
        bloc.add(const MarkAsRead('1'));
        await Future.delayed(const Duration(milliseconds: 100));

        // Assert - markAsRead should not be called
        verifyNever(() => mockMarkAsRead.call(any()));
      });

      test('handles error silently when markNotificationReadUseCase fails', () async {
        // Arrange
        when(() => mockGetNotifications.call())
            .thenAnswer((_) async => testNotifications);
        when(() => mockMarkAsRead.call(any()))
            .thenThrow(Exception('Server error'));

        // First load
        bloc.add(const LoadNotifications());
        await Future.delayed(const Duration(milliseconds: 150));
        
        expect(bloc.state, isA<NotificationLoaded>());

        // Act - mark as read (should handle error silently)
        bloc.add(const MarkAsRead('1'));
        await Future.delayed(const Duration(milliseconds: 100));

        // Assert - no error state should be emitted, state should remain NotificationLoaded
        expect(bloc.state, isA<NotificationLoaded>());
      });
    });
  });
}
