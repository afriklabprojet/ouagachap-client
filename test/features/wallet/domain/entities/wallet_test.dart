import 'package:flutter_test/flutter_test.dart';
import 'package:ouaga_chap_client/features/wallet/domain/entities/wallet.dart';

void main() {
  group('Wallet Entity', () {
    group('Constructor', () {
      test('creates wallet with required fields', () {
        // Arrange & Act
        const wallet = Wallet(
          id: 'wallet_123',
          balance: 5000,
        );

        // Assert
        expect(wallet.id, equals('wallet_123'));
        expect(wallet.balance, equals(5000));
        expect(wallet.currency, equals('XOF')); // Default currency
      });

      test('creates wallet with custom currency', () {
        // Arrange & Act
        const wallet = Wallet(
          id: 'wallet_456',
          balance: 10000,
          currency: 'EUR',
        );

        // Assert
        expect(wallet.id, equals('wallet_456'));
        expect(wallet.balance, equals(10000));
        expect(wallet.currency, equals('EUR'));
      });

      test('creates wallet with zero balance', () {
        // Arrange & Act
        const wallet = Wallet(
          id: 'wallet_empty',
          balance: 0,
        );

        // Assert
        expect(wallet.balance, equals(0));
      });

      test('creates wallet with large balance', () {
        // Arrange & Act
        const wallet = Wallet(
          id: 'wallet_rich',
          balance: 1000000000, // 1 billion
        );

        // Assert
        expect(wallet.balance, equals(1000000000));
      });
    });

    group('Equatable', () {
      test('wallets with same data are equal', () {
        // Arrange
        const wallet1 = Wallet(
          id: 'wallet_123',
          balance: 5000,
          currency: 'XOF',
        );
        const wallet2 = Wallet(
          id: 'wallet_123',
          balance: 5000,
          currency: 'XOF',
        );

        // Assert
        expect(wallet1, equals(wallet2));
        expect(wallet1.hashCode, equals(wallet2.hashCode));
      });

      test('wallets with different id are not equal', () {
        // Arrange
        const wallet1 = Wallet(
          id: 'wallet_123',
          balance: 5000,
        );
        const wallet2 = Wallet(
          id: 'wallet_456',
          balance: 5000,
        );

        // Assert
        expect(wallet1, isNot(equals(wallet2)));
      });

      test('wallets with different balance are not equal', () {
        // Arrange
        const wallet1 = Wallet(
          id: 'wallet_123',
          balance: 5000,
        );
        const wallet2 = Wallet(
          id: 'wallet_123',
          balance: 10000,
        );

        // Assert
        expect(wallet1, isNot(equals(wallet2)));
      });

      test('wallets with different currency are not equal', () {
        // Arrange
        const wallet1 = Wallet(
          id: 'wallet_123',
          balance: 5000,
          currency: 'XOF',
        );
        const wallet2 = Wallet(
          id: 'wallet_123',
          balance: 5000,
          currency: 'EUR',
        );

        // Assert
        expect(wallet1, isNot(equals(wallet2)));
      });

      test('props returns correct list', () {
        // Arrange
        const wallet = Wallet(
          id: 'wallet_123',
          balance: 5000,
          currency: 'XOF',
        );

        // Assert
        expect(wallet.props, equals(['wallet_123', 5000, 'XOF']));
      });
    });

    group('Default values', () {
      test('default currency is XOF', () {
        // Arrange & Act
        const wallet = Wallet(
          id: 'wallet_test',
          balance: 1000,
        );

        // Assert
        expect(wallet.currency, equals('XOF'));
      });
    });
  });
}
