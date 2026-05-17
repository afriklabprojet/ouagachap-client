import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/bloc/safe_emit_mixin.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../core/utils/error_helpers.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/verify_otp_usecase.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> with SafeEmitMixin {
  final VerifyOtpUseCase _verifyOtpUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final LogoutUseCase _logoutUseCase;
  final AuthRepository _authRepository;

  AuthBloc({
    required VerifyOtpUseCase verifyOtpUseCase,
    required GetCurrentUserUseCase getCurrentUserUseCase,
    required LogoutUseCase logoutUseCase,
    required AuthRepository authRepository,
  }) : _verifyOtpUseCase = verifyOtpUseCase,
       _getCurrentUserUseCase = getCurrentUserUseCase,
       _logoutUseCase = logoutUseCase,
       _authRepository = authRepository,
       super(AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthRegisterRequested>(_onRegisterRequested);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthOtpVerificationRequested>(_onOtpVerificationRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthResendOtpRequested>(_onResendOtpRequested);
    on<AuthAutoVerified>(_onAutoVerified);
    on<UpdateProfileRequested>(_onUpdateProfileRequested);
    on<SendPhoneVerificationOtpRequested>(_onSendPhoneVerificationOtp);
    on<VerifyPhoneOtpRequested>(_onVerifyPhoneOtp);
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await _getCurrentUserUseCase();
      if (user != null) {
        emit(AuthAuthenticated(user: user));
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e, st) {
      AppLogger.error('Auth check failed', e, st);
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await _authRepository.register(
        name: event.name,
        phone: event.phone,
        email: event.email,
        password: event.password,
      );
      emit(
        const AuthSuccess(
          message: 'Compte créé ! Connectez-vous avec votre numéro.',
        ),
      );
    } catch (e) {
      emit(AuthError(message: _parseError(e)));
    }
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await _authRepository.login(
        phone: event.phone,
        password: event.password,
      );
      emit(AuthAuthenticated(user: user));
    } catch (e) {
      emit(AuthError(message: _parseError(e)));
    }
  }

  Future<void> _onOtpVerificationRequested(
    AuthOtpVerificationRequested event,
    Emitter<AuthState> emit,
  ) async {
    if (event.verificationId == null || event.verificationId!.isEmpty) {
      emit(
        const AuthError(
          message: 'Session expirée, veuillez renvoyer le code OTP',
        ),
      );
      return;
    }
    emit(AuthLoading());
    try {
      final credential = fb.PhoneAuthProvider.credential(
        verificationId: event.verificationId!,
        smsCode: event.otp,
      );
      final userCredential = await fb.FirebaseAuth.instance
          .signInWithCredential(credential);
      final idToken = await userCredential.user?.getIdToken();
      final user = await _verifyOtpUseCase(
        phone: event.phone,
        otp: '',
        firebaseIdToken: idToken,
      );
      emit(AuthAuthenticated(user: user));
    } catch (e) {
      emit(AuthError(message: _parseError(e)));
    }
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await _logoutUseCase();
    } catch (_) {
      // Toujours déconnecter localement même si l'API échoue
    }
    emit(AuthUnauthenticated());
  }

  Future<void> _onResendOtpRequested(
    AuthResendOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final completer = Completer<void>();
    await fb.FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: event.phone,
      verificationCompleted: (credential) {
        add(AuthAutoVerified(credential: credential, phone: event.phone));
        if (!completer.isCompleted) completer.complete();
      },
      verificationFailed: (e) {
        emit(
          AuthError(message: e.message ?? 'Erreur lors du renvoi du code OTP'),
        );
        if (!completer.isCompleted) completer.complete();
      },
      codeSent: (verificationId, resendToken) {
        emit(
          AuthOtpSent(
            phone: event.phone,
            isLogin: event.isLogin,
            verificationId: verificationId,
          ),
        );
        if (!completer.isCompleted) completer.complete();
      },
      codeAutoRetrievalTimeout: (verificationId) {
        if (!completer.isCompleted) completer.complete();
      },
      timeout: const Duration(seconds: 60),
    );
    await completer.future;
  }

  Future<void> _onAutoVerified(
    AuthAutoVerified event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final userCredential = await fb.FirebaseAuth.instance
          .signInWithCredential(event.credential);
      final idToken = await userCredential.user?.getIdToken();
      final user = await _verifyOtpUseCase(
        phone: event.phone,
        otp: '',
        firebaseIdToken: idToken,
      );
      emit(AuthAuthenticated(user: user));
    } catch (e) {
      emit(AuthError(message: _parseError(e)));
    }
  }

  Future<void> _onUpdateProfileRequested(
    UpdateProfileRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await _authRepository.updateProfile(
        name: event.name,
        email: event.email,
        avatarFile: event.avatarFile,
        avatarBytes: event.avatarBytes,
      );
      emit(AuthProfileUpdated(user: user));
    } catch (e) {
      emit(AuthError(message: _parseError(e)));
    }
  }

  Future<void> _onSendPhoneVerificationOtp(
    SendPhoneVerificationOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await _authRepository.sendPhoneVerificationOtp();
      emit(AuthPhoneOtpSent());
    } catch (e) {
      emit(AuthError(message: _parseError(e)));
    }
  }

  Future<void> _onVerifyPhoneOtp(
    VerifyPhoneOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await _authRepository.verifyPhoneOtp(code: event.code);
      emit(AuthAuthenticated(user: user));
    } catch (e) {
      emit(AuthError(message: _parseError(e)));
    }
  }

  String _parseError(Object e) {
    return extractUserFriendlyError(e);
  }
}
