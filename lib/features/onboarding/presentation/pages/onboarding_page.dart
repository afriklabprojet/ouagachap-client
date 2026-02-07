import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  Timer? _autoScrollTimer;

  final List<OnboardingItem> _items = [
    OnboardingItem(
      title: 'Envoyez vos colis facilement',
      description: 'Expédiez vos colis partout à Ouagadougou en quelques clics. Simple, rapide et sécurisé.',
      icon: Icons.local_shipping_rounded,
      gradient: [const Color(0xFF667eea), const Color(0xFF764ba2)],
    ),
    OnboardingItem(
      title: 'Suivi en temps réel',
      description: 'Suivez votre colis à chaque étape de la livraison. Notifications instantanées et localisation GPS.',
      icon: Icons.location_on_rounded,
      gradient: [const Color(0xFF11998e), const Color(0xFF38ef7d)],
    ),
    OnboardingItem(
      title: 'Paiement sécurisé',
      description: 'Payez facilement avec Mobile Money, carte bancaire ou portefeuille OUAGA CHAP.',
      icon: Icons.account_balance_wallet_rounded,
      gradient: [const Color(0xFFf093fb), const Color(0xFFf5576c)],
    ),
    OnboardingItem(
      title: 'Livreurs de confiance',
      description: 'Des livreurs professionnels et vérifiés pour assurer la sécurité de vos envois.',
      icon: Icons.verified_user_rounded,
      gradient: [const Color(0xFFfc4a1a), const Color(0xFFf7b733)],
    ),
  ];

  @override
  void initState() {
    super.initState();
    // Pas de défilement automatique pour l'onboarding
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_currentPage < _items.length - 1) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _stopAutoScroll() {
    _autoScrollTimer?.cancel();
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_onboarding', true);
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
      backgroundColor: Colors.white,
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
                    'Passer',
                    style: TextStyle(
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
              child: GestureDetector(
                onPanDown: (_) => _stopAutoScroll(),
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
                          : AppColors.primary.withOpacity(0.3),
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
                  text: _currentPage == _items.length - 1 ? 'Commencer' : 'Suivant',
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
          // Icon with gradient background
          ScaleInWidget(
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: item.gradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(40),
                boxShadow: [
                  BoxShadow(
                    color: item.gradient.first.withAlpha(100),
                    blurRadius: 30,
                    offset: const Offset(0, 15),
                  ),
                ],
              ),
              child: Icon(
                item.icon,
                size: 80,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 48),
          
          // Title
          SlideInWidget(
            beginOffset: const Offset(0, 0.3),
            child: Text(
              item.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
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
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
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
  final IconData icon;
  final List<Color> gradient;

  OnboardingItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.gradient,
  });
}
