import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ouaga_chap_client/features/notification/data/datasources/notification_remote_datasource.dart';
import 'package:ouaga_chap_client/features/notification/data/models/notification_model.dart';
import 'package:ouaga_chap_client/features/notification/data/repositories/notification_repository_impl.dart';

class MockNotificationRemoteDataSource extends Mock
    implements NotificationRemoteDataSource {}

void main() {
  late NotificationRepositoryImpl repository;
  late MockNotificationRemoteDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockNotificationRemoteDataSource();
    repository = NotificationRepositoryImpl(remoteDataSource: mockDataSource);
  });

  group('NotificationRepositoryImpl', () {
    group('getNotifications', () {
      test('calls datasource with default page 1', () async {
        final notifications = [
          NotificationModel(
            id: '1',
            title: 'Test',
            body: 'Test message',
            isRead: false,
            createdAt: DateTime(2024, 1, 15),
          ),
        ];

        when(() => mockDataSource.getNotifications(page: 1))
            .thenAnswer((_) async => notifications);

        final result = await repository.getNotifications();

        expect(result, notifications);
        verify(() => mockDataSource.getNotifications(page: 1)).called(1);
      });

      test('calls datasource with custom page', () async {
        final notifications = <NotificationModel>[];

        when(() => mockDataSource.getNotifications(page: 3))
            .thenAnswer((_) async => notifications);

        final result = await repository.getNotifications(page: 3);

        expect(result, isEmpty);
        verify(() => mockDataSource.getNotifications(page: 3)).called(1);
      });

      test('returns empty list when no notifications', () async {
        when(() => mockDataSource.getNotifications(page: 1))
            .thenAnswer((_) async => []);

        final result = await repository.getNotifications();

        expect(result, isEmpty);
      });

      test('propagates exception from datasource', () async {
        when(() => mockDataSource.getNotifications(page: 1))
            .thenThrow(Exception('Network error'));

        expect(
          () => repository.getNotifications(),
          throwsException,
        );
      });
    });

    group('getUnreadCount', () {
      test('returns count from datasource', () async {
        when(() => mockDataSource.getUnreadCount())
            .thenAnswer((_) async => 5);

        final result = await repository.getUnreadCount();

        expect(result, 5);
        verify(() => mockDataSource.getUnreadCount()).called(1);
      });

      test('returns zero when no unread notifications', () async {
        when(() => mockDataSource.getUnreadCount())
            .thenAnswer((_) async => 0);

        final result = await repository.getUnreadCount();

        expect(result, 0);
      });

      test('propagates exception from datasource', () async {
        when(() => mockDataSource.getUnreadCount())
            .thenThrow(Exception('Error'));

        expect(
          () => repository.getUnreadCount(),
          throwsException,
        );
      });
    });

    group('markAsRead', () {
      test('calls datasource with correct id', () async {
        when(() => mockDataSource.markAsRead('notif123'))
            .thenAnswer((_) async {});

        await repository.markAsRead('notif123');

        verify(() => mockDataSource.markAsRead('notif123')).called(1);
      });

      test('propagates exception from datasource', () async {
        when(() => mockDataSource.markAsRead(any()))
            .thenThrow(Exception('Error'));

        expect(
          () => repository.markAsRead('123'),
          throwsException,
        );
      });
    });

    group('markAllAsRead', () {
      test('calls datasource markAllAsRead', () async {
        when(() => mockDataSource.markAllAsRead())
            .thenAnswer((_) async {});

        await repository.markAllAsRead();

        verify(() => mockDataSource.markAllAsRead()).called(1);
      });

      test('propagates exception from datasource', () async {
        when(() => mockDataSource.markAllAsRead())
            .thenThrow(Exception('Error'));

        expect(
          () => repository.markAllAsRead(),
          throwsException,
        );
      });
    });
  });
}
