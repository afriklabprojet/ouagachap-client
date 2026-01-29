import '../../domain/entities/wallet.dart';
import '../../domain/repositories/wallet_repository.dart';
import '../datasources/wallet_remote_datasource.dart';

class WalletRepositoryImpl implements WalletRepository {
  final WalletRemoteDataSource remoteDataSource;

  WalletRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Wallet> getWallet() async {
    return await remoteDataSource.getWallet();
  }

  @override
  Future<Map<String, dynamic>> initiateRecharge({
    required int amount,
    required String provider,
    required String phoneNumber,
  }) async {
    return await remoteDataSource.initiateRecharge(
      amount: amount,
      provider: provider,
      phoneNumber: phoneNumber,
    );
  }
}
