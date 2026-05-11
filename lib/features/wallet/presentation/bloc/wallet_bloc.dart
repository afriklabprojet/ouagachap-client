import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/bloc/safe_emit_mixin.dart';
import '../../../../core/utils/error_helpers.dart';
import '../../domain/repositories/wallet_repository.dart';
import 'wallet_event.dart';
import 'wallet_state.dart';

class WalletBloc extends Bloc<WalletEvent, WalletState>
    with SafeEmitMixin {
  final WalletRepository walletRepository;

  WalletBloc({required this.walletRepository}) : super(WalletInitial()) {
    // restartable() → annule le chargement précédent si un nouveau arrive
    on<LoadWallet>(_onLoadWallet, transformer: restartable());
    // droppable() → ignore les double-taps sur recharge (évite double débit)
    on<InitiateRecharge>(_onInitiateRecharge, transformer: droppable());
  }

  Future<void> _onLoadWallet(
    LoadWallet event,
    Emitter<WalletState> emit,
  ) async {
    emit(WalletLoading());
    try {
      final wallet = await walletRepository.getWallet();
      safeEmit(emit, WalletLoaded(wallet: wallet));
    } catch (e) {
      safeEmit(emit, WalletError(message: extractUserFriendlyError(e)));
    }
  }

  Future<void> _onInitiateRecharge(
    InitiateRecharge event,
    Emitter<WalletState> emit,
  ) async {
    final currentWallet = state is WalletLoaded 
        ? (state as WalletLoaded).wallet 
        : null;
    
    emit(RechargeLoading(currentWallet: currentWallet));
    
    try {
      final response = await walletRepository.initiateRecharge(
        amount: event.amount,
        provider: event.provider,
        phoneNumber: event.phoneNumber,
      );
      if (isClosed) return;
      
      final message = response['message'] ?? 'Recharge initiée avec succès';
      
      // Recharger le portefeuille pour avoir le solde mis à jour
      try {
        final wallet = await walletRepository.getWallet();
        safeEmit(emit, RechargeSuccess(message: message, wallet: wallet));
      } catch (_) {
        safeEmit(emit, RechargeSuccess(message: message, wallet: currentWallet));
      }
    } catch (e) {
      safeEmit(emit, RechargeError(
        message: e.toString(),
        currentWallet: currentWallet,
      ));
    }
  }
}
