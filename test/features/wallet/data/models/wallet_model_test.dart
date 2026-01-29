import 'package:flutter_test/flutter_test.dart';
import 'package:ouaga_chap_client/features/wallet/data/models/wallet_model.dart';
import 'package:ouaga_chap_client/features/wallet/domain/entities/wallet.dart';

void main() {
  group('WalletModel', () {
    group('Constructor', () {
      test('creates WalletModel with required fields', () {
        // Arrange & Act
        const walletModel = WalletModel(
          id: 'wallet_123',
          balance: 5000,
        );

        // Assert
        expect(walletModel.id, equals('wallet_123'));
        expect(walletModel.balance, equals(5000));
        expect(walletModel.currency, equals('XOF'));
      });

      test('creates WalletModel with custom currency', () {
        // Arrange & Act
        const walletModel = WalletModel(
          id: 'wallet_456',
          balance: 10000,
          currency: 'EUR',
        );

        // Assert
        expect(walletModel.currency, equals('EUR'));
      });
    });

    group('fromJson', () {
      test('creates WalletModel from complete JSON', () {
        // Arrange
        final json = {
          'id': 'wallet_123',
          'balance': 5000,
          'currency': 'XOF',
        };

        // Act
        final walletModel = WalletModel.fromJson(json);

        // Assert
        expect(walletModel.id, equals('wallet_123'));
        expect(walletModel.balance, equals(5000));
        expect(walletModel.currency, equals('XOF'));
      });

      test('creates WalletModel with integer id', () {
        // Arrange
        final json = {
          'id': 123, // Integer instead of string
          'balance': 5000,
        };

        // Act
        final walletModel = WalletModel.fromJson(json);

        // Assert
        expect(walletModel.id, equals('123'));
      });

      test('creates WalletModel with null id', () {
        // Arrange
        final json = {
          'id': null,
          'balance': 5000,
        };

        // Act
        final walletModel = WalletModel.fromJson(json);

        // Assert
        expect(walletModel.id, equals(''));
      });

      test('creates WalletModel with missing balance defaults to 0', () {
        // Arrange
        final json = {
          'id': 'wallet_123',
        };

        // Act
        final walletModel = WalletModel.fromJson(json);

        // Assert
        expect(walletModel.balance, equals(0));
      });

      test('creates WalletModel with null balance defaults to 0', () {
        // Arrange
        final json = {
          'id': 'wallet_123',
          'balance': null,
        };

        // Act
        final walletModel = WalletModel.fromJson(json);

        // Assert
        expect(walletModel.balance, equals(0));
      });

      test('creates WalletModel with missing currency defaults to XOF', () {
        // Arrange
        final json = {
          'id': 'wallet_123',
          'balance': 5000,
        };

        // Act
        final walletModel = WalletModel.fromJson(json);

        // Assert
        expect(walletModel.currency, equals('XOF'));
      });

      test('creates WalletModel with null currency defaults to XOF', () {
        // Arrange
        final json = {
          'id': 'wallet_123',
          'balance': 5000,
          'currency': null,
        };

        // Act
        final walletModel = WalletModel.fromJson(json);

        // Assert
        expect(walletModel.currency, equals('XOF'));
      });

      test('creates WalletModel with different currencies', () {
        // Arrange & Act
        final walletEUR = WalletModel.fromJson({
          'id': '1',
          'balance': 100,
          'currency': 'EUR',
        });
        final walletUSD = WalletModel.fromJson({
          'id': '2',
          'balance': 100,
          'currency': 'USD',
        });

        // Assert
        expect(walletEUR.currency, equals('EUR'));
        expect(walletUSD.currency, equals('USD'));
      });
    });

    group('toJson', () {
      test('converts WalletModel to JSON', () {
        // Arrange
        const walletModel = WalletModel(
          id: 'wallet_123',
          balance: 5000,
          currency: 'XOF',
        );

        // Act
        final json = walletModel.toJson();

        // Assert
        expect(json['id'], equals('wallet_123'));
        expect(json['balance'], equals(5000));
        expect(json['currency'], equals('XOF'));
      });

      test('round-trip conversion (fromJson -> toJson)', () {
        // Arrange
        final originalJson = {
          'id': 'wallet_456',
          'balance': 10000,
          'currency': 'EUR',
        };

        // Act
        final walletModel = WalletModel.fromJson(originalJson);
        final resultJson = walletModel.toJson();

        // Assert
        expect(resultJson['id'], equals(originalJson['id']));
        expect(resultJson['balance'], equals(originalJson['balance']));
        expect(resultJson['currency'], equals(originalJson['currency']));
      });
    });

    group('Inheritance', () {
      test('WalletModel extends Wallet', () {
        // Arrange & Act
        const walletModel = WalletModel(
          id: 'wallet_123',
          balance: 5000,
        );

        // Assert
        expect(walletModel, isA<Wallet>());
      });

      test('WalletModel inherits Equatable from Wallet', () {
        // Arrange
        const wallet1 = WalletModel(
          id: 'wallet_123',
          balance: 5000,
          currency: 'XOF',
        );
        const wallet2 = WalletModel(
          id: 'wallet_123',
          balance: 5000,
          currency: 'XOF',
        );

        // Assert
        expect(wallet1, equals(wallet2));
      });
    });
  });
}
