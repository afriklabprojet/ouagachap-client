import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/bloc/safe_emit_mixin.dart';
import '../../../../core/utils/error_helpers.dart';
import '../../domain/repositories/sappay_repository.dart';

part 'sappay_payment_event.dart';
part 'sappay_payment_state.dart';

class SappayPaymentBloc extends Bloc<SappayPaymentEvent, SappayPaymentState>
    with SafeEmitMixin {
  final SappayRepository _repository;

  SappayPaymentBloc(this._repository) : super(const SappayPaymentState()) {
    on<SappayInitiatePayment>(_onInitiatePayment);
    on<SappayConfirmPayment>(_onConfirmPayment);
    on<SappayResetPayment>(_onReset);
  }

  Future<void> _onInitiatePayment(
    SappayInitiatePayment event,
    Emitter<SappayPaymentState> emit,
  ) async {
    emit(state.copyWith(status: SappayStatus.initiating, errorMessage: null));

    try {
      final data = await _repository.initiateRecharge(
        amount: event.amount,
        paymentMethod: event.paymentMethod,
        phone: event.phone,
      );

      final requiresOtp = data['requires_otp'] == true;
      final transactionId = data['transaction_id'] as int;

      emit(state.copyWith(
        status: requiresOtp ? SappayStatus.waitingOtp : SappayStatus.success,
        transactionId: transactionId,
        requiresOtp: requiresOtp,
        otpSent: data['otp_sent'] == true,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: SappayStatus.error,
        errorMessage: extractUserFriendlyError(e),
      ));
    }
  }

  Future<void> _onConfirmPayment(
    SappayConfirmPayment event,
    Emitter<SappayPaymentState> emit,
  ) async {
    final txId = state.transactionId;
    if (txId == null) return;

    emit(state.copyWith(status: SappayStatus.submittingOtp, errorMessage: null));

    try {
      final data = await _repository.confirmRecharge(
        transactionId: txId,
        otp: event.otp,
      );

      emit(state.copyWith(
        status: SappayStatus.success,
        newBalance: data['new_balance'] as int?,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: SappayStatus.error,
        errorMessage: extractUserFriendlyError(e),
      ));
    }
  }

  void _onReset(SappayResetPayment event, Emitter<SappayPaymentState> emit) {
    emit(const SappayPaymentState());
  }
}
