import '../../data/datasources/jeko_payment_datasource.dart';

abstract class JekoPaymentRepositoryInterface {
  Future<List<JekoPaymentMethod>> getPaymentMethods();
  Future<JekoPaymentResult> initiateWalletRecharge({
    required double amount,
    required String paymentMethod,
  });
  Future<JekoPaymentResult> initiateOrderPayment({
    required String orderId,
    required String paymentMethod,
  });
  Future<JekoTransaction> checkTransactionStatus(int transactionId);
  Future<List<JekoTransaction>> getTransactionHistory({int page = 1});
  Future<JekoTransaction> paymentSuccessCallback(int transactionId);
  Future<void> paymentErrorCallback(int transactionId);
}
