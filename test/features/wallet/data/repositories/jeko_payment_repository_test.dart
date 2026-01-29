import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ouaga_chap_client/features/wallet/data/datasources/jeko_payment_datasource.dart';
import 'package:ouaga_chap_client/features/wallet/data/repositories/jeko_payment_repository.dart';

class MockJekoPaymentRemoteDataSource extends Mock
    implements JekoPaymentRemoteDataSource {}

void main() {
  late JekoPaymentRepository repository;
  late MockJekoPaymentRemoteDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockJekoPaymentRemoteDataSource();
    repository = JekoPaymentRepository(mockDataSource);
  });

  group('JekoPaymentRepository', () {
    group('getPaymentMethods', () {
      final testMethods = [
        JekoPaymentMethod(code: 'orange', name: 'Orange Money', icon: '🟠'),
        JekoPaymentMethod(code: 'moov', name: 'Moov Money', icon: '🔵'),
      ];

      test('should return payment methods from datasource', () async {
        // Arrange
        when(() => mockDataSource.getPaymentMethods())
            .thenAnswer((_) async => testMethods);

        // Act
        final result = await repository.getPaymentMethods();

        // Assert
        expect(result.length, equals(2));
        expect(result[0].code, equals('orange'));
        expect(result[1].name, equals('Moov Money'));
        verify(() => mockDataSource.getPaymentMethods()).called(1);
      });

      test('should throw exception when datasource fails', () async {
        // Arrange
        when(() => mockDataSource.getPaymentMethods())
            .thenThrow(Exception('Network error'));

        // Act & Assert
        expect(
          () => repository.getPaymentMethods(),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('initiateWalletRecharge', () {
      final testResult = JekoPaymentResult(
        success: true,
        message: 'Recharge initiée',
        transactionId: 123,
        redirectUrl: 'https://payment.url',
      );

      test('should return payment result from datasource', () async {
        // Arrange
        when(() => mockDataSource.initiateWalletRecharge(
              amount: any(named: 'amount'),
              paymentMethod: any(named: 'paymentMethod'),
            )).thenAnswer((_) async => testResult);

        // Act
        final result = await repository.initiateWalletRecharge(
          amount: 1000.0,
          paymentMethod: 'orange',
        );

        // Assert
        expect(result.success, isTrue);
        expect(result.transactionId, equals(123));
        verify(() => mockDataSource.initiateWalletRecharge(
              amount: 1000.0,
              paymentMethod: 'orange',
            )).called(1);
      });

      test('should throw exception when datasource fails', () async {
        // Arrange
        when(() => mockDataSource.initiateWalletRecharge(
              amount: any(named: 'amount'),
              paymentMethod: any(named: 'paymentMethod'),
            )).thenThrow(Exception('Payment error'));

        // Act & Assert
        expect(
          () => repository.initiateWalletRecharge(
            amount: 1000.0,
            paymentMethod: 'orange',
          ),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('initiateOrderPayment', () {
      final testResult = JekoPaymentResult(
        success: true,
        message: 'Paiement initié',
        transactionId: 456,
      );

      test('should return payment result from datasource', () async {
        // Arrange
        when(() => mockDataSource.initiateOrderPayment(
              orderId: any(named: 'orderId'),
              paymentMethod: any(named: 'paymentMethod'),
            )).thenAnswer((_) async => testResult);

        // Act
        final result = await repository.initiateOrderPayment(
          orderId: 'ORDER123',
          paymentMethod: 'moov',
        );

        // Assert
        expect(result.success, isTrue);
        expect(result.transactionId, equals(456));
        verify(() => mockDataSource.initiateOrderPayment(
              orderId: 'ORDER123',
              paymentMethod: 'moov',
            )).called(1);
      });

      test('should throw exception when datasource fails', () async {
        // Arrange
        when(() => mockDataSource.initiateOrderPayment(
              orderId: any(named: 'orderId'),
              paymentMethod: any(named: 'paymentMethod'),
            )).thenThrow(Exception('Payment error'));

        // Act & Assert
        expect(
          () => repository.initiateOrderPayment(
            orderId: 'ORDER123',
            paymentMethod: 'moov',
          ),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('checkTransactionStatus', () {
      final testTransaction = JekoTransaction(
        id: 123,
        reference: 'REF123',
        type: 'recharge',
        amount: 1000.0,
        currency: 'XOF',
        fees: 50.0,
        status: 'success',
        statusLabel: 'Succès',
        paymentMethod: 'orange',
        paymentMethodName: 'Orange Money',
        createdAt: DateTime(2024, 1, 15),
      );

      test('should return transaction from datasource', () async {
        // Arrange
        when(() => mockDataSource.checkTransactionStatus(123))
            .thenAnswer((_) async => testTransaction);

        // Act
        final result = await repository.checkTransactionStatus(123);

        // Assert
        expect(result.id, equals(123));
        expect(result.status, equals('success'));
        verify(() => mockDataSource.checkTransactionStatus(123)).called(1);
      });

      test('should throw exception when datasource fails', () async {
        // Arrange
        when(() => mockDataSource.checkTransactionStatus(any()))
            .thenThrow(Exception('Network error'));

        // Act & Assert
        expect(
          () => repository.checkTransactionStatus(123),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('getTransactionHistory', () {
      final testTransactions = [
        JekoTransaction(
          id: 1,
          reference: 'REF1',
          type: 'recharge',
          amount: 1000.0,
          currency: 'XOF',
          fees: 50.0,
          status: 'success',
          statusLabel: 'Succès',
          paymentMethod: 'orange',
          paymentMethodName: 'Orange Money',
          createdAt: DateTime(2024, 1, 15),
        ),
        JekoTransaction(
          id: 2,
          reference: 'REF2',
          type: 'payment',
          amount: 2000.0,
          currency: 'XOF',
          fees: 100.0,
          status: 'pending',
          statusLabel: 'En attente',
          paymentMethod: 'moov',
          paymentMethodName: 'Moov Money',
          createdAt: DateTime(2024, 1, 14),
        ),
      ];

      test('should return transaction list from datasource', () async {
        // Arrange
        when(() => mockDataSource.getTransactionHistory(page: 1))
            .thenAnswer((_) async => testTransactions);

        // Act
        final result = await repository.getTransactionHistory(page: 1);

        // Assert
        expect(result.length, equals(2));
        expect(result[0].reference, equals('REF1'));
        verify(() => mockDataSource.getTransactionHistory(page: 1)).called(1);
      });

      test('should use default page 1', () async {
        // Arrange
        when(() => mockDataSource.getTransactionHistory(page: 1))
            .thenAnswer((_) async => testTransactions);

        // Act
        await repository.getTransactionHistory();

        // Assert
        verify(() => mockDataSource.getTransactionHistory(page: 1)).called(1);
      });

      test('should throw exception when datasource fails', () async {
        // Arrange
        when(() => mockDataSource.getTransactionHistory(page: any(named: 'page')))
            .thenThrow(Exception('Network error'));

        // Act & Assert
        expect(
          () => repository.getTransactionHistory(),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('paymentSuccessCallback', () {
      final testTransaction = JekoTransaction(
        id: 123,
        reference: 'REF123',
        type: 'recharge',
        amount: 1000.0,
        currency: 'XOF',
        fees: 50.0,
        status: 'success',
        statusLabel: 'Succès',
        paymentMethod: 'orange',
        paymentMethodName: 'Orange Money',
        createdAt: DateTime(2024, 1, 15),
      );

      test('should return confirmed transaction from datasource', () async {
        // Arrange
        when(() => mockDataSource.paymentSuccessCallback(123))
            .thenAnswer((_) async => testTransaction);

        // Act
        final result = await repository.paymentSuccessCallback(123);

        // Assert
        expect(result.status, equals('success'));
        verify(() => mockDataSource.paymentSuccessCallback(123)).called(1);
      });

      test('should throw exception when datasource fails', () async {
        // Arrange
        when(() => mockDataSource.paymentSuccessCallback(any()))
            .thenThrow(Exception('Callback error'));

        // Act & Assert
        expect(
          () => repository.paymentSuccessCallback(123),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('paymentErrorCallback', () {
      test('should call datasource error callback', () async {
        // Arrange
        when(() => mockDataSource.paymentErrorCallback(123))
            .thenAnswer((_) async {});

        // Act
        await repository.paymentErrorCallback(123);

        // Assert
        verify(() => mockDataSource.paymentErrorCallback(123)).called(1);
      });

      test('should ignore exception when datasource fails', () async {
        // Arrange
        when(() => mockDataSource.paymentErrorCallback(any()))
            .thenThrow(Exception('Callback error'));

        // Act & Assert - Should not throw
        await repository.paymentErrorCallback(123);
      });
    });
  });

  group('JekoPaymentMethod', () {
    test('fromJson creates instance correctly', () {
      final json = {
        'code': 'orange',
        'name': 'Orange Money',
        'icon': '🟠',
      };

      final method = JekoPaymentMethod.fromJson(json);

      expect(method.code, equals('orange'));
      expect(method.name, equals('Orange Money'));
      expect(method.icon, equals('🟠'));
    });

    test('fromJson handles missing values with defaults', () {
      final json = <String, dynamic>{};

      final method = JekoPaymentMethod.fromJson(json);

      expect(method.code, equals(''));
      expect(method.name, equals(''));
      expect(method.icon, equals('💳'));
    });
  });

  group('JekoTransaction', () {
    test('fromJson creates instance correctly', () {
      final json = {
        'id': 123,
        'jeko_id': 'JEKO123',
        'reference': 'REF123',
        'type': 'recharge',
        'amount': 1000,
        'currency': 'XOF',
        'fees': 50,
        'status': 'success',
        'status_label': 'Succès',
        'payment_method': 'orange',
        'payment_method_name': 'Orange Money',
        'created_at': '2024-01-15T10:00:00Z',
        'executed_at': '2024-01-15T10:01:00Z',
      };

      final transaction = JekoTransaction.fromJson(json);

      expect(transaction.id, equals(123));
      expect(transaction.jekoId, equals('JEKO123'));
      expect(transaction.reference, equals('REF123'));
      expect(transaction.type, equals('recharge'));
      expect(transaction.amount, equals(1000.0));
      expect(transaction.currency, equals('XOF'));
      expect(transaction.fees, equals(50.0));
      expect(transaction.status, equals('success'));
      expect(transaction.statusLabel, equals('Succès'));
      expect(transaction.paymentMethod, equals('orange'));
      expect(transaction.paymentMethodName, equals('Orange Money'));
      expect(transaction.executedAt, isNotNull);
    });

    test('fromJson handles missing values with defaults', () {
      final json = <String, dynamic>{};

      final transaction = JekoTransaction.fromJson(json);

      expect(transaction.id, equals(0));
      expect(transaction.jekoId, isNull);
      expect(transaction.reference, equals(''));
      expect(transaction.type, equals(''));
      expect(transaction.amount, equals(0.0));
      expect(transaction.currency, equals('XOF'));
      expect(transaction.fees, equals(0.0));
      expect(transaction.status, equals('pending'));
      expect(transaction.statusLabel, equals('En attente'));
      expect(transaction.executedAt, isNull);
    });

    test('isPending returns true for pending status', () {
      final transaction = JekoTransaction(
        id: 1,
        reference: 'REF',
        type: 'recharge',
        amount: 100.0,
        currency: 'XOF',
        fees: 5.0,
        status: 'pending',
        statusLabel: 'En attente',
        paymentMethod: 'orange',
        paymentMethodName: 'Orange Money',
        createdAt: DateTime.now(),
      );

      expect(transaction.isPending, isTrue);
      expect(transaction.isSuccessful, isFalse);
      expect(transaction.isFailed, isFalse);
    });

    test('isSuccessful returns true for success status', () {
      final transaction = JekoTransaction(
        id: 1,
        reference: 'REF',
        type: 'recharge',
        amount: 100.0,
        currency: 'XOF',
        fees: 5.0,
        status: 'success',
        statusLabel: 'Succès',
        paymentMethod: 'orange',
        paymentMethodName: 'Orange Money',
        createdAt: DateTime.now(),
      );

      expect(transaction.isPending, isFalse);
      expect(transaction.isSuccessful, isTrue);
      expect(transaction.isFailed, isFalse);
    });

    test('isFailed returns true for error/expired/cancelled status', () {
      for (final status in ['error', 'expired', 'cancelled']) {
        final transaction = JekoTransaction(
          id: 1,
          reference: 'REF',
          type: 'recharge',
          amount: 100.0,
          currency: 'XOF',
          fees: 5.0,
          status: status,
          statusLabel: 'Échoué',
          paymentMethod: 'orange',
          paymentMethodName: 'Orange Money',
          createdAt: DateTime.now(),
        );

        expect(transaction.isFailed, isTrue, reason: 'status: $status');
      }
    });

    test('formattedAmount returns correctly formatted string', () {
      final transaction = JekoTransaction(
        id: 1,
        reference: 'REF',
        type: 'recharge',
        amount: 1500.0,
        currency: 'XOF',
        fees: 5.0,
        status: 'success',
        statusLabel: 'Succès',
        paymentMethod: 'orange',
        paymentMethodName: 'Orange Money',
        createdAt: DateTime.now(),
      );

      expect(transaction.formattedAmount, equals('1500 XOF'));
    });
  });

  group('JekoPaymentResult', () {
    test('fromJson creates instance correctly', () {
      final json = {
        'success': true,
        'message': 'Paiement initié',
        'data': {
          'transaction_id': 123,
          'jeko_id': 'JEKO123',
          'redirect_url': 'https://payment.url',
          'amount': 1000.0,
          'payment_method': 'orange',
        },
      };

      final result = JekoPaymentResult.fromJson(json);

      expect(result.success, isTrue);
      expect(result.message, equals('Paiement initié'));
      expect(result.transactionId, equals(123));
      expect(result.jekoId, equals('JEKO123'));
      expect(result.redirectUrl, equals('https://payment.url'));
      expect(result.amount, equals(1000.0));
      expect(result.paymentMethod, equals('orange'));
    });

    test('fromJson handles missing data with defaults', () {
      final json = <String, dynamic>{};

      final result = JekoPaymentResult.fromJson(json);

      expect(result.success, isFalse);
      expect(result.message, isNull);
      expect(result.transactionId, isNull);
    });
  });
}
