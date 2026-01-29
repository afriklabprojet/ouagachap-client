import 'package:flutter_test/flutter_test.dart';
import 'package:ouaga_chap_client/features/wallet/data/datasources/jeko_payment_datasource.dart';
import 'package:ouaga_chap_client/features/wallet/presentation/bloc/jeko_payment_event.dart';
import 'package:ouaga_chap_client/features/wallet/presentation/bloc/jeko_payment_state.dart';

void main() {
  group('JekoPaymentEvent', () {
    group('LoadPaymentMethods', () {
      test('creates instance', () {
        final event = LoadPaymentMethods();
        expect(event, isA<JekoPaymentEvent>());
      });

      test('props is empty', () {
        final event = LoadPaymentMethods();
        expect(event.props, isEmpty);
      });
    });

    group('InitiateWalletRecharge', () {
      test('creates instance with amount and paymentMethod', () {
        const event = InitiateWalletRecharge(
          amount: 5000.0,
          paymentMethod: 'orange_money',
        );

        expect(event.amount, 5000.0);
        expect(event.paymentMethod, 'orange_money');
      });

      test('props contains amount and paymentMethod', () {
        const event = InitiateWalletRecharge(
          amount: 1000.0,
          paymentMethod: 'mtn_money',
        );
        expect(event.props, [1000.0, 'mtn_money']);
      });

      test('two events with same props are equal', () {
        const event1 = InitiateWalletRecharge(
          amount: 2000.0,
          paymentMethod: 'wave',
        );
        const event2 = InitiateWalletRecharge(
          amount: 2000.0,
          paymentMethod: 'wave',
        );
        expect(event1, equals(event2));
      });
    });

    group('InitiateOrderPayment', () {
      test('creates instance with orderId and paymentMethod', () {
        const event = InitiateOrderPayment(
          orderId: 'order123',
          paymentMethod: 'orange_money',
        );

        expect(event.orderId, 'order123');
        expect(event.paymentMethod, 'orange_money');
      });

      test('props contains orderId and paymentMethod', () {
        const event = InitiateOrderPayment(
          orderId: 'order456',
          paymentMethod: 'moov_money',
        );
        expect(event.props, ['order456', 'moov_money']);
      });
    });

    group('CheckTransactionStatus', () {
      test('creates instance with transactionId', () {
        const event = CheckTransactionStatus(123);
        expect(event.transactionId, 123);
      });

      test('props contains transactionId', () {
        const event = CheckTransactionStatus(456);
        expect(event.props, [456]);
      });
    });

    group('LoadTransactionHistory', () {
      test('creates instance with default page', () {
        const event = LoadTransactionHistory();
        expect(event.page, 1);
      });

      test('creates instance with custom page', () {
        const event = LoadTransactionHistory(page: 3);
        expect(event.page, 3);
      });

      test('props contains page', () {
        const event = LoadTransactionHistory(page: 2);
        expect(event.props, [2]);
      });
    });

    group('PaymentSuccessCallback', () {
      test('creates instance with transactionId', () {
        const event = PaymentSuccessCallback(789);
        expect(event.transactionId, 789);
      });

      test('props contains transactionId', () {
        const event = PaymentSuccessCallback(101);
        expect(event.props, [101]);
      });
    });

    group('PaymentErrorCallback', () {
      test('creates instance with transactionId', () {
        const event = PaymentErrorCallback(999);
        expect(event.transactionId, 999);
      });

      test('props contains transactionId', () {
        const event = PaymentErrorCallback(111);
        expect(event.props, [111]);
      });
    });
  });

  group('JekoPaymentStatus', () {
    test('has all expected values', () {
      expect(JekoPaymentStatus.values, contains(JekoPaymentStatus.initial));
      expect(JekoPaymentStatus.values, contains(JekoPaymentStatus.loadingMethods));
      expect(JekoPaymentStatus.values, contains(JekoPaymentStatus.methodsLoaded));
      expect(JekoPaymentStatus.values, contains(JekoPaymentStatus.initiatingPayment));
      expect(JekoPaymentStatus.values, contains(JekoPaymentStatus.paymentInitiated));
      expect(JekoPaymentStatus.values, contains(JekoPaymentStatus.checkingStatus));
      expect(JekoPaymentStatus.values, contains(JekoPaymentStatus.statusChecked));
      expect(JekoPaymentStatus.values, contains(JekoPaymentStatus.loadingHistory));
      expect(JekoPaymentStatus.values, contains(JekoPaymentStatus.historyLoaded));
      expect(JekoPaymentStatus.values, contains(JekoPaymentStatus.success));
      expect(JekoPaymentStatus.values, contains(JekoPaymentStatus.error));
    });

    test('has 11 values', () {
      expect(JekoPaymentStatus.values.length, 11);
    });
  });

  group('JekoPaymentState', () {
    test('creates instance with default values', () {
      const state = JekoPaymentState();

      expect(state.status, JekoPaymentStatus.initial);
      expect(state.paymentMethods, isEmpty);
      expect(state.paymentResult, isNull);
      expect(state.currentTransaction, isNull);
      expect(state.transactionHistory, isEmpty);
      expect(state.errorMessage, isNull);
      expect(state.hasMoreHistory, isTrue);
      expect(state.currentPage, 1);
    });

    test('creates instance with custom values', () {
      final method = JekoPaymentMethod(
        code: 'orange',
        name: 'Orange Money',
        icon: '📱',
      );

      final state = JekoPaymentState(
        status: JekoPaymentStatus.methodsLoaded,
        paymentMethods: [method],
        currentPage: 2,
        hasMoreHistory: false,
      );

      expect(state.status, JekoPaymentStatus.methodsLoaded);
      expect(state.paymentMethods.length, 1);
      expect(state.currentPage, 2);
      expect(state.hasMoreHistory, isFalse);
    });

    group('copyWith', () {
      test('copies with new status', () {
        const state = JekoPaymentState();
        final newState = state.copyWith(status: JekoPaymentStatus.loadingMethods);

        expect(newState.status, JekoPaymentStatus.loadingMethods);
        expect(newState.paymentMethods, state.paymentMethods);
      });

      test('copies with new paymentMethods', () {
        const state = JekoPaymentState();
        final methods = [
          JekoPaymentMethod(code: 'mtn', name: 'MTN Money', icon: '💰'),
        ];
        final newState = state.copyWith(paymentMethods: methods);

        expect(newState.paymentMethods.length, 1);
        expect(newState.paymentMethods[0].code, 'mtn');
      });

      test('clears paymentResult when clearPaymentResult is true', () {
        final result = JekoPaymentResult(success: true, message: 'OK');
        final state = JekoPaymentState(paymentResult: result);
        final newState = state.copyWith(clearPaymentResult: true);

        expect(newState.paymentResult, isNull);
      });

      test('clears currentTransaction when clearCurrentTransaction is true', () {
        final transaction = JekoTransaction(
          id: 1,
          reference: 'REF001',
          type: 'recharge',
          amount: 1000.0,
          currency: 'XOF',
          fees: 0.0,
          status: 'success',
          statusLabel: 'Réussie',
          paymentMethod: 'orange',
          paymentMethodName: 'Orange Money',
          createdAt: DateTime.now(),
        );
        final state = JekoPaymentState(currentTransaction: transaction);
        final newState = state.copyWith(clearCurrentTransaction: true);

        expect(newState.currentTransaction, isNull);
      });

      test('clears error when clearError is true', () {
        const state = JekoPaymentState(errorMessage: 'Error message');
        final newState = state.copyWith(clearError: true);

        expect(newState.errorMessage, isNull);
      });
    });

    group('isLoading', () {
      test('returns true for loadingMethods', () {
        const state = JekoPaymentState(status: JekoPaymentStatus.loadingMethods);
        expect(state.isLoading, isTrue);
      });

      test('returns true for initiatingPayment', () {
        const state = JekoPaymentState(status: JekoPaymentStatus.initiatingPayment);
        expect(state.isLoading, isTrue);
      });

      test('returns true for checkingStatus', () {
        const state = JekoPaymentState(status: JekoPaymentStatus.checkingStatus);
        expect(state.isLoading, isTrue);
      });

      test('returns true for loadingHistory', () {
        const state = JekoPaymentState(status: JekoPaymentStatus.loadingHistory);
        expect(state.isLoading, isTrue);
      });

      test('returns false for initial', () {
        const state = JekoPaymentState(status: JekoPaymentStatus.initial);
        expect(state.isLoading, isFalse);
      });

      test('returns false for success', () {
        const state = JekoPaymentState(status: JekoPaymentStatus.success);
        expect(state.isLoading, isFalse);
      });
    });

    group('hasPaymentMethods', () {
      test('returns false when empty', () {
        const state = JekoPaymentState();
        expect(state.hasPaymentMethods, isFalse);
      });

      test('returns true when methods exist', () {
        final state = JekoPaymentState(
          paymentMethods: [
            JekoPaymentMethod(code: 'test', name: 'Test', icon: '💳'),
          ],
        );
        expect(state.hasPaymentMethods, isTrue);
      });
    });

    group('hasRedirectUrl', () {
      test('returns false when paymentResult is null', () {
        const state = JekoPaymentState();
        expect(state.hasRedirectUrl, isFalse);
      });

      test('returns false when redirectUrl is null', () {
        final state = JekoPaymentState(
          paymentResult: JekoPaymentResult(success: true),
        );
        expect(state.hasRedirectUrl, isFalse);
      });

      test('returns true when redirectUrl exists', () {
        final state = JekoPaymentState(
          paymentResult: JekoPaymentResult(
            success: true,
            redirectUrl: 'https://pay.jeko.com',
          ),
        );
        expect(state.hasRedirectUrl, isTrue);
      });
    });

    group('payment status getters', () {
      test('isPaymentSuccessful returns true for success status', () {
        final transaction = JekoTransaction(
          id: 1,
          reference: 'REF',
          type: 'recharge',
          amount: 1000.0,
          currency: 'XOF',
          fees: 0.0,
          status: 'success',
          statusLabel: 'Réussie',
          paymentMethod: 'orange',
          paymentMethodName: 'Orange Money',
          createdAt: DateTime.now(),
        );
        final state = JekoPaymentState(currentTransaction: transaction);
        expect(state.isPaymentSuccessful, isTrue);
        expect(state.isPaymentFailed, isFalse);
        expect(state.isPaymentPending, isFalse);
      });

      test('isPaymentFailed returns true for error status', () {
        final transaction = JekoTransaction(
          id: 1,
          reference: 'REF',
          type: 'recharge',
          amount: 1000.0,
          currency: 'XOF',
          fees: 0.0,
          status: 'error',
          statusLabel: 'Échouée',
          paymentMethod: 'orange',
          paymentMethodName: 'Orange Money',
          createdAt: DateTime.now(),
        );
        final state = JekoPaymentState(currentTransaction: transaction);
        expect(state.isPaymentSuccessful, isFalse);
        expect(state.isPaymentFailed, isTrue);
        expect(state.isPaymentPending, isFalse);
      });

      test('isPaymentPending returns true for pending status', () {
        final transaction = JekoTransaction(
          id: 1,
          reference: 'REF',
          type: 'recharge',
          amount: 1000.0,
          currency: 'XOF',
          fees: 0.0,
          status: 'pending',
          statusLabel: 'En attente',
          paymentMethod: 'orange',
          paymentMethodName: 'Orange Money',
          createdAt: DateTime.now(),
        );
        final state = JekoPaymentState(currentTransaction: transaction);
        expect(state.isPaymentSuccessful, isFalse);
        expect(state.isPaymentFailed, isFalse);
        expect(state.isPaymentPending, isTrue);
      });

      test('returns false for all when currentTransaction is null', () {
        const state = JekoPaymentState();
        expect(state.isPaymentSuccessful, isFalse);
        expect(state.isPaymentFailed, isFalse);
        expect(state.isPaymentPending, isFalse);
      });
    });

    test('props contains all fields', () {
      const state = JekoPaymentState();
      expect(state.props.length, 8);
    });
  });

  group('JekoPaymentMethod', () {
    test('creates instance', () {
      final method = JekoPaymentMethod(
        code: 'orange_money',
        name: 'Orange Money',
        icon: '🟠',
      );

      expect(method.code, 'orange_money');
      expect(method.name, 'Orange Money');
      expect(method.icon, '🟠');
    });

    test('fromJson creates instance correctly', () {
      final json = {
        'code': 'mtn_money',
        'name': 'MTN Money',
        'icon': '💛',
      };

      final method = JekoPaymentMethod.fromJson(json);

      expect(method.code, 'mtn_money');
      expect(method.name, 'MTN Money');
      expect(method.icon, '💛');
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
    test('creates instance with all fields', () {
      final transaction = JekoTransaction(
        id: 1,
        jekoId: 'JEKO123',
        reference: 'REF001',
        type: 'recharge',
        amount: 5000.0,
        currency: 'XOF',
        fees: 100.0,
        status: 'success',
        statusLabel: 'Réussie',
        paymentMethod: 'orange_money',
        paymentMethodName: 'Orange Money',
        createdAt: DateTime(2024, 1, 15),
        executedAt: DateTime(2024, 1, 15, 10, 30),
      );

      expect(transaction.id, 1);
      expect(transaction.jekoId, 'JEKO123');
      expect(transaction.reference, 'REF001');
      expect(transaction.type, 'recharge');
      expect(transaction.amount, 5000.0);
      expect(transaction.currency, 'XOF');
      expect(transaction.fees, 100.0);
      expect(transaction.status, 'success');
      expect(transaction.statusLabel, 'Réussie');
      expect(transaction.paymentMethod, 'orange_money');
      expect(transaction.paymentMethodName, 'Orange Money');
      expect(transaction.createdAt, DateTime(2024, 1, 15));
      expect(transaction.executedAt, DateTime(2024, 1, 15, 10, 30));
    });

    test('fromJson creates instance correctly', () {
      final json = {
        'id': 2,
        'jeko_id': 'JEKO456',
        'reference': 'REF002',
        'type': 'payment',
        'amount': 3000,
        'currency': 'XOF',
        'fees': 50,
        'status': 'pending',
        'status_label': 'En attente',
        'payment_method': 'mtn_money',
        'payment_method_name': 'MTN Money',
        'created_at': '2024-01-20T08:00:00Z',
        'executed_at': null,
      };

      final transaction = JekoTransaction.fromJson(json);

      expect(transaction.id, 2);
      expect(transaction.jekoId, 'JEKO456');
      expect(transaction.reference, 'REF002');
      expect(transaction.amount, 3000.0);
      expect(transaction.isPending, isTrue);
    });

    test('fromJson handles null executed_at', () {
      final json = {
        'id': 1,
        'reference': 'REF',
        'type': 'recharge',
        'amount': 1000,
        'created_at': '2024-01-15T10:00:00Z',
      };

      final transaction = JekoTransaction.fromJson(json);

      expect(transaction.executedAt, isNull);
    });

    group('status getters', () {
      test('isPending returns true for pending status', () {
        final transaction = JekoTransaction(
          id: 1,
          reference: 'REF',
          type: 'recharge',
          amount: 1000.0,
          currency: 'XOF',
          fees: 0.0,
          status: 'pending',
          statusLabel: 'En attente',
          paymentMethod: 'orange',
          paymentMethodName: 'Orange Money',
          createdAt: DateTime.now(),
        );
        expect(transaction.isPending, isTrue);
      });

      test('isSuccessful returns true for success status', () {
        final transaction = JekoTransaction(
          id: 1,
          reference: 'REF',
          type: 'recharge',
          amount: 1000.0,
          currency: 'XOF',
          fees: 0.0,
          status: 'success',
          statusLabel: 'Réussie',
          paymentMethod: 'orange',
          paymentMethodName: 'Orange Money',
          createdAt: DateTime.now(),
        );
        expect(transaction.isSuccessful, isTrue);
      });

      test('isFailed returns true for error status', () {
        final transaction = JekoTransaction(
          id: 1,
          reference: 'REF',
          type: 'recharge',
          amount: 1000.0,
          currency: 'XOF',
          fees: 0.0,
          status: 'error',
          statusLabel: 'Erreur',
          paymentMethod: 'orange',
          paymentMethodName: 'Orange Money',
          createdAt: DateTime.now(),
        );
        expect(transaction.isFailed, isTrue);
      });

      test('isFailed returns true for expired status', () {
        final transaction = JekoTransaction(
          id: 1,
          reference: 'REF',
          type: 'recharge',
          amount: 1000.0,
          currency: 'XOF',
          fees: 0.0,
          status: 'expired',
          statusLabel: 'Expirée',
          paymentMethod: 'orange',
          paymentMethodName: 'Orange Money',
          createdAt: DateTime.now(),
        );
        expect(transaction.isFailed, isTrue);
      });

      test('isFailed returns true for cancelled status', () {
        final transaction = JekoTransaction(
          id: 1,
          reference: 'REF',
          type: 'recharge',
          amount: 1000.0,
          currency: 'XOF',
          fees: 0.0,
          status: 'cancelled',
          statusLabel: 'Annulée',
          paymentMethod: 'orange',
          paymentMethodName: 'Orange Money',
          createdAt: DateTime.now(),
        );
        expect(transaction.isFailed, isTrue);
      });
    });

    test('formattedAmount returns correct format', () {
      final transaction = JekoTransaction(
        id: 1,
        reference: 'REF',
        type: 'recharge',
        amount: 5000.0,
        currency: 'XOF',
        fees: 0.0,
        status: 'success',
        statusLabel: 'Réussie',
        paymentMethod: 'orange',
        paymentMethodName: 'Orange Money',
        createdAt: DateTime.now(),
      );
      expect(transaction.formattedAmount, '5000 XOF');
    });
  });

  group('JekoPaymentResult', () {
    test('creates instance with all fields', () {
      final result = JekoPaymentResult(
        success: true,
        message: 'Payment initiated',
        transactionId: 123,
        jekoId: 'JEKO789',
        redirectUrl: 'https://pay.jeko.com/redirect',
        amount: 2000.0,
        paymentMethod: 'orange_money',
      );

      expect(result.success, isTrue);
      expect(result.message, 'Payment initiated');
      expect(result.transactionId, 123);
      expect(result.jekoId, 'JEKO789');
      expect(result.redirectUrl, 'https://pay.jeko.com/redirect');
      expect(result.amount, 2000.0);
      expect(result.paymentMethod, 'orange_money');
    });

    test('fromJson creates instance correctly', () {
      final json = {
        'success': true,
        'message': 'OK',
        'data': {
          'transaction_id': 456,
          'jeko_id': 'JEKO001',
          'redirect_url': 'https://example.com',
          'amount': 3000,
          'payment_method': 'mtn_money',
        },
      };

      final result = JekoPaymentResult.fromJson(json);

      expect(result.success, isTrue);
      expect(result.message, 'OK');
      expect(result.transactionId, 456);
      expect(result.jekoId, 'JEKO001');
      expect(result.redirectUrl, 'https://example.com');
      expect(result.amount, 3000.0);
      expect(result.paymentMethod, 'mtn_money');
    });

    test('fromJson handles null data', () {
      final json = {
        'success': false,
        'message': 'Error',
      };

      final result = JekoPaymentResult.fromJson(json);

      expect(result.success, isFalse);
      expect(result.message, 'Error');
      expect(result.transactionId, isNull);
    });
  });
}
