import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ouaga_chap_client/core/network/api_client.dart';
import 'package:ouaga_chap_client/features/wallet/data/datasources/wallet_remote_datasource.dart';

class MockApiClient extends Mock implements ApiClient {}

void main() {
  late WalletRemoteDataSourceImpl dataSource;
  late MockApiClient mockApiClient;

  setUp(() {
    mockApiClient = MockApiClient();
    dataSource = WalletRemoteDataSourceImpl(mockApiClient);
  });

  group('WalletRemoteDataSourceImpl', () {
    group('getWallet', () {
      final testResponse = Response(
        requestOptions: RequestOptions(path: 'client-wallet/balance'),
        data: {
          'data': {
            'balance': 5000,
            'currency': 'XOF',
          },
        },
      );

      test('should return wallet from API', () async {
        // Arrange
        when(() => mockApiClient.get('client-wallet/balance'))
            .thenAnswer((_) async => testResponse);

        // Act
        final result = await dataSource.getWallet();

        // Assert
        expect(result.balance, equals(5000));
        expect(result.currency, equals('XOF'));
        verify(() => mockApiClient.get('client-wallet/balance')).called(1);
      });

      test('should throw exception when API fails', () async {
        // Arrange
        when(() => mockApiClient.get('client-wallet/balance'))
            .thenThrow(DioException(
              requestOptions: RequestOptions(path: 'client-wallet/balance'),
              message: 'Network error',
            ));

        // Act & Assert
        expect(
          () => dataSource.getWallet(),
          throwsA(isA<DioException>()),
        );
      });
    });

    group('initiateRecharge', () {
      final testResponse = Response(
        requestOptions: RequestOptions(path: 'client-wallet/recharge'),
        data: {
          'success': true,
          'message': 'Recharge initiée',
          'data': {
            'transaction_id': 'TX123',
            'redirect_url': 'https://payment.url',
          },
        },
      );

      test('should initiate recharge with correct parameters', () async {
        // Arrange
        when(() => mockApiClient.post(
              'client-wallet/recharge',
              data: any(named: 'data'),
            )).thenAnswer((_) async => testResponse);

        // Act
        final result = await dataSource.initiateRecharge(
          amount: 1000,
          provider: 'orange_money',
          phoneNumber: '70123456',
        );

        // Assert
        expect(result['success'], isTrue);
        verify(() => mockApiClient.post(
              'client-wallet/recharge',
              data: {
                'amount': 1000,
                'provider': 'orange_money',
                'phone': '70123456',
              },
            )).called(1);
      });

      test('should return full response data', () async {
        // Arrange
        when(() => mockApiClient.post(
              'client-wallet/recharge',
              data: any(named: 'data'),
            )).thenAnswer((_) async => testResponse);

        // Act
        final result = await dataSource.initiateRecharge(
          amount: 2000,
          provider: 'moov_money',
          phoneNumber: '75555555',
        );

        // Assert
        expect(result['data']['transaction_id'], equals('TX123'));
        expect(result['data']['redirect_url'], equals('https://payment.url'));
      });

      test('should throw exception when API fails', () async {
        // Arrange
        when(() => mockApiClient.post(
              'client-wallet/recharge',
              data: any(named: 'data'),
            )).thenThrow(DioException(
              requestOptions: RequestOptions(path: 'client-wallet/recharge'),
              message: 'Payment error',
            ));

        // Act & Assert
        expect(
          () => dataSource.initiateRecharge(
            amount: 1000,
            provider: 'orange_money',
            phoneNumber: '70123456',
          ),
          throwsA(isA<DioException>()),
        );
      });
    });
  });
}
