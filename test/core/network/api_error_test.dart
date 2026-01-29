import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ouaga_chap_client/core/network/api_error.dart';

void main() {
  group('ApiErrorType', () {
    test('all error types are defined', () {
      expect(ApiErrorType.values.length, 8);
      expect(ApiErrorType.values, contains(ApiErrorType.network));
      expect(ApiErrorType.values, contains(ApiErrorType.server));
      expect(ApiErrorType.values, contains(ApiErrorType.timeout));
      expect(ApiErrorType.values, contains(ApiErrorType.unauthorized));
      expect(ApiErrorType.values, contains(ApiErrorType.forbidden));
      expect(ApiErrorType.values, contains(ApiErrorType.notFound));
      expect(ApiErrorType.values, contains(ApiErrorType.validation));
      expect(ApiErrorType.values, contains(ApiErrorType.unknown));
    });
  });

  group('ApiError', () {
    group('Constructor', () {
      test('creates error with required fields', () {
        const error = ApiError(
          message: 'Test error',
          type: ApiErrorType.unknown,
        );

        expect(error.message, 'Test error');
        expect(error.type, ApiErrorType.unknown);
        expect(error.details, isNull);
        expect(error.statusCode, isNull);
        expect(error.originalError, isNull);
      });

      test('creates error with all fields', () {
        final originalError = Exception('Original');
        final error = ApiError(
          message: 'Test error',
          details: 'Error details',
          type: ApiErrorType.server,
          statusCode: 500,
          originalError: originalError,
        );

        expect(error.message, 'Test error');
        expect(error.details, 'Error details');
        expect(error.type, ApiErrorType.server);
        expect(error.statusCode, 500);
        expect(error.originalError, originalError);
      });
    });

    group('fromDioException', () {
      test('handles connectionTimeout', () {
        final dioError = DioException(
          type: DioExceptionType.connectionTimeout,
          requestOptions: RequestOptions(path: '/test'),
        );

        final error = ApiError.fromDioException(dioError);

        expect(error.type, ApiErrorType.timeout);
        expect(error.message, contains('Délai'));
      });

      test('handles sendTimeout', () {
        final dioError = DioException(
          type: DioExceptionType.sendTimeout,
          requestOptions: RequestOptions(path: '/test'),
        );

        final error = ApiError.fromDioException(dioError);

        expect(error.type, ApiErrorType.timeout);
      });

      test('handles receiveTimeout', () {
        final dioError = DioException(
          type: DioExceptionType.receiveTimeout,
          requestOptions: RequestOptions(path: '/test'),
        );

        final error = ApiError.fromDioException(dioError);

        expect(error.type, ApiErrorType.timeout);
      });

      test('handles connectionError', () {
        final dioError = DioException(
          type: DioExceptionType.connectionError,
          requestOptions: RequestOptions(path: '/test'),
        );

        final error = ApiError.fromDioException(dioError);

        expect(error.type, ApiErrorType.network);
        expect(error.message, contains('connexion'));
      });

      test('handles cancel', () {
        final dioError = DioException(
          type: DioExceptionType.cancel,
          requestOptions: RequestOptions(path: '/test'),
        );

        final error = ApiError.fromDioException(dioError);

        expect(error.type, ApiErrorType.unknown);
        expect(error.message, contains('annulée'));
      });

      test('handles badCertificate', () {
        final dioError = DioException(
          type: DioExceptionType.badCertificate,
          requestOptions: RequestOptions(path: '/test'),
        );

        final error = ApiError.fromDioException(dioError);

        expect(error.type, ApiErrorType.server);
        expect(error.message, contains('certificat'));
      });

      test('handles SocketException as network error', () {
        final dioError = DioException(
          type: DioExceptionType.unknown,
          error: const SocketException('No internet'),
          requestOptions: RequestOptions(path: '/test'),
        );

        final error = ApiError.fromDioException(dioError);

        expect(error.type, ApiErrorType.network);
        expect(error.message, contains('connexion'));
      });

      test('handles unknown error', () {
        final dioError = DioException(
          type: DioExceptionType.unknown,
          message: 'Unknown error',
          requestOptions: RequestOptions(path: '/test'),
        );

        final error = ApiError.fromDioException(dioError);

        expect(error.type, ApiErrorType.unknown);
      });
    });

    group('HTTP Status Codes', () {
      test('handles 400 Bad Request', () {
        final dioError = DioException(
          type: DioExceptionType.badResponse,
          response: Response(
            statusCode: 400,
            requestOptions: RequestOptions(path: '/test'),
          ),
          requestOptions: RequestOptions(path: '/test'),
        );

        final error = ApiError.fromDioException(dioError);

        expect(error.type, ApiErrorType.validation);
        expect(error.statusCode, 400);
        expect(error.message, contains('invalide'));
      });

      test('handles 401 Unauthorized', () {
        final dioError = DioException(
          type: DioExceptionType.badResponse,
          response: Response(
            statusCode: 401,
            requestOptions: RequestOptions(path: '/test'),
          ),
          requestOptions: RequestOptions(path: '/test'),
        );

        final error = ApiError.fromDioException(dioError);

        expect(error.type, ApiErrorType.unauthorized);
        expect(error.statusCode, 401);
        expect(error.message, contains('Session'));
      });

      test('handles 403 Forbidden', () {
        final dioError = DioException(
          type: DioExceptionType.badResponse,
          response: Response(
            statusCode: 403,
            requestOptions: RequestOptions(path: '/test'),
          ),
          requestOptions: RequestOptions(path: '/test'),
        );

        final error = ApiError.fromDioException(dioError);

        expect(error.type, ApiErrorType.forbidden);
        expect(error.statusCode, 403);
        expect(error.message, contains('refusé'));
      });

      test('handles 404 Not Found', () {
        final dioError = DioException(
          type: DioExceptionType.badResponse,
          response: Response(
            statusCode: 404,
            requestOptions: RequestOptions(path: '/test'),
          ),
          requestOptions: RequestOptions(path: '/test'),
        );

        final error = ApiError.fromDioException(dioError);

        expect(error.type, ApiErrorType.notFound);
        expect(error.statusCode, 404);
        expect(error.message, contains('introuvable'));
      });

      test('handles 422 Unprocessable Entity', () {
        final dioError = DioException(
          type: DioExceptionType.badResponse,
          response: Response(
            statusCode: 422,
            requestOptions: RequestOptions(path: '/test'),
          ),
          requestOptions: RequestOptions(path: '/test'),
        );

        final error = ApiError.fromDioException(dioError);

        expect(error.type, ApiErrorType.validation);
        expect(error.statusCode, 422);
        expect(error.message, contains('invalides'));
      });

      test('extracts message from response data', () {
        final dioError = DioException(
          type: DioExceptionType.badResponse,
          response: Response(
            statusCode: 400,
            data: {'message': 'Custom error message'},
            requestOptions: RequestOptions(path: '/test'),
          ),
          requestOptions: RequestOptions(path: '/test'),
        );

        final error = ApiError.fromDioException(dioError);

        expect(error.details, 'Custom error message');
      });

      test('extracts error from response data', () {
        final dioError = DioException(
          type: DioExceptionType.badResponse,
          response: Response(
            statusCode: 400,
            data: {'error': 'Custom error'},
            requestOptions: RequestOptions(path: '/test'),
          ),
          requestOptions: RequestOptions(path: '/test'),
        );

        final error = ApiError.fromDioException(dioError);

        expect(error.details, 'Custom error');
      });
    });

    group('Exception behavior', () {
      test('ApiError implements Exception', () {
        const error = ApiError(
          message: 'Test',
          type: ApiErrorType.unknown,
        );

        expect(error, isA<Exception>());
      });

      test('toString returns message', () {
        const error = ApiError(
          message: 'Test error message',
          type: ApiErrorType.unknown,
        );

        expect(error.toString(), 'Test error message');
      });
    });

    group('icon getter', () {
      test('returns wifi_off for network error', () {
        const error = ApiError(
          message: 'Network',
          type: ApiErrorType.network,
        );
        expect(error.icon, Icons.wifi_off_outlined);
      });

      test('returns cloud_off for server error', () {
        const error = ApiError(
          message: 'Server',
          type: ApiErrorType.server,
        );
        expect(error.icon, Icons.cloud_off_outlined);
      });

      test('returns hourglass for timeout error', () {
        const error = ApiError(
          message: 'Timeout',
          type: ApiErrorType.timeout,
        );
        expect(error.icon, Icons.hourglass_empty);
      });

      test('returns lock for unauthorized error', () {
        const error = ApiError(
          message: 'Unauthorized',
          type: ApiErrorType.unauthorized,
        );
        expect(error.icon, Icons.lock_outline);
      });

      test('returns block for forbidden error', () {
        const error = ApiError(
          message: 'Forbidden',
          type: ApiErrorType.forbidden,
        );
        expect(error.icon, Icons.block_outlined);
      });

      test('returns search_off for notFound error', () {
        const error = ApiError(
          message: 'Not Found',
          type: ApiErrorType.notFound,
        );
        expect(error.icon, Icons.search_off_outlined);
      });

      test('returns warning for validation error', () {
        const error = ApiError(
          message: 'Validation',
          type: ApiErrorType.validation,
        );
        expect(error.icon, Icons.warning_amber_outlined);
      });

      test('returns error for unknown error', () {
        const error = ApiError(
          message: 'Unknown',
          type: ApiErrorType.unknown,
        );
        expect(error.icon, Icons.error_outline);
      });
    });

    group('isRetryable getter', () {
      test('returns true for network error', () {
        const error = ApiError(
          message: 'Network',
          type: ApiErrorType.network,
        );
        expect(error.isRetryable, isTrue);
      });

      test('returns true for timeout error', () {
        const error = ApiError(
          message: 'Timeout',
          type: ApiErrorType.timeout,
        );
        expect(error.isRetryable, isTrue);
      });

      test('returns true for server error', () {
        const error = ApiError(
          message: 'Server',
          type: ApiErrorType.server,
        );
        expect(error.isRetryable, isTrue);
      });

      test('returns false for unauthorized error', () {
        const error = ApiError(
          message: 'Unauthorized',
          type: ApiErrorType.unauthorized,
        );
        expect(error.isRetryable, isFalse);
      });

      test('returns false for forbidden error', () {
        const error = ApiError(
          message: 'Forbidden',
          type: ApiErrorType.forbidden,
        );
        expect(error.isRetryable, isFalse);
      });

      test('returns false for validation error', () {
        const error = ApiError(
          message: 'Validation',
          type: ApiErrorType.validation,
        );
        expect(error.isRetryable, isFalse);
      });

      test('returns false for notFound error', () {
        const error = ApiError(
          message: 'Not Found',
          type: ApiErrorType.notFound,
        );
        expect(error.isRetryable, isFalse);
      });

      test('returns false for unknown error', () {
        const error = ApiError(
          message: 'Unknown',
          type: ApiErrorType.unknown,
        );
        expect(error.isRetryable, isFalse);
      });
    });

    group('requiresReauth getter', () {
      test('returns true for unauthorized error', () {
        const error = ApiError(
          message: 'Unauthorized',
          type: ApiErrorType.unauthorized,
        );
        expect(error.requiresReauth, isTrue);
      });

      test('returns false for other error types', () {
        const networkError = ApiError(
          message: 'Network',
          type: ApiErrorType.network,
        );
        const serverError = ApiError(
          message: 'Server',
          type: ApiErrorType.server,
        );
        const forbiddenError = ApiError(
          message: 'Forbidden',
          type: ApiErrorType.forbidden,
        );

        expect(networkError.requiresReauth, isFalse);
        expect(serverError.requiresReauth, isFalse);
        expect(forbiddenError.requiresReauth, isFalse);
      });
    });

    group('HTTP Status Codes (additional)', () {
      test('handles 429 Too Many Requests', () {
        final dioError = DioException(
          type: DioExceptionType.badResponse,
          response: Response(
            statusCode: 429,
            requestOptions: RequestOptions(path: '/test'),
          ),
          requestOptions: RequestOptions(path: '/test'),
        );

        final error = ApiError.fromDioException(dioError);

        expect(error.type, ApiErrorType.server);
        expect(error.statusCode, 429);
        expect(error.message, contains('requêtes'));
      });

      test('handles 500 Internal Server Error', () {
        final dioError = DioException(
          type: DioExceptionType.badResponse,
          response: Response(
            statusCode: 500,
            requestOptions: RequestOptions(path: '/test'),
          ),
          requestOptions: RequestOptions(path: '/test'),
        );

        final error = ApiError.fromDioException(dioError);

        expect(error.type, ApiErrorType.server);
        expect(error.statusCode, 500);
      });

      test('handles 502 Bad Gateway', () {
        final dioError = DioException(
          type: DioExceptionType.badResponse,
          response: Response(
            statusCode: 502,
            requestOptions: RequestOptions(path: '/test'),
          ),
          requestOptions: RequestOptions(path: '/test'),
        );

        final error = ApiError.fromDioException(dioError);

        expect(error.type, ApiErrorType.server);
        expect(error.statusCode, 502);
      });

      test('handles 503 Service Unavailable', () {
        final dioError = DioException(
          type: DioExceptionType.badResponse,
          response: Response(
            statusCode: 503,
            requestOptions: RequestOptions(path: '/test'),
          ),
          requestOptions: RequestOptions(path: '/test'),
        );

        final error = ApiError.fromDioException(dioError);

        expect(error.type, ApiErrorType.server);
        expect(error.statusCode, 503);
      });

      test('handles 504 Gateway Timeout', () {
        final dioError = DioException(
          type: DioExceptionType.badResponse,
          response: Response(
            statusCode: 504,
            requestOptions: RequestOptions(path: '/test'),
          ),
          requestOptions: RequestOptions(path: '/test'),
        );

        final error = ApiError.fromDioException(dioError);

        expect(error.type, ApiErrorType.server);
        expect(error.statusCode, 504);
      });

      test('handles unknown status code', () {
        final dioError = DioException(
          type: DioExceptionType.badResponse,
          response: Response(
            statusCode: 418, // I'm a teapot
            requestOptions: RequestOptions(path: '/test'),
          ),
          requestOptions: RequestOptions(path: '/test'),
        );

        final error = ApiError.fromDioException(dioError);

        expect(error.type, ApiErrorType.unknown);
        expect(error.statusCode, 418);
        expect(error.details, contains('418'));
      });

      test('uses server message for unknown status code', () {
        final dioError = DioException(
          type: DioExceptionType.badResponse,
          response: Response(
            statusCode: 418,
            data: {'message': 'Custom server message'},
            requestOptions: RequestOptions(path: '/test'),
          ),
          requestOptions: RequestOptions(path: '/test'),
        );

        final error = ApiError.fromDioException(dioError);

        expect(error.message, 'Custom server message');
      });
    });
  });

  group('DioExceptionExtension', () {
    test('toApiError converts DioException to ApiError', () {
      final dioError = DioException(
        type: DioExceptionType.connectionError,
        requestOptions: RequestOptions(path: '/test'),
      );

      final error = dioError.toApiError();

      expect(error, isA<ApiError>());
      expect(error.type, ApiErrorType.network);
    });
  });
}
