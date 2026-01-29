import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/jeko_payment_repository.dart';
import 'jeko_payment_event.dart';
import 'jeko_payment_state.dart';

class JekoPaymentBloc extends Bloc<JekoPaymentEvent, JekoPaymentState> {
  final JekoPaymentRepository _repository;

  JekoPaymentBloc(this._repository) : super(const JekoPaymentState()) {
    on<LoadPaymentMethods>(_onLoadPaymentMethods);
    on<InitiateWalletRecharge>(_onInitiateWalletRecharge);
    on<InitiateOrderPayment>(_onInitiateOrderPayment);
    on<CheckTransactionStatus>(_onCheckTransactionStatus);
    on<LoadTransactionHistory>(_onLoadTransactionHistory);
    on<PaymentSuccessCallback>(_onPaymentSuccessCallback);
    on<PaymentErrorCallback>(_onPaymentErrorCallback);
    on<ResetPaymentState>(_onResetPaymentState);
  }

  Future<void> _onLoadPaymentMethods(
    LoadPaymentMethods event,
    Emitter<JekoPaymentState> emit,
  ) async {
    emit(state.copyWith(
      status: JekoPaymentStatus.loadingMethods,
      clearError: true,
    ));

    try {
      final methods = await _repository.getPaymentMethods();
      emit(state.copyWith(
        status: JekoPaymentStatus.methodsLoaded,
        paymentMethods: methods,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: JekoPaymentStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onInitiateWalletRecharge(
    InitiateWalletRecharge event,
    Emitter<JekoPaymentState> emit,
  ) async {
    emit(state.copyWith(
      status: JekoPaymentStatus.initiatingPayment,
      clearError: true,
      clearPaymentResult: true,
    ));

    try {
      final result = await _repository.initiateWalletRecharge(
        amount: event.amount,
        paymentMethod: event.paymentMethod,
      );

      if (result.success) {
        emit(state.copyWith(
          status: JekoPaymentStatus.paymentInitiated,
          paymentResult: result,
        ));
      } else {
        emit(state.copyWith(
          status: JekoPaymentStatus.error,
          errorMessage: result.message ?? 'Erreur lors de l\'initiation du paiement',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: JekoPaymentStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onInitiateOrderPayment(
    InitiateOrderPayment event,
    Emitter<JekoPaymentState> emit,
  ) async {
    emit(state.copyWith(
      status: JekoPaymentStatus.initiatingPayment,
      clearError: true,
      clearPaymentResult: true,
    ));

    try {
      final result = await _repository.initiateOrderPayment(
        orderId: event.orderId,
        paymentMethod: event.paymentMethod,
      );

      if (result.success) {
        emit(state.copyWith(
          status: JekoPaymentStatus.paymentInitiated,
          paymentResult: result,
        ));
      } else {
        emit(state.copyWith(
          status: JekoPaymentStatus.error,
          errorMessage: result.message ?? 'Erreur lors de l\'initiation du paiement',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: JekoPaymentStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onCheckTransactionStatus(
    CheckTransactionStatus event,
    Emitter<JekoPaymentState> emit,
  ) async {
    emit(state.copyWith(
      status: JekoPaymentStatus.checkingStatus,
      clearError: true,
    ));

    try {
      final transaction = await _repository.checkTransactionStatus(event.transactionId);
      emit(state.copyWith(
        status: JekoPaymentStatus.statusChecked,
        currentTransaction: transaction,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: JekoPaymentStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onLoadTransactionHistory(
    LoadTransactionHistory event,
    Emitter<JekoPaymentState> emit,
  ) async {
    emit(state.copyWith(
      status: JekoPaymentStatus.loadingHistory,
      clearError: true,
    ));

    try {
      final transactions = await _repository.getTransactionHistory(page: event.page);
      
      final List<dynamic> allTransactions;
      if (event.page == 1) {
        allTransactions = transactions;
      } else {
        allTransactions = [...state.transactionHistory, ...transactions];
      }

      emit(state.copyWith(
        status: JekoPaymentStatus.historyLoaded,
        transactionHistory: allTransactions.cast(),
        currentPage: event.page,
        hasMoreHistory: transactions.length >= 20,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: JekoPaymentStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onPaymentSuccessCallback(
    PaymentSuccessCallback event,
    Emitter<JekoPaymentState> emit,
  ) async {
    emit(state.copyWith(
      status: JekoPaymentStatus.checkingStatus,
      clearError: true,
    ));

    try {
      final transaction = await _repository.paymentSuccessCallback(event.transactionId);
      emit(state.copyWith(
        status: JekoPaymentStatus.success,
        currentTransaction: transaction,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: JekoPaymentStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onPaymentErrorCallback(
    PaymentErrorCallback event,
    Emitter<JekoPaymentState> emit,
  ) async {
    try {
      await _repository.paymentErrorCallback(event.transactionId);
    } catch (e) {
      // Ignorer les erreurs de callback d'erreur
    }

    emit(state.copyWith(
      status: JekoPaymentStatus.error,
      errorMessage: 'Le paiement a échoué ou a été annulé',
    ));
  }

  void _onResetPaymentState(
    ResetPaymentState event,
    Emitter<JekoPaymentState> emit,
  ) {
    emit(state.copyWith(
      status: JekoPaymentStatus.initial,
      clearPaymentResult: true,
      clearCurrentTransaction: true,
      clearError: true,
    ));
  }
}
