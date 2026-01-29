import 'package:flutter_test/flutter_test.dart';
import 'package:ouaga_chap_client/features/wallet/presentation/bloc/jeko_payment_event.dart';

void main() {
  group('JekoPaymentEvent', () {
    group('LoadPaymentMethods', () {
      test('should be a JekoPaymentEvent', () {
        final event = LoadPaymentMethods();
        expect(event, isA<JekoPaymentEvent>());
      });

      test('props should be empty', () {
        final event = LoadPaymentMethods();
        expect(event.props, isEmpty);
      });
    });

    group('InitiateWalletRecharge', () {
      test('should be a JekoPaymentEvent', () {
        const event = InitiateWalletRecharge(
          amount: 5000.0,
          paymentMethod: 'orange_money',
        );
        expect(event, isA<JekoPaymentEvent>());
      });

      test('props should contain amount and paymentMethod', () {
        const event = InitiateWalletRecharge(
          amount: 5000.0,
          paymentMethod: 'orange_money',
        );
        expect(event.props, [5000.0, 'orange_money']);
      });

      test('two instances with same values should be equal', () {
        const event1 = InitiateWalletRecharge(
          amount: 5000.0,
          paymentMethod: 'orange_money',
        );
        const event2 = InitiateWalletRecharge(
          amount: 5000.0,
          paymentMethod: 'orange_money',
        );
        expect(event1, equals(event2));
      });

      test('two instances with different amount should not be equal', () {
        const event1 = InitiateWalletRecharge(
          amount: 5000.0,
          paymentMethod: 'orange_money',
        );
        const event2 = InitiateWalletRecharge(
          amount: 10000.0,
          paymentMethod: 'orange_money',
        );
        expect(event1, isNot(equals(event2)));
      });

      test('two instances with different paymentMethod should not be equal', () {
        const event1 = InitiateWalletRecharge(
          amount: 5000.0,
          paymentMethod: 'orange_money',
        );
        const event2 = InitiateWalletRecharge(
          amount: 5000.0,
          paymentMethod: 'moov_money',
        );
        expect(event1, isNot(equals(event2)));
      });
    });

    group('InitiateOrderPayment', () {
      test('should be a JekoPaymentEvent', () {
        const event = InitiateOrderPayment(
          orderId: 'order_123',
          paymentMethod: 'wallet',
        );
        expect(event, isA<JekoPaymentEvent>());
      });

      test('props should contain orderId and paymentMethod', () {
        const event = InitiateOrderPayment(
          orderId: 'order_123',
          paymentMethod: 'wallet',
        );
        expect(event.props, ['order_123', 'wallet']);
      });

      test('two instances with same values should be equal', () {
        const event1 = InitiateOrderPayment(
          orderId: 'order_123',
          paymentMethod: 'wallet',
        );
        const event2 = InitiateOrderPayment(
          orderId: 'order_123',
          paymentMethod: 'wallet',
        );
        expect(event1, equals(event2));
      });

      test('two instances with different orderId should not be equal', () {
        const event1 = InitiateOrderPayment(
          orderId: 'order_123',
          paymentMethod: 'wallet',
        );
        const event2 = InitiateOrderPayment(
          orderId: 'order_456',
          paymentMethod: 'wallet',
        );
        expect(event1, isNot(equals(event2)));
      });
    });

    group('CheckTransactionStatus', () {
      test('should be a JekoPaymentEvent', () {
        const event = CheckTransactionStatus(123);
        expect(event, isA<JekoPaymentEvent>());
      });

      test('props should contain transactionId', () {
        const event = CheckTransactionStatus(123);
        expect(event.props, [123]);
      });

      test('two instances with same transactionId should be equal', () {
        const event1 = CheckTransactionStatus(123);
        const event2 = CheckTransactionStatus(123);
        expect(event1, equals(event2));
      });

      test('two instances with different transactionId should not be equal', () {
        const event1 = CheckTransactionStatus(123);
        const event2 = CheckTransactionStatus(456);
        expect(event1, isNot(equals(event2)));
      });
    });

    group('LoadTransactionHistory', () {
      test('should be a JekoPaymentEvent', () {
        const event = LoadTransactionHistory();
        expect(event, isA<JekoPaymentEvent>());
      });

      test('default page should be 1', () {
        const event = LoadTransactionHistory();
        expect(event.page, 1);
        expect(event.props, [1]);
      });

      test('props should contain custom page', () {
        const event = LoadTransactionHistory(page: 5);
        expect(event.page, 5);
        expect(event.props, [5]);
      });

      test('two instances with same page should be equal', () {
        const event1 = LoadTransactionHistory(page: 2);
        const event2 = LoadTransactionHistory(page: 2);
        expect(event1, equals(event2));
      });

      test('two instances with different page should not be equal', () {
        const event1 = LoadTransactionHistory(page: 1);
        const event2 = LoadTransactionHistory(page: 2);
        expect(event1, isNot(equals(event2)));
      });
    });

    group('PaymentSuccessCallback', () {
      test('should be a JekoPaymentEvent', () {
        const event = PaymentSuccessCallback(123);
        expect(event, isA<JekoPaymentEvent>());
      });

      test('props should contain transactionId', () {
        const event = PaymentSuccessCallback(123);
        expect(event.props, [123]);
      });

      test('two instances with same transactionId should be equal', () {
        const event1 = PaymentSuccessCallback(123);
        const event2 = PaymentSuccessCallback(123);
        expect(event1, equals(event2));
      });

      test('two instances with different transactionId should not be equal', () {
        const event1 = PaymentSuccessCallback(123);
        const event2 = PaymentSuccessCallback(456);
        expect(event1, isNot(equals(event2)));
      });
    });

    group('PaymentErrorCallback', () {
      test('should be a JekoPaymentEvent', () {
        const event = PaymentErrorCallback(123);
        expect(event, isA<JekoPaymentEvent>());
      });

      test('props should contain transactionId', () {
        const event = PaymentErrorCallback(123);
        expect(event.props, [123]);
      });

      test('two instances with same transactionId should be equal', () {
        const event1 = PaymentErrorCallback(123);
        const event2 = PaymentErrorCallback(123);
        expect(event1, equals(event2));
      });

      test('two instances with different transactionId should not be equal', () {
        const event1 = PaymentErrorCallback(123);
        const event2 = PaymentErrorCallback(456);
        expect(event1, isNot(equals(event2)));
      });
    });

    group('ResetPaymentState', () {
      test('should be a JekoPaymentEvent', () {
        final event = ResetPaymentState();
        expect(event, isA<JekoPaymentEvent>());
      });

      test('props should be empty', () {
        final event = ResetPaymentState();
        expect(event.props, isEmpty);
      });
    });
  });
}
