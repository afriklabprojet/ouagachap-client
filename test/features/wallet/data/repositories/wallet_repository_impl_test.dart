import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ouaga_chap_client/features/wallet/data/datasources/wallet_remote_datasource.dart';
import 'package:ouaga_chap_client/features/wallet/data/models/wallet_model.dart';
import 'package:ouaga_chap_client/features/wallet/data/repositories/wallet_repository_impl.dart';

class MockWalletRemoteDataSource extends Mock implements WalletRemoteDataSource {}

void main() {
  late WalletRepositoryImpl repository;
  late MockWalletRemoteDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockWalletRemoteDataSource();
    repository = WalletRepositoryImpl(remoteDataSource: mockDataSource);
  });

  group('WalletRepositoryImpl', () {
    group('getWallet', () {
      final testWallet = WalletModel(
        id: '1',
        balance: 5000,
        currency: 'XOF',
      );

      test('should return wallet from datasource', () async {
        // Arrange
        when(() => mockDataSource.getWallet())
            .thenAnswer((_) async => testWallet);

        // Act
        final result = await repository.getWallet();

        // Assert
        expect(result.balance, equals(5000));
        expect(result.currency, equals('XOF'));
        verify(() => mockDataSource.getWallet()).called(1);
      });

      test('should throw exception when datasource fails', () async {
        // Arrange
        when(() => mockDataSource.getWallet())
            .thenThrow(Exception('Network error'));

        // Act & Assert
        expect(
          () => repository.getWallet(),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('initiateRecharge', () {
      const testAmount = 1000;
      const testProvider = 'orange_money';
      const testPhone = '70123456';
      final testResponse = {
        'success': true,
        'transaction_id': 'TX123',
        'message': 'Recharge initiée',
      };

      test('should return response from datasource', () async {
        // Arrange
        when(() => mockDataSource.initiateRecharge(
              amount: testAmount,
              provider: testProvider,
              phoneNumber: testPhone,
            )).thenAnswer((_) async => testResponse);

        // Act
        final result = await repository.initiateRecharge(
          amount: testAmount,
          provider: testProvider,
          phoneNumber: testPhone,
        );

        // Assert
        expect(result['success'], isTrue);
        expect(result['transaction_id'], equals('TX123'));
        verify(() => mockDataSource.initiateRecharge(
              amount: testAmount,
              provider: testProvider,
              phoneNumber: testPhone,
            )).called(1);
      });

      test('should pass correct parameters to datasource', () async {
        // Arrange
        when(() => mockDataSource.initiateRecharge(
              amount: any(named: 'amount'),
              provider: any(named: 'provider'),
              phoneNumber: any(named: 'phoneNumber'),
            )).thenAnswer((_) async => testResponse);

        // Act
        await repository.initiateRecharge(
          amount: 2000,
          provider: 'moov_money',
          phoneNumber: '75555555',
        );

        // Assert
        verify(() => mockDataSource.initiateRecharge(
              amount: 2000,
              provider: 'moov_money',
              phoneNumber: '75555555',
            )).called(1);
      });

      test('should throw exception when datasource fails', () async {
        // Arrange
        when(() => mockDataSource.initiateRecharge(
              amount: any(named: 'amount'),
              provider: any(named: 'provider'),
              phoneNumber: any(named: 'phoneNumber'),
            )).thenThrow(Exception('Payment error'));

        // Act & Assert
        expect(
          () => repository.initiateRecharge(
            amount: testAmount,
            provider: testProvider,
            phoneNumber: testPhone,
          ),
          throwsA(isA<Exception>()),
        );
      });
    });
  });
}
