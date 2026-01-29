import '../../../../core/network/api_client.dart';
import '../models/wallet_model.dart';

abstract class WalletRemoteDataSource {
  Future<WalletModel> getWallet();
  Future<Map<String, dynamic>> initiateRecharge({
    required int amount,
    required String provider,
    required String phoneNumber,
  });
}

class WalletRemoteDataSourceImpl implements WalletRemoteDataSource {
  final ApiClient _apiClient;

  WalletRemoteDataSourceImpl(this._apiClient);

  @override
  Future<WalletModel> getWallet() async {
    final response = await _apiClient.get('client-wallet/balance');
    return WalletModel.fromJson(response.data['data']);
  }

  @override
  Future<Map<String, dynamic>> initiateRecharge({
    required int amount,
    required String provider,
    required String phoneNumber,
  }) async {
    final response = await _apiClient.post(
      'client-wallet/recharge',
      data: {
        'amount': amount,
        'provider': provider,
        'phone': phoneNumber,
      },
    );
    return response.data;
  }
}
