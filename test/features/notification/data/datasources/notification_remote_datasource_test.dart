import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ouaga_chap_client/core/network/api_client.dart';
import 'package:ouaga_chap_client/features/notification/data/datasources/notification_remote_datasource.dart';

class MockApiClient extends Mock implements ApiClient {}

void main() {
  late NotificationRemoteDataSourceImpl dataSource;
  late MockApiClient mockApiClient;

  setUp(() {
    mockApiClient = MockApiClient();
    dataSource = NotificationRemoteDataSourceImpl(mockApiClient);
  });

  group('NotificationRemoteDataSourceImpl', () {
    group('getNotifications', () {
      final testResponse = Response(
        requestOptions: RequestOptions(path: 'notifications'),
        data: {
          'data': {
            'data': [
              {
                'id': '1',
                'title': 'Test Notification',
                'body': 'Test body',
                'is_read': false,
                'type': 'order',
                'created_at': '2024-01-15T10:00:00Z',
                'data': {'order_id': '123'},
              },
              {
                'id': '2',
                'title': 'Second Notification',
                'body': 'Second body',
                'is_read': true,
                'type': 'promo',
                'created_at': '2024-01-14T10:00:00Z',
                'data': null,
              },
            ],
          },
        },
      );

      test('should return notifications from API', () async {
        // Arrange
        when(() => mockApiClient.get(
              'notifications',
              queryParameters: any(named: 'queryParameters'),
            )).thenAnswer((_) async => testResponse);

        // Act
        final result = await dataSource.getNotifications();

        // Assert
        expect(result.length, equals(2));
        expect(result[0].title, equals('Test Notification'));
        expect(result[1].title, equals('Second Notification'));
        verify(() => mockApiClient.get(
              'notifications',
              queryParameters: {'page': 1},
            )).called(1);
      });

      test('should pass page parameter to API', () async {
        // Arrange
        when(() => mockApiClient.get(
              'notifications',
              queryParameters: any(named: 'queryParameters'),
            )).thenAnswer((_) async => testResponse);

        // Act
        await dataSource.getNotifications(page: 2);

        // Assert
        verify(() => mockApiClient.get(
              'notifications',
              queryParameters: {'page': 2},
            )).called(1);
      });

      test('should return empty list when data is null', () async {
        // Arrange
        final emptyResponse = Response(
          requestOptions: RequestOptions(path: 'notifications'),
          data: {
            'data': {
              'data': null,
            },
          },
        );
        when(() => mockApiClient.get(
              'notifications',
              queryParameters: any(named: 'queryParameters'),
            )).thenAnswer((_) async => emptyResponse);

        // Act
        final result = await dataSource.getNotifications();

        // Assert
        expect(result, isEmpty);
      });
    });

    group('getUnreadCount', () {
      test('should return count when response is int', () async {
        // Arrange
        final testResponse = Response(
          requestOptions: RequestOptions(path: 'notifications/unread-count'),
          data: 5,
        );
        when(() => mockApiClient.get('notifications/unread-count'))
            .thenAnswer((_) async => testResponse);

        // Act
        final result = await dataSource.getUnreadCount();

        // Assert
        expect(result, equals(5));
        verify(() => mockApiClient.get('notifications/unread-count')).called(1);
      });

      test('should return count from object when response is map', () async {
        // Arrange
        final testResponse = Response(
          requestOptions: RequestOptions(path: 'notifications/unread-count'),
          data: {'count': 10},
        );
        when(() => mockApiClient.get('notifications/unread-count'))
            .thenAnswer((_) async => testResponse);

        // Act
        final result = await dataSource.getUnreadCount();

        // Assert
        expect(result, equals(10));
      });

      test('should return 0 when count is missing', () async {
        // Arrange
        final testResponse = Response(
          requestOptions: RequestOptions(path: 'notifications/unread-count'),
          data: {},
        );
        when(() => mockApiClient.get('notifications/unread-count'))
            .thenAnswer((_) async => testResponse);

        // Act
        final result = await dataSource.getUnreadCount();

        // Assert
        expect(result, equals(0));
      });
    });

    group('markAsRead', () {
      test('should call mark as read API', () async {
        // Arrange
        final testResponse = Response(
          requestOptions: RequestOptions(path: 'notifications/1/read'),
          data: {'success': true},
        );
        when(() => mockApiClient.post('notifications/1/read'))
            .thenAnswer((_) async => testResponse);

        // Act
        await dataSource.markAsRead('1');

        // Assert
        verify(() => mockApiClient.post('notifications/1/read')).called(1);
      });
    });

    group('markAllAsRead', () {
      test('should call mark all as read API', () async {
        // Arrange
        final testResponse = Response(
          requestOptions: RequestOptions(path: 'notifications/mark-all-read'),
          data: {'success': true},
        );
        when(() => mockApiClient.post('notifications/mark-all-read'))
            .thenAnswer((_) async => testResponse);

        // Act
        await dataSource.markAllAsRead();

        // Assert
        verify(() => mockApiClient.post('notifications/mark-all-read')).called(1);
      });
    });
  });
}
