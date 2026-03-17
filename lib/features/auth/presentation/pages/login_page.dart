import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/form_validators.dart';
import '../../../../core/widgets/animations.dart';
import '../../../../core/widgets/custom_buttons.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _onLogin() {
    if (_formKey.currentState?.validate() ?? false) {
      final phone = '+226${_phoneController.text.replaceAll(' ', '')}';
      context.read<AuthBloc>().add(AuthLoginRequested(phone: phone));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthOtpSent) {
          // Afficher message de succès avant navigation
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Code de vérification envoyé par SMS'),
              backgroundColor: AppColors.success,
              duration: Duration(seconds: 2),
            ),
          );
          
          // Naviguer vers la page OTP
          context.go(Routes.otpVerification, extra: {
            'phoneNumber': state.phone,
            'isLogin': state.isLogin,
          });
        } else if (state is AuthSuccess) {
          // Message de succès (connexion/inscription)
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.success,
              duration: const Duration(seconds: 3),
            ),
          );
        } else if (state is AuthError) {
          // Messages d'erreur détaillés
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
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  // Logo
                  FadeInWidget(
                    duration: const Duration(milliseconds: 600),
                    child: Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.asset(
                          'assets/images/logo.png',
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Title
                  SlideInWidget(
                    beginOffset: const Offset(0, 0.3),
                    child: const Text(
                      'Connexion',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Entrez votre numéro de téléphone pour continuer',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Phone field
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(8),
                      PhoneNumberFormatter(),
                    ],
                    decoration: InputDecoration(
                      labelText: 'Numéro de téléphone',
                      hintText: '70 00 00 00',
                      prefixIcon: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              '🇧🇫',
                              style: TextStyle(fontSize: 20),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '+226',
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.symmetric(horizontal: 8),
                              height: 24,
                              width: 1,
                              color: Colors.grey[300],
                            ),
                          ],
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer votre numéro';
                      }
                      final digits = value.replaceAll(' ', '');
                      if (digits.length != 8) {
                        return 'Le numéro doit contenir 8 chiffres';
                      }
                      // Vérifier les préfixes valides au Burkina Faso
                      final prefix = digits.substring(0, 2);
                      const validPrefixes = ['50','51','52','53','54','55','56','57','58',
                                             '60','61','62','63','64','65','66','67','68','69',
                                             '70','71','72','73','74','75','76','77','78','79'];
                      if (!validPrefixes.contains(prefix)) {
                        return 'Préfixe invalide. Utilisez un numéro Burkina Faso';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),
                  // Login button
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      final isLoading = state is AuthLoading;
                      return ScaleInWidget(
                        delay: const Duration(milliseconds: 200),
                        child: PrimaryButton(
                          text: 'Continuer',
                          isLoading: isLoading,
                          onPressed: _onLogin,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  // Register link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Pas de compte ? ',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      TextButton(
                        onPressed: () => context.go(Routes.register),
                        child: const Text('S\'inscrire'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
