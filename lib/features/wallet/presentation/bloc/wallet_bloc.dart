import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/wallet_repository.dart';
import 'wallet_event.dart';
import 'wallet_state.dart';

class WalletBloc extends Bloc<WalletEvent, WalletState> {
  final WalletRepository walletRepository;

  WalletBloc({required this.walletRepository}) : super(WalletInitial()) {
    on<LoadWallet>(_onLoadWallet);
    on<InitiateRecharge>(_onInitiateRecharge);
  }

  Future<void> _onLoadWallet(
    LoadWallet event,
    Emitter<WalletState> emit,
  ) async {
    emit(WalletLoading());
    try {
      final wallet = await walletRepository.getWallet();
      emit(WalletLoaded(wallet: wallet));
    } catch (e) {
      emit(WalletError(message: e.toString()));
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
      
      final message = response['message'] ?? 'Recharge initiée avec succès';
      
      // Reload wallet to get updated balance
      try {
        final wallet = await walletRepository.getWallet();
        emit(RechargeSuccess(message: message, wallet: wallet));
      } catch (_) {
        emit(RechargeSuccess(message: message, wallet: currentWallet));
      }
    } catch (e) {
      emit(RechargeError(
        message: e.toString(),
        currentWallet: currentWallet,
      ));
    }
  }
}
