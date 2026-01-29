import 'package:equatable/equatable.dart';
import '../../data/datasources/jeko_payment_datasource.dart';

enum JekoPaymentStatus {
  initial,
  loadingMethods,
  methodsLoaded,
  initiatingPayment,
  paymentInitiated,
  checkingStatus,
  statusChecked,
  loadingHistory,
  historyLoaded,
  success,
  error,
}

class JekoPaymentState extends Equatable {
  final JekoPaymentStatus status;
  final List<JekoPaymentMethod> paymentMethods;
  final JekoPaymentResult? paymentResult;
  final JekoTransaction? currentTransaction;
  final List<JekoTransaction> transactionHistory;
  final String? errorMessage;
  final bool hasMoreHistory;
  final int currentPage;

  const JekoPaymentState({
    this.status = JekoPaymentStatus.initial,
    this.paymentMethods = const [],
    this.paymentResult,
    this.currentTransaction,
    this.transactionHistory = const [],
    this.errorMessage,
    this.hasMoreHistory = true,
    this.currentPage = 1,
  });

  JekoPaymentState copyWith({
    JekoPaymentStatus? status,
    List<JekoPaymentMethod>? paymentMethods,
    JekoPaymentResult? paymentResult,
    JekoTransaction? currentTransaction,
    List<JekoTransaction>? transactionHistory,
    String? errorMessage,
    bool? hasMoreHistory,
    int? currentPage,
    bool clearPaymentResult = false,
    bool clearCurrentTransaction = false,
    bool clearError = false,
  }) {
    return JekoPaymentState(
      status: status ?? this.status,
      paymentMethods: paymentMethods ?? this.paymentMethods,
      paymentResult: clearPaymentResult ? null : (paymentResult ?? this.paymentResult),
      currentTransaction: clearCurrentTransaction ? null : (currentTransaction ?? this.currentTransaction),
      transactionHistory: transactionHistory ?? this.transactionHistory,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      hasMoreHistory: hasMoreHistory ?? this.hasMoreHistory,
      currentPage: currentPage ?? this.currentPage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        paymentMethods,
        paymentResult,
        currentTransaction,
        transactionHistory,
        errorMessage,
        hasMoreHistory,
        currentPage,
      ];

  bool get isLoading => [
        JekoPaymentStatus.loadingMethods,
        JekoPaymentStatus.initiatingPayment,
        JekoPaymentStatus.checkingStatus,
        JekoPaymentStatus.loadingHistory,
      ].contains(status);

  bool get hasPaymentMethods => paymentMethods.isNotEmpty;

  bool get hasRedirectUrl =>
      paymentResult != null && paymentResult!.redirectUrl != null;

  bool get isPaymentSuccessful =>
      currentTransaction != null && currentTransaction!.isSuccessful;

  bool get isPaymentFailed =>
      currentTransaction != null && currentTransaction!.isFailed;

  bool get isPaymentPending =>
      currentTransaction != null && currentTransaction!.isPending;
}
