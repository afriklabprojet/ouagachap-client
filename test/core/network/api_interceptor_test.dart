import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ouaga_chap_client/core/network/api_interceptor.dart';

void main() {
  late ApiInterceptor interceptor;

  group('ApiInterceptor', () {
    group('onRequest', () {
      test('should add Authorization header when token exists', () async {
        // Arrange
        SharedPreferences.setMockInitialValues({'auth_token': 'test_token_123'});
        final prefs = await SharedPreferences.getInstance();
        interceptor = ApiInterceptor(prefs);

        final options = RequestOptions(path: '/test');
        final handler = _MockRequestInterceptorHandler();

        // Act
        interceptor.onRequest(options, handler);

        // Assert
        expect(options.headers['Authorization'], equals('Bearer test_token_123'));
        expect(handler.nextCalled, isTrue);
      });

      test('should not add Authorization header when token is null', () async {
        // Arrange
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();
        interceptor = ApiInterceptor(prefs);

        final options = RequestOptions(path: '/test');
        final handler = _MockRequestInterceptorHandler();

        // Act
        interceptor.onRequest(options, handler);

        // Assert
        expect(options.headers['Authorization'], isNull);
        expect(handler.nextCalled, isTrue);
      });

      test('should not add Authorization header when token is empty', () async {
        // Arrange
        SharedPreferences.setMockInitialValues({'auth_token': ''});
        final prefs = await SharedPreferences.getInstance();
        interceptor = ApiInterceptor(prefs);

        final options = RequestOptions(path: '/test');
        final handler = _MockRequestInterceptorHandler();

        // Act
        interceptor.onRequest(options, handler);

        // Assert
        expect(options.headers['Authorization'], isNull);
        expect(handler.nextCalled, isTrue);
      });
    });

    group('onResponse', () {
      test('should pass response through', () async {
        // Arrange
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();
        interceptor = ApiInterceptor(prefs);

        final response = Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 200,
          data: {'success': true},
        );
        final handler = _MockResponseInterceptorHandler();

        // Act
        interceptor.onResponse(response, handler);

        // Assert
        expect(handler.nextCalled, isTrue);
      });
    });

    group('onError', () {
      test('should remove token on 401 error', () async {
        // Arrange
        SharedPreferences.setMockInitialValues({'auth_token': 'expired_token'});
        final prefs = await SharedPreferences.getInstance();
        interceptor = ApiInterceptor(prefs);

        final error = DioException(
          requestOptions: RequestOptions(path: '/test'),
          response: Response(
            requestOptions: RequestOptions(path: '/test'),
            statusCode: 401,
          ),
          type: DioExceptionType.badResponse,
        );
        final handler = _MockErrorInterceptorHandler();

        // Verify token exists before
        expect(prefs.getString('auth_token'), equals('expired_token'));

        // Act
        interceptor.onError(error, handler);

        // Assert - token should be removed
        expect(prefs.getString('auth_token'), isNull);
        expect(handler.nextCalled, isTrue);
      });

      test('should not remove token on non-401 error', () async {
        // Arrange
        SharedPreferences.setMockInitialValues({'auth_token': 'valid_token'});
        final prefs = await SharedPreferences.getInstance();
        interceptor = ApiInterceptor(prefs);

        final error = DioException(
          requestOptions: RequestOptions(path: '/test'),
          response: Response(
            requestOptions: RequestOptions(path: '/test'),
            statusCode: 500,
          ),
          type: DioExceptionType.badResponse,
        );
        final handler = _MockErrorInterceptorHandler();

        // Act
        interceptor.onError(error, handler);

        // Assert - token should still exist
        expect(prefs.getString('auth_token'), equals('valid_token'));
        expect(handler.nextCalled, isTrue);
      });

      test('should handle error without response', () async {
        // Arrange
        SharedPreferences.setMockInitialValues({'auth_token': 'valid_token'});
        final prefs = await SharedPreferences.getInstance();
        interceptor = ApiInterceptor(prefs);

        final error = DioException(
          requestOptions: RequestOptions(path: '/test'),
          type: DioExceptionType.connectionTimeout,
        );
        final handler = _MockErrorInterceptorHandler();

        // Act
        interceptor.onError(error, handler);

        // Assert - token should still exist
        expect(prefs.getString('auth_token'), equals('valid_token'));
        expect(handler.nextCalled, isTrue);
      });
    });
  });
}

// Mock handlers for testing
class _MockRequestInterceptorHandler extends RequestInterceptorHandler {
  bool nextCalled = false;

  @override
  void next(RequestOptions requestOptions) {
    nextCalled = true;
  }
}

class _MockResponseInterceptorHandler extends ResponseInterceptorHandler {
  bool nextCalled = false;

  @override
  void next(Response response) {
    nextCalled = true;
  }
}

class _MockErrorInterceptorHandler extends ErrorInterceptorHandler {
  bool nextCalled = false;

  @override
  void next(DioException err) {
    nextCalled = true;
  }
}
