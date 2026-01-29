import '../entities/wallet.dart';

abstract class WalletRepository {
  Future<Wallet> getWallet();
  Future<Map<String, dynamic>> initiateRecharge({
    required int amount,
    required String provider,
    required String phoneNumber,
  });
}
