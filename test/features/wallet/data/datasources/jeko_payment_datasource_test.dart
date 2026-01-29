import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ouaga_chap_client/core/network/api_client.dart';
import 'package:ouaga_chap_client/features/wallet/data/datasources/jeko_payment_datasource.dart';

class MockApiClient extends Mock implements ApiClient {}

void main() {
  late MockApiClient mockApiClient;
  late JekoPaymentRemoteDataSourceImpl dataSource;

  setUp(() {
    mockApiClient = MockApiClient();
    dataSource = JekoPaymentRemoteDataSourceImpl(mockApiClient);
  });

  group('JekoPaymentMethod', () {
    test('fromJson creates instance with all fields', () {
      final json = {
        'code': 'orange_money',
        'name': 'Orange Money',
        'icon': '🟠',
      };

      final method = JekoPaymentMethod.fromJson(json);

      expect(method.code, 'orange_money');
      expect(method.name, 'Orange Money');
      expect(method.icon, '🟠');
    });

    test('fromJson handles missing values with defaults', () {
      final json = <String, dynamic>{};

      final method = JekoPaymentMethod.fromJson(json);

      expect(method.code, '');
      expect(method.name, '');
      expect(method.icon, '💳');
    });
  });

  group('JekoTransaction', () {
    test('fromJson creates instance with all fields', () {
      final json = {
        'id': 1,
        'jeko_id': 'JKO123',
        'reference': 'REF-001',
        'type': 'recharge',
        'amount': 5000,
        'currency': 'XOF',
        'fees': 100,
        'status': 'success',
        'status_label': 'Réussi',
        'payment_method': 'orange_money',
        'payment_method_name': 'Orange Money',
        'created_at': '2026-01-27T10:00:00Z',
        'executed_at': '2026-01-27T10:01:00Z',
      };

      final transaction = JekoTransaction.fromJson(json);

      expect(transaction.id, 1);
      expect(transaction.jekoId, 'JKO123');
      expect(transaction.reference, 'REF-001');
      expect(transaction.type, 'recharge');
      expect(transaction.amount, 5000.0);
      expect(transaction.currency, 'XOF');
      expect(transaction.fees, 100.0);
      expect(transaction.status, 'success');
      expect(transaction.statusLabel, 'Réussi');
      expect(transaction.paymentMethod, 'orange_money');
      expect(transaction.paymentMethodName, 'Orange Money');
      expect(transaction.executedAt, isNotNull);
    });

    test('fromJson handles missing optional fields', () {
      final json = {
        'id': 1,
        'reference': 'REF-001',
        'type': 'recharge',
        'amount': 5000,
        'created_at': '2026-01-27T10:00:00Z',
      };

      final transaction = JekoTransaction.fromJson(json);

      expect(transaction.jekoId, isNull);
      expect(transaction.executedAt, isNull);
      expect(transaction.currency, 'XOF');
      expect(transaction.fees, 0.0);
      expect(transaction.status, 'pending');
    });

    test('fromJson handles missing created_at', () {
      final json = {
        'id': 1,
        'reference': 'REF-001',
        'type': 'recharge',
        'amount': 5000,
      };

      final transaction = JekoTransaction.fromJson(json);

      expect(transaction.createdAt, isNotNull);
    });

    test('isPending returns true for pending status', () {
      final json = {
        'id': 1,
        'reference': 'REF-001',
        'type': 'recharge',
        'amount': 5000,
        'status': 'pending',
      };

      final transaction = JekoTransaction.fromJson(json);

      expect(transaction.isPending, isTrue);
      expect(transaction.isSuccessful, isFalse);
      expect(transaction.isFailed, isFalse);
    });

    test('isSuccessful returns true for success status', () {
      final json = {
        'id': 1,
        'reference': 'REF-001',
        'type': 'recharge',
        'amount': 5000,
        'status': 'success',
      };

      final transaction = JekoTransaction.fromJson(json);

      expect(transaction.isSuccessful, isTrue);
      expect(transaction.isPending, isFalse);
      expect(transaction.isFailed, isFalse);
    });

    test('isFailed returns true for error status', () {
      final transaction = JekoTransaction.fromJson({
        'id': 1,
        'reference': 'REF-001',
        'type': 'recharge',
        'amount': 5000,
        'status': 'error',
      });

      expect(transaction.isFailed, isTrue);
    });

    test('isFailed returns true for expired status', () {
      final transaction = JekoTransaction.fromJson({
        'id': 1,
        'reference': 'REF-001',
        'type': 'recharge',
        'amount': 5000,
        'status': 'expired',
      });

      expect(transaction.isFailed, isTrue);
    });

    test('isFailed returns true for cancelled status', () {
      final transaction = JekoTransaction.fromJson({
        'id': 1,
        'reference': 'REF-001',
        'type': 'recharge',
        'amount': 5000,
        'status': 'cancelled',
      });

      expect(transaction.isFailed, isTrue);
    });

    test('formattedAmount formats correctly', () {
      final transaction = JekoTransaction.fromJson({
        'id': 1,
        'reference': 'REF-001',
        'type': 'recharge',
        'amount': 5000.50,
        'currency': 'XOF',
      });

      expect(transaction.formattedAmount, '5001 XOF');
    });
  });

  group('JekoPaymentResult', () {
    test('fromJson creates instance with all fields', () {
      final json = {
        'success': true,
        'message': 'Paiement initié',
        'data': {
          'transaction_id': 123,
          'jeko_id': 'JKO123',
          'redirect_url': 'https://pay.jeko.io/redirect',
          'amount': 5000.0,
          'payment_method': 'orange_money',
        },
      };

      final result = JekoPaymentResult.fromJson(json);

      expect(result.success, isTrue);
      expect(result.message, 'Paiement initié');
      expect(result.transactionId, 123);
      expect(result.jekoId, 'JKO123');
      expect(result.redirectUrl, 'https://pay.jeko.io/redirect');
      expect(result.amount, 5000.0);
      expect(result.paymentMethod, 'orange_money');
    });

    test('fromJson handles missing data', () {
      final json = {
        'success': false,
        'message': 'Erreur',
      };

      final result = JekoPaymentResult.fromJson(json);

      expect(result.success, isFalse);
      expect(result.message, 'Erreur');
      expect(result.transactionId, isNull);
      expect(result.jekoId, isNull);
      expect(result.redirectUrl, isNull);
    });

    test('fromJson defaults success to false', () {
      final json = <String, dynamic>{};

      final result = JekoPaymentResult.fromJson(json);

      expect(result.success, isFalse);
    });
  });

  group('JekoPaymentRemoteDataSourceImpl', () {
    group('getPaymentMethods', () {
      test('returns list of payment methods on success', () async {
        when(() => mockApiClient.get('jeko/payment-methods')).thenAnswer(
          (_) async => Response(
            data: {
              'success': true,
              'data': [
                {'code': 'orange_money', 'name': 'Orange Money', 'icon': '🟠'},
                {'code': 'moov_money', 'name': 'Moov Money', 'icon': '🔵'},
              ],
            },
            statusCode: 200,
            requestOptions: RequestOptions(path: ''),
          ),
        );

        final result = await dataSource.getPaymentMethods();

        expect(result.length, 2);
        expect(result[0].code, 'orange_money');
        expect(result[1].code, 'moov_money');
      });

      test('returns empty list when success is false', () async {
        when(() => mockApiClient.get('jeko/payment-methods')).thenAnswer(
          (_) async => Response(
            data: {'success': false},
            statusCode: 200,
            requestOptions: RequestOptions(path: ''),
          ),
        );

        final result = await dataSource.getPaymentMethods();

        expect(result, isEmpty);
      });

      test('returns empty list on error', () async {
        when(() => mockApiClient.get('jeko/payment-methods')).thenThrow(
          Exception('Network error'),
        );

        final result = await dataSource.getPaymentMethods();

        expect(result, isEmpty);
      });

      test('returns empty list when data is null', () async {
        when(() => mockApiClient.get('jeko/payment-methods')).thenAnswer(
          (_) async => Response(
            data: {'success': true, 'data': null},
            statusCode: 200,
            requestOptions: RequestOptions(path: ''),
          ),
        );

        final result = await dataSource.getPaymentMethods();

        expect(result, isEmpty);
      });
    });

    group('initiateWalletRecharge', () {
      test('returns payment result on success', () async {
        when(() => mockApiClient.post(
          'jeko/recharge',
          data: {'amount': 5000.0, 'payment_method': 'orange_money'},
        )).thenAnswer(
          (_) async => Response(
            data: {
              'success': true,
              'message': 'Paiement initié',
              'data': {
                'transaction_id': 123,
                'jeko_id': 'JKO123',
                'redirect_url': 'https://pay.jeko.io',
              },
            },
            statusCode: 200,
            requestOptions: RequestOptions(path: ''),
          ),
        );

        final result = await dataSource.initiateWalletRecharge(
          amount: 5000.0,
          paymentMethod: 'orange_money',
        );

        expect(result.success, isTrue);
        expect(result.transactionId, 123);
        expect(result.jekoId, 'JKO123');
      });
    });

    group('initiateOrderPayment', () {
      test('returns payment result on success', () async {
        when(() => mockApiClient.post(
          'jeko/pay-order',
          data: {'order_id': '456', 'payment_method': 'moov_money'},
        )).thenAnswer(
          (_) async => Response(
            data: {
              'success': true,
              'message': 'Paiement commande initié',
              'data': {
                'transaction_id': 789,
                'jeko_id': 'JKO789',
                'redirect_url': 'https://pay.jeko.io/order',
              },
            },
            statusCode: 200,
            requestOptions: RequestOptions(path: ''),
          ),
        );

        final result = await dataSource.initiateOrderPayment(
          orderId: '456',
          paymentMethod: 'moov_money',
        );

        expect(result.success, isTrue);
        expect(result.transactionId, 789);
      });
    });

    group('checkTransactionStatus', () {
      test('returns transaction on success', () async {
        when(() => mockApiClient.get('jeko/status/123')).thenAnswer(
          (_) async => Response(
            data: {
              'success': true,
              'data': {
                'id': 123,
                'reference': 'REF-123',
                'type': 'recharge',
                'amount': 5000,
                'status': 'success',
                'created_at': '2026-01-27T10:00:00Z',
              },
            },
            statusCode: 200,
            requestOptions: RequestOptions(path: ''),
          ),
        );

        final result = await dataSource.checkTransactionStatus(123);

        expect(result.id, 123);
        expect(result.status, 'success');
      });

      test('throws exception when success is false', () async {
        when(() => mockApiClient.get('jeko/status/123')).thenAnswer(
          (_) async => Response(
            data: {
              'success': false,
              'message': 'Transaction non trouvée',
            },
            statusCode: 200,
            requestOptions: RequestOptions(path: ''),
          ),
        );

        expect(
          () => dataSource.checkTransactionStatus(123),
          throwsException,
        );
      });

      test('throws exception with default message when message is null', () async {
        when(() => mockApiClient.get('jeko/status/123')).thenAnswer(
          (_) async => Response(
            data: {'success': false},
            statusCode: 200,
            requestOptions: RequestOptions(path: ''),
          ),
        );

        expect(
          () => dataSource.checkTransactionStatus(123),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('getTransactionHistory', () {
      test('returns list of transactions on success', () async {
        when(() => mockApiClient.get(
          'jeko/transactions',
          queryParameters: {'page': 1},
        )).thenAnswer(
          (_) async => Response(
            data: {
              'success': true,
              'data': [
                {
                  'id': 1,
                  'reference': 'REF-001',
                  'type': 'recharge',
                  'amount': 5000,
                  'status': 'success',
                  'created_at': '2026-01-27T10:00:00Z',
                },
                {
                  'id': 2,
                  'reference': 'REF-002',
                  'type': 'payment',
                  'amount': 3000,
                  'status': 'pending',
                  'created_at': '2026-01-27T09:00:00Z',
                },
              ],
            },
            statusCode: 200,
            requestOptions: RequestOptions(path: ''),
          ),
        );

        final result = await dataSource.getTransactionHistory(page: 1);

        expect(result.length, 2);
        expect(result[0].id, 1);
        expect(result[1].id, 2);
      });

      test('returns empty list when success is false', () async {
        when(() => mockApiClient.get(
          'jeko/transactions',
          queryParameters: {'page': 1},
        )).thenAnswer(
          (_) async => Response(
            data: {'success': false},
            statusCode: 200,
            requestOptions: RequestOptions(path: ''),
          ),
        );

        final result = await dataSource.getTransactionHistory();

        expect(result, isEmpty);
      });

      test('passes page parameter correctly', () async {
        when(() => mockApiClient.get(
          'jeko/transactions',
          queryParameters: {'page': 3},
        )).thenAnswer(
          (_) async => Response(
            data: {'success': true, 'data': []},
            statusCode: 200,
            requestOptions: RequestOptions(path: ''),
          ),
        );

        await dataSource.getTransactionHistory(page: 3);

        verify(() => mockApiClient.get(
          'jeko/transactions',
          queryParameters: {'page': 3},
        )).called(1);
      });
    });

    group('paymentSuccessCallback', () {
      test('returns transaction on success', () async {
        when(() => mockApiClient.get(
          'jeko/callback/success',
          queryParameters: {'transaction_id': 123},
        )).thenAnswer(
          (_) async => Response(
            data: {
              'success': true,
              'data': {
                'id': 123,
                'reference': 'REF-123',
                'type': 'recharge',
                'amount': 5000,
                'status': 'success',
                'created_at': '2026-01-27T10:00:00Z',
              },
            },
            statusCode: 200,
            requestOptions: RequestOptions(path: ''),
          ),
        );

        final result = await dataSource.paymentSuccessCallback(123);

        expect(result.id, 123);
        expect(result.status, 'success');
      });

      test('throws exception when success is false', () async {
        when(() => mockApiClient.get(
          'jeko/callback/success',
          queryParameters: {'transaction_id': 123},
        )).thenAnswer(
          (_) async => Response(
            data: {
              'success': false,
              'message': 'Erreur de confirmation',
            },
            statusCode: 200,
            requestOptions: RequestOptions(path: ''),
          ),
        );

        expect(
          () => dataSource.paymentSuccessCallback(123),
          throwsException,
        );
      });

      test('throws with default message when message is null', () async {
        when(() => mockApiClient.get(
          'jeko/callback/success',
          queryParameters: {'transaction_id': 123},
        )).thenAnswer(
          (_) async => Response(
            data: {'success': false},
            statusCode: 200,
            requestOptions: RequestOptions(path: ''),
          ),
        );

        expect(
          () => dataSource.paymentSuccessCallback(123),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('paymentErrorCallback', () {
      test('calls error callback endpoint', () async {
        when(() => mockApiClient.get(
          'jeko/callback/error',
          queryParameters: {'transaction_id': 123},
        )).thenAnswer(
          (_) async => Response(
            data: {'success': true},
            statusCode: 200,
            requestOptions: RequestOptions(path: ''),
          ),
        );

        await dataSource.paymentErrorCallback(123);

        verify(() => mockApiClient.get(
          'jeko/callback/error',
          queryParameters: {'transaction_id': 123},
        )).called(1);
      });
    });
  });
}
