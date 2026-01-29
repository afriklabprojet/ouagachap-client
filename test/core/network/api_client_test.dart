import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ouaga_chap_client/core/network/api_client.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late ApiClient apiClient;
  late MockDio mockDio;

  setUp(() {
    mockDio = MockDio();
    apiClient = ApiClient(mockDio);
  });

  group('ApiClient', () {
    final testResponse = Response(
      requestOptions: RequestOptions(path: '/test'),
      statusCode: 200,
      data: {'success': true},
    );

    group('GET request', () {
      test('should make GET request with path only', () async {
        // Arrange
        when(() => mockDio.get(
              '/users',
              queryParameters: null,
              options: null,
            )).thenAnswer((_) async => testResponse);

        // Act
        final result = await apiClient.get('/users');

        // Assert
        expect(result.statusCode, equals(200));
        verify(() => mockDio.get('/users', queryParameters: null, options: null)).called(1);
      });

      test('should make GET request with query parameters', () async {
        // Arrange
        final queryParams = {'page': 1, 'limit': 10};
        when(() => mockDio.get(
              '/users',
              queryParameters: queryParams,
              options: null,
            )).thenAnswer((_) async => testResponse);

        // Act
        await apiClient.get('/users', queryParameters: queryParams);

        // Assert
        verify(() => mockDio.get('/users', queryParameters: queryParams, options: null)).called(1);
      });

      test('should make GET request with options', () async {
        // Arrange
        final options = Options(headers: {'Custom': 'Header'});
        when(() => mockDio.get(
              '/users',
              queryParameters: null,
              options: any(named: 'options'),
            )).thenAnswer((_) async => testResponse);

        // Act
        await apiClient.get('/users', options: options);

        // Assert
        verify(() => mockDio.get('/users', queryParameters: null, options: any(named: 'options'))).called(1);
      });
    });

    group('POST request', () {
      test('should make POST request with data', () async {
        // Arrange
        final data = {'name': 'John', 'email': 'john@test.com'};
        when(() => mockDio.post(
              '/users',
              data: data,
              queryParameters: null,
              options: null,
            )).thenAnswer((_) async => testResponse);

        // Act
        final result = await apiClient.post('/users', data: data);

        // Assert
        expect(result.statusCode, equals(200));
        verify(() => mockDio.post('/users', data: data, queryParameters: null, options: null)).called(1);
      });

      test('should make POST request without data', () async {
        // Arrange
        when(() => mockDio.post(
              '/logout',
              data: null,
              queryParameters: null,
              options: null,
            )).thenAnswer((_) async => testResponse);

        // Act
        await apiClient.post('/logout');

        // Assert
        verify(() => mockDio.post('/logout', data: null, queryParameters: null, options: null)).called(1);
      });
    });

    group('PUT request', () {
      test('should make PUT request with data', () async {
        // Arrange
        final data = {'name': 'John Updated'};
        when(() => mockDio.put(
              '/users/1',
              data: data,
              queryParameters: null,
              options: null,
            )).thenAnswer((_) async => testResponse);

        // Act
        await apiClient.put('/users/1', data: data);

        // Assert
        verify(() => mockDio.put('/users/1', data: data, queryParameters: null, options: null)).called(1);
      });
    });

    group('PATCH request', () {
      test('should make PATCH request with data', () async {
        // Arrange
        final data = {'status': 'active'};
        when(() => mockDio.patch(
              '/users/1',
              data: data,
              queryParameters: null,
              options: null,
            )).thenAnswer((_) async => testResponse);

        // Act
        await apiClient.patch('/users/1', data: data);

        // Assert
        verify(() => mockDio.patch('/users/1', data: data, queryParameters: null, options: null)).called(1);
      });
    });

    group('DELETE request', () {
      test('should make DELETE request', () async {
        // Arrange
        when(() => mockDio.delete(
              '/users/1',
              data: null,
              queryParameters: null,
              options: null,
            )).thenAnswer((_) async => testResponse);

        // Act
        await apiClient.delete('/users/1');

        // Assert
        verify(() => mockDio.delete('/users/1', data: null, queryParameters: null, options: null)).called(1);
      });

      test('should make DELETE request with data', () async {
        // Arrange
        final data = {'reason': 'Account closed'};
        when(() => mockDio.delete(
              '/users/1',
              data: data,
              queryParameters: null,
              options: null,
            )).thenAnswer((_) async => testResponse);

        // Act
        await apiClient.delete('/users/1', data: data);

        // Assert
        verify(() => mockDio.delete('/users/1', data: data, queryParameters: null, options: null)).called(1);
      });
    });

    group('Error handling', () {
      test('should propagate DioException on error', () async {
        // Arrange
        when(() => mockDio.get(
              any(),
              queryParameters: any(named: 'queryParameters'),
              options: any(named: 'options'),
            )).thenThrow(DioException(
          requestOptions: RequestOptions(path: '/error'),
          type: DioExceptionType.connectionTimeout,
        ));

        // Act & Assert
        expect(
          () => apiClient.get('/error'),
          throwsA(isA<DioException>()),
        );
      });

      test('should propagate 404 error', () async {
        // Arrange
        when(() => mockDio.get(
              any(),
              queryParameters: any(named: 'queryParameters'),
              options: any(named: 'options'),
            )).thenThrow(DioException(
          requestOptions: RequestOptions(path: '/notfound'),
          response: Response(
            requestOptions: RequestOptions(path: '/notfound'),
            statusCode: 404,
          ),
          type: DioExceptionType.badResponse,
        ));

        // Act & Assert
        expect(
          () => apiClient.get('/notfound'),
          throwsA(isA<DioException>()),
        );
      });
    });

    group('PUT request with queryParameters', () {
      test('should make PUT request with queryParameters', () async {
        // Arrange
        final data = {'name': 'Test'};
        final queryParams = {'expand': 'true'};
        when(() => mockDio.put(
              '/users/1',
              data: data,
              queryParameters: queryParams,
              options: null,
            )).thenAnswer((_) async => testResponse);

        // Act
        await apiClient.put('/users/1', data: data, queryParameters: queryParams);

        // Assert
        verify(() => mockDio.put('/users/1', data: data, queryParameters: queryParams, options: null)).called(1);
      });
    });

    group('PATCH request with queryParameters', () {
      test('should make PATCH request with queryParameters', () async {
        // Arrange
        final data = {'status': 'active'};
        final queryParams = {'notify': 'true'};
        when(() => mockDio.patch(
              '/users/1',
              data: data,
              queryParameters: queryParams,
              options: null,
            )).thenAnswer((_) async => testResponse);

        // Act
        await apiClient.patch('/users/1', data: data, queryParameters: queryParams);

        // Assert
        verify(() => mockDio.patch('/users/1', data: data, queryParameters: queryParams, options: null)).called(1);
      });
    });

    group('DELETE request with queryParameters', () {
      test('should make DELETE request with queryParameters', () async {
        // Arrange
        final queryParams = {'soft': 'true'};
        when(() => mockDio.delete(
              '/users/1',
              data: null,
              queryParameters: queryParams,
              options: null,
            )).thenAnswer((_) async => testResponse);

        // Act
        await apiClient.delete('/users/1', queryParameters: queryParams);

        // Assert
        verify(() => mockDio.delete('/users/1', data: null, queryParameters: queryParams, options: null)).called(1);
      });
    });

    group('POST request with queryParameters', () {
      test('should make POST request with queryParameters', () async {
        // Arrange
        final data = {'name': 'Test'};
        final queryParams = {'type': 'user'};
        when(() => mockDio.post(
              '/create',
              data: data,
              queryParameters: queryParams,
              options: null,
            )).thenAnswer((_) async => testResponse);

        // Act
        await apiClient.post('/create', data: data, queryParameters: queryParams);

        // Assert
        verify(() => mockDio.post('/create', data: data, queryParameters: queryParams, options: null)).called(1);
      });
    });
  });
}
