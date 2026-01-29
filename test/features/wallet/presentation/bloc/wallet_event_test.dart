import 'package:flutter_test/flutter_test.dart';
import 'package:ouaga_chap_client/features/wallet/presentation/bloc/wallet_event.dart';

void main() {
  group('WalletEvent', () {
    group('LoadWallet', () {
      test('should be a WalletEvent', () {
        const event = LoadWallet();
        expect(event, isA<WalletEvent>());
      });

      test('props should be empty', () {
        const event = LoadWallet();
        expect(event.props, isEmpty);
      });

      test('two instances should be equal', () {
        const event1 = LoadWallet();
        const event2 = LoadWallet();
        expect(event1, equals(event2));
      });
    });

    group('InitiateRecharge', () {
      test('should be a WalletEvent', () {
        const event = InitiateRecharge(
          amount: 1000,
          provider: 'orange_money',
          phoneNumber: '78123456',
        );
        expect(event, isA<WalletEvent>());
      });

      test('props should contain amount, provider, and phoneNumber', () {
        const event = InitiateRecharge(
          amount: 1000,
          provider: 'orange_money',
          phoneNumber: '78123456',
        );
        expect(event.props, [1000, 'orange_money', '78123456']);
      });

      test('two instances with same values should be equal', () {
        const event1 = InitiateRecharge(
          amount: 1000,
          provider: 'orange_money',
          phoneNumber: '78123456',
        );
        const event2 = InitiateRecharge(
          amount: 1000,
          provider: 'orange_money',
          phoneNumber: '78123456',
        );
        expect(event1, equals(event2));
      });

      test('two instances with different amount should not be equal', () {
        const event1 = InitiateRecharge(
          amount: 1000,
          provider: 'orange_money',
          phoneNumber: '78123456',
        );
        const event2 = InitiateRecharge(
          amount: 2000,
          provider: 'orange_money',
          phoneNumber: '78123456',
        );
        expect(event1, isNot(equals(event2)));
      });

      test('two instances with different provider should not be equal', () {
        const event1 = InitiateRecharge(
          amount: 1000,
          provider: 'orange_money',
          phoneNumber: '78123456',
        );
        const event2 = InitiateRecharge(
          amount: 1000,
          provider: 'moov_money',
          phoneNumber: '78123456',
        );
        expect(event1, isNot(equals(event2)));
      });

      test('two instances with different phoneNumber should not be equal', () {
        const event1 = InitiateRecharge(
          amount: 1000,
          provider: 'orange_money',
          phoneNumber: '78123456',
        );
        const event2 = InitiateRecharge(
          amount: 1000,
          provider: 'orange_money',
          phoneNumber: '78654321',
        );
        expect(event1, isNot(equals(event2)));
      });
    });
  });
}
