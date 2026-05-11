import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/animations.dart';
import '../../../../core/widgets/custom_buttons.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingItem> _items = [
    OnboardingItem(
      title: 'Envoyez vos colis facilement',
      description:
          'Expédiez vos colis partout à Ouagadougou en quelques clics. Simple, rapide et sécurisé.',
      svgAsset: 'assets/images/onboarding/onboarding_delivery.svg',
    ),
    OnboardingItem(
      title: 'Suivi en temps réel',
      description:
          'Suivez votre colis à chaque étape de la livraison. Notifications instantanées et localisation GPS.',
      svgAsset: 'assets/images/onboarding/onboarding_tracking.svg',
    ),
    OnboardingItem(
      title: 'Paiement sécurisé',
      description:
          'Payez facilement avec Mobile Money, carte bancaire ou portefeuille OUAGA CHAP.',
      svgAsset: 'assets/images/onboarding/onboarding_payment.svg',
    ),
    OnboardingItem(
      title: 'Livreurs de confiance',
      description:
          'Des livreurs professionnels et vérifiés pour assurer la sécurité de vos envois.',
      svgAsset: 'assets/images/onboarding/onboarding_trust.svg',
    ),
  ];

  @override
  void initState() {
    super.initState();
    // Pas de défilement automatique pour l'onboarding
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    await getIt<SharedPreferences>().setBool('has_seen_onboarding', true);
    if (mounted) {
      context.go(Routes.login);
    }
  }

  void _nextPage() {
    if (_currentPage < _items.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _skipOnboarding() {
    _completeOnboarding();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextButton(
                  onPressed: _skipOnboarding,
                  child: Text(
                    context.l10n.translate('skip'),
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),

            // Page View
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _items.length,
                itemBuilder: (context, index) {
                  return _buildPage(_items[index]);
                },
              ),
            ),

            // Indicators
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _items.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == index ? 32 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: _currentPage == index
                          ? AppColors.primary
                          : AppColors.primary.withValues(alpha: 0.3),
                    ),
                  ),
                ),
              ),
            ),

            // Buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: ScaleInWidget(
                child: PrimaryButton(
                  text: _currentPage == _items.length - 1
                      ? context.l10n.translate('get_started')
                      : context.l10n.translate('next'),
                  onPressed: _nextPage,
                  icon: _currentPage == _items.length - 1
                      ? Icons.rocket_launch
                      : Icons.arrow_forward,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Illustration SVG
          ScaleInWidget(
            child: Semantics(
              image: true,
              label: item.title,
              child: SvgPicture.asset(
                item.svgAsset,
                width: 280,
                height: 280,
                placeholderBuilder: (context) => const SizedBox(
                  width: 280,
                  height: 280,
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),

          // Title
          SlideInWidget(
            beginOffset: const Offset(0, 0.3),
            child: Text(
              item.title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                height: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Description
          FadeInWidget(
            delay: const Duration(milliseconds: 200),
            child: Text(
              item.description,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingItem {
  final String title;
  final String description;
  final String svgAsset;

  OnboardingItem({
    required this.title,
    required this.description,
    required this.svgAsset,
  });
}
