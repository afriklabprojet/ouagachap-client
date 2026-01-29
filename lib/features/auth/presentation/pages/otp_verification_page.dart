import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class OtpVerificationPage extends StatefulWidget {
  final String phoneNumber;
  final bool isLogin;

  const OtpVerificationPage({
    super.key,
    required this.phoneNumber,
    required this.isLogin,
  });

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  final _otpController = TextEditingController();
  Timer? _timer;
  int _remainingSeconds = 60;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _remainingSeconds = 60;
    _canResend = false;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      // Vérifier mounted avant toute opération et annuler immédiatement si nécessaire
      if (!mounted) {
        timer.cancel();
        return;
      }
      
      if (_remainingSeconds > 0) {
        _remainingSeconds--;
        // Double vérification de mounted avant setState
        if (mounted) {
          setState(() {});
        }
      } else {
        timer.cancel();
        // Double vérification de mounted avant setState
        if (mounted) {
          _canResend = true;
          setState(() {});
        }
      }
    });
  }

  @override
  void dispose() {
    // Annuler le timer en PREMIER pour éviter les appels setState après dispose
    _timer?.cancel();
    _timer = null;
    _otpController.dispose();
    super.dispose();
  }

  void _onVerify() {
    if (_otpController.text.length == 6) {
      context.read<AuthBloc>().add(AuthOtpVerificationRequested(
            phone: widget.phoneNumber,
            otp: _otpController.text,
            isNewUser: !widget.isLogin, // true si inscription, false si connexion
          ));
    }
  }

  void _onResendOtp() {
    if (_canResend) {
      context.read<AuthBloc>().add(AuthResendOtpRequested(
            phone: widget.phoneNumber,
            isLogin: widget.isLogin,
          ));
      _startTimer();
    }
  }

  String _formatPhoneNumber(String phone) {
    // Format +22670000000 to +226 70 00 00 00
    if (phone.startsWith('+226') && phone.length == 12) {
      final local = phone.substring(4);
      return '+226 ${local.substring(0, 2)} ${local.substring(2, 4)} ${local.substring(4, 6)} ${local.substring(6)}';
    }
    return phone;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (!mounted) return;
        
        if (state is AuthSuccess) {
          // Afficher message de bienvenue
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(child: Text(state.message)),
                ],
              ),
              backgroundColor: AppColors.success,
              duration: const Duration(seconds: 3),
            ),
          );
        } else if (state is AuthAuthenticated) {
          context.go(Routes.home);
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
              duration: const Duration(seconds: 4),
              action: SnackBarAction(
                label: 'OK',
                textColor: Colors.white,
                onPressed: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                },
              ),
            ),
          );
          if (mounted) {
            _otpController.clear();
          }
        } else if (state is AuthOtpSent) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Code OTP renvoyé'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go(Routes.login),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                const Text(
                  'Vérification',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    children: [
                      const TextSpan(
                        text: 'Entrez le code à 6 chiffres envoyé au ',
                      ),
                      TextSpan(
                        text: _formatPhoneNumber(widget.phoneNumber),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                // OTP input
                PinCodeTextField(
                  appContext: context,
                  controller: _otpController,
                  length: 6,
                  keyboardType: TextInputType.number,
                  animationType: AnimationType.fade,
                  pinTheme: PinTheme(
                    shape: PinCodeFieldShape.box,
                    borderRadius: BorderRadius.circular(12),
                    fieldHeight: 56,
                    fieldWidth: 48,
                    activeFillColor: Colors.white,
                    inactiveFillColor: Colors.grey[100],
                    selectedFillColor: AppColors.primaryLight,
                    activeColor: AppColors.primary,
                    inactiveColor: Colors.grey[300],
                    selectedColor: AppColors.primary,
                  ),
                  enableActiveFill: true,
                  onCompleted: (value) {
                    _onVerify();
                  },
                  onChanged: (value) {},
                ),
                const SizedBox(height: 24),
                // Demo hint
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.info.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: AppColors.info, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Mode démo : utilisez le code 123456',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                // Verify button
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    final isLoading = state is AuthLoading;
                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _onVerify,
                        child: isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Vérifier'),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                // Resend OTP
                Center(
                  child: _canResend
                      ? TextButton(
                          onPressed: _onResendOtp,
                          child: const Text('Renvoyer le code'),
                        )
                      : Text(
                          'Renvoyer le code dans ${_remainingSeconds}s',
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
