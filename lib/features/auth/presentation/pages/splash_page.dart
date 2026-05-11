import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/services/secure_token_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/lottie_animations.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _controller.forward();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    // Attendre que l'animation du logo soit visible (1.5s de l'AnimationController),
    // mais naviguer dès que l'animation est à 60% au lieu d'attendre 2s fixes.
    // Sur un téléphone lent, l'animation peut mettre plus de temps,
    // donc on attend le minimum entre animation et auth check.
    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;

    final prefs = getIt<SharedPreferences>();
    final hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;

    debugPrint('🔍 hasSeenOnboarding: $hasSeenOnboarding');

    if (!hasSeenOnboarding) {
      debugPrint('➡️ Navigation vers onboarding');
      if (mounted) context.go(Routes.onboarding);
      return;
    }

    // Vérifier l'authentification via le use case directement
    try {
      final getCurrentUserUseCase = getIt<GetCurrentUserUseCase>();
      final user = await getCurrentUserUseCase();

      if (!mounted) return;

      if (user != null) {
        // Vérifier que l'utilisateur est un client
        if (!user.isClient) {
          debugPrint(
            '⚠️ Utilisateur n\'est pas un client (role: ${user.role}), déconnexion...',
          );
          // Déconnecter l'utilisateur non-client
          try {
            final logoutUseCase = getIt<LogoutUseCase>();
            await logoutUseCase();
          } catch (e) {
            debugPrint('[Splash] Logout error: $e');
          }
          if (mounted) context.go(Routes.login);
          return;
        }
        debugPrint('➡️ Utilisateur client connecté, navigation vers home');
        context.go(Routes.home);
      } else {
        debugPrint('➡️ Pas d\'utilisateur, navigation vers login');
        context.go(Routes.login);
      }
    } catch (e) {
      debugPrint('⚠️ Erreur vérification auth au splash: $e');
      // En cas d'erreur réseau, vérifier si un token existe localement
      if (!mounted) return;
      final tokenService = getIt<SecureTokenService>();
      final token = tokenService.token;
      if (token != null && token.isNotEmpty) {
        // Token local trouvé → tenter d'aller à home (le token sera validé aux prochains appels)
        context.go(Routes.home);
      } else {
        context.go(Routes.login);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeAnimation.value,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: Image.asset(
                          'assets/images/logo.png',
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Nom de l'app
                    const Text(
                      'OUAGA CHAP',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Livraison rapide à Ouagadougou',
                      style: TextStyle(fontSize: 14, color: Colors.white70),
                    ),
                    const SizedBox(height: 48),
                    // Animation de livraison Lottie
                    Lottie.asset(
                      LottieAssets.delivery,
                      width: 150,
                      height: 80,
                      fit: BoxFit.contain,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
