import 'package:flutter_test/flutter_test.dart';
import 'package:ouaga_chap_client/features/wallet/domain/entities/wallet.dart';
import 'package:ouaga_chap_client/features/wallet/presentation/bloc/wallet_event.dart';
import 'package:ouaga_chap_client/features/wallet/presentation/bloc/wallet_state.dart';

void main() {
  group('WalletEvent', () {
    group('LoadWallet', () {
      test('creates instance', () {
        const event = LoadWallet();
        expect(event, isA<WalletEvent>());
      });

      test('props is empty', () {
        const event = LoadWallet();
        expect(event.props, isEmpty);
      });

      test('two instances are equal', () {
        const event1 = LoadWallet();
        const event2 = LoadWallet();
        expect(event1, equals(event2));
      });
    });

    group('InitiateRecharge', () {
      test('creates instance with required fields', () {
        const event = InitiateRecharge(
          amount: 5000,
          provider: 'orange',
          phoneNumber: '70123456',
        );

        expect(event.amount, 5000);
        expect(event.provider, 'orange');
        expect(event.phoneNumber, '70123456');
      });

      test('props contains all fields', () {
        const event = InitiateRecharge(
          amount: 5000,
          provider: 'orange',
          phoneNumber: '70123456',
        );
        expect(event.props, [5000, 'orange', '70123456']);
      });

      test('two events with same props are equal', () {
        const event1 = InitiateRecharge(
          amount: 5000,
          provider: 'orange',
          phoneNumber: '70123456',
        );
        const event2 = InitiateRecharge(
          amount: 5000,
          provider: 'orange',
          phoneNumber: '70123456',
        );
        expect(event1, equals(event2));
      });

      test('two events with different props are not equal', () {
        const event1 = InitiateRecharge(
          amount: 5000,
          provider: 'orange',
          phoneNumber: '70123456',
        );
        const event2 = InitiateRecharge(
          amount: 10000,
          provider: 'orange',
          phoneNumber: '70123456',
        );
        expect(event1, isNot(equals(event2)));
      });
    });
  });

  group('WalletState', () {
    group('WalletInitial', () {
      test('creates instance', () {
        final state = WalletInitial();
        expect(state, isA<WalletState>());
      });

      test('props is empty', () {
        final state = WalletInitial();
        expect(state.props, isEmpty);
      });

      test('two instances are equal', () {
        final state1 = WalletInitial();
        final state2 = WalletInitial();
        expect(state1, equals(state2));
      });
    });

    group('WalletLoading', () {
      test('creates instance', () {
        final state = WalletLoading();
        expect(state, isA<WalletState>());
      });

      test('props is empty', () {
        final state = WalletLoading();
        expect(state.props, isEmpty);
      });
    });

    group('WalletLoaded', () {
      test('creates instance with wallet', () {
        const wallet = Wallet(id: '1', balance: 5000);
        const state = WalletLoaded(wallet: wallet);
        expect(state.wallet, wallet);
      });

      test('props contains wallet', () {
        const wallet = Wallet(id: '1', balance: 5000);
        const state = WalletLoaded(wallet: wallet);
        expect(state.props, [wallet]);
      });

      test('two states with same wallet are equal', () {
        const wallet = Wallet(id: '1', balance: 5000);
        const state1 = WalletLoaded(wallet: wallet);
        const state2 = WalletLoaded(wallet: wallet);
        expect(state1, equals(state2));
      });
    });

    group('WalletError', () {
      test('creates instance with message', () {
        const state = WalletError(message: 'Error occurred');
        expect(state.message, 'Error occurred');
      });

      test('props contains message', () {
        const state = WalletError(message: 'Error');
        expect(state.props, ['Error']);
      });

      test('two states with same message are equal', () {
        const state1 = WalletError(message: 'Error');
        const state2 = WalletError(message: 'Error');
        expect(state1, equals(state2));
      });
    });

    group('RechargeLoading', () {
      test('creates instance without wallet', () {
        const state = RechargeLoading();
        expect(state.currentWallet, isNull);
      });

      test('creates instance with wallet', () {
        const wallet = Wallet(id: '1', balance: 5000);
        const state = RechargeLoading(currentWallet: wallet);
        expect(state.currentWallet, wallet);
      });

      test('props contains currentWallet', () {
        const wallet = Wallet(id: '1', balance: 5000);
        const state = RechargeLoading(currentWallet: wallet);
        expect(state.props, [wallet]);
      });
    });

    group('RechargeSuccess', () {
      test('creates instance with message only', () {
        const state = RechargeSuccess(message: 'Recharge successful');
        expect(state.message, 'Recharge successful');
        expect(state.wallet, isNull);
      });

      test('creates instance with message and wallet', () {
        const wallet = Wallet(id: '1', balance: 10000);
        const state = RechargeSuccess(message: 'Success', wallet: wallet);
        expect(state.message, 'Success');
        expect(state.wallet, wallet);
      });

      test('props contains message and wallet', () {
        const wallet = Wallet(id: '1', balance: 10000);
        const state = RechargeSuccess(message: 'Success', wallet: wallet);
        expect(state.props, ['Success', wallet]);
      });

      test('two states with same props are equal', () {
        const state1 = RechargeSuccess(message: 'Success');
        const state2 = RechargeSuccess(message: 'Success');
        expect(state1, equals(state2));
      });
    });

    group('RechargeError', () {
      test('creates instance with message only', () {
        const state = RechargeError(message: 'Recharge failed');
        expect(state.message, 'Recharge failed');
        expect(state.currentWallet, isNull);
      });

      test('creates instance with message and wallet', () {
        const wallet = Wallet(id: '1', balance: 5000);
        const state = RechargeError(message: 'Failed', currentWallet: wallet);
        expect(state.message, 'Failed');
        expect(state.currentWallet, wallet);
      });

      test('props contains message and currentWallet', () {
        const wallet = Wallet(id: '1', balance: 5000);
        const state = RechargeError(message: 'Failed', currentWallet: wallet);
        expect(state.props, ['Failed', wallet]);
      });

      test('two states with same props are equal', () {
        const state1 = RechargeError(message: 'Error');
        const state2 = RechargeError(message: 'Error');
        expect(state1, equals(state2));
      });
    });
  });
}
