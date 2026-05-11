import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/services/changelog_service.dart';
import '../../../../core/services/deep_link_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/animations.dart';
import '../../../notification/presentation/bloc/notification_bloc.dart';
import '../../../notification/presentation/bloc/notification_event.dart';
import '../../../order/presentation/bloc/order_bloc.dart';
import '../../../order/presentation/bloc/order_event.dart';
import '../../../wallet/presentation/bloc/wallet_bloc.dart';
import '../../../wallet/presentation/bloc/wallet_event.dart';
import '../../../wallet/presentation/bloc/wallet_state.dart';
import '../../../promo/presentation/bloc/promo_bloc.dart';
import '../../../promo/presentation/bloc/promo_event.dart';
import '../../../promo/presentation/bloc/promo_state.dart';
import '../widgets/active_orders_banner.dart';
import '../widgets/home_header.dart';
import '../widgets/service_grid_widget.dart';
import '../widgets/promo_carousel_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  /// Subscription pour les deep links — DOIT être cancel dans dispose()
  StreamSubscription? _deepLinkSubscription;

  @override
  void initState() {
    super.initState();
    context.read<OrderBloc>().add(const GetOrdersRequested(refresh: true));
    context.read<WalletBloc>().add(const LoadWallet());
    context.read<NotificationBloc>().add(const LoadNotifications());
    context.read<PromoBloc>().add(const LoadPromoCodes());
    _checkChangelogAndDeepLinks();
  }

  Future<void> _checkChangelogAndDeepLinks() async {
    // Attendre que le premier frame soit rendu avant d'afficher des dialogs
    final completer = Completer<void>();
    WidgetsBinding.instance.addPostFrameCallback((_) => completer.complete());
    await completer.future;
    if (!mounted) return;

    // Vérifier et afficher le changelog si nouvelle version
    final changelogService = getIt<ChangelogService>();
    if (changelogService.shouldShowChangelog()) {
      await changelogService.showChangelogDialog(context);
    }

    // Écouter les deep links
    final deepLinkService = getIt<DeepLinkService>();
    _deepLinkSubscription = deepLinkService.onDeepLink.listen(
      _handleDeepLink,
      onError: (e) {
        debugPrint('❌ Deep link error: $e');
      },
    );
  }

  void _handleDeepLink(DeepLinkData data) {
    if (!mounted) return;

    switch (data.type) {
      case DeepLinkType.order:
        context.push('${Routes.orderDetails}/${data.id}');
        break;
      case DeepLinkType.tracking:
        context.push('${Routes.orderTracking}/${data.id}');
        break;
      case DeepLinkType.promo:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.l10n
                  .translate('promo_applied_snack')
                  .replaceAll('%s', data.id),
            ),
            backgroundColor: AppColors.success,
          ),
        );
        break;
      case DeepLinkType.referral:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.l10n
                  .translate('referral_validated')
                  .replaceAll('%s', data.id),
            ),
            backgroundColor: AppColors.success,
          ),
        );
        break;
    }
  }

  @override
  void dispose() {
    _deepLinkSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            context.read<OrderBloc>().add(
              const GetOrdersRequested(refresh: true),
            );
            context.read<WalletBloc>().add(const LoadWallet());
            context.read<NotificationBloc>().add(const LoadNotifications());
            context.read<PromoBloc>().add(const LoadPromoCodes());
          },
          child: CustomScrollView(
            slivers: [
              const SliverPadding(
                padding: EdgeInsets.fromLTRB(24, 24, 24, 16),
                sliver: SliverToBoxAdapter(
                  child: RepaintBoundary(
                    child: FadeInWidget(child: HomeHeader()),
                  ),
                ),
              ),

              const SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                sliver: SliverToBoxAdapter(
                  child: RepaintBoundary(
                    child: SlideInWidget(
                      delay: Duration(milliseconds: 50),
                      child: _WelcomeBanner(),
                    ),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 32)),

              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                sliver: SliverToBoxAdapter(
                  child: RepaintBoundary(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FadeInWidget(
                          delay: const Duration(milliseconds: 100),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                context.l10n.services,
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  context.l10n.servicesCount,
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        const ScaleInWidget(
                          delay: Duration(milliseconds: 150),
                          child: ServiceGridWidget(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SliverToBoxAdapter(
                child: FadeInWidget(
                  delay: Duration(milliseconds: 200),
                  child: PromoCarouselWidget(),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 28)),

              const SliverToBoxAdapter(
                child: RepaintBoundary(
                  child: SlideInWidget(
                    delay: Duration(milliseconds: 250),
                    child: ActiveOrdersBanner(),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('${Routes.home}/${Routes.createOrder}'),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.send_rounded, color: Colors.white),
        label: const Text(
          'Envoyer un colis',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

// Extracted to StatelessWidget so Flutter caches widget identity across
// parent rebuilds — only rebuilds internally when wallet balance changes.
class _WelcomeBanner extends StatelessWidget {
  const _WelcomeBanner();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WalletBloc, WalletState>(
      buildWhen: (p, c) {
        final pBalance = p is WalletLoaded ? p.wallet.balance : -1;
        final cBalance = c is WalletLoaded ? c.wallet.balance : -1;
        return pBalance != cBalance || p.runtimeType != c.runtimeType;
      },
      builder: (context, walletState) {
        int balance = 0;
        if (walletState is WalletLoaded) {
          balance = walletState.wallet.balance;
        }

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: AppColors.walletGradient,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n.balance,
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        formatCFA(balance),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  BlocBuilder<PromoBloc, PromoState>(
                    buildWhen: (p, c) =>
                        p.promoCodes.length != c.promoCodes.length ||
                        p.status != c.status,
                    builder: (context, promoState) {
                      final count = promoState.promoCodes.length;
                      if (count == 0) return const SizedBox.shrink();
                      return GestureDetector(
                        onTap: () =>
                            context.push('${Routes.home}/${Routes.promotions}'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.local_offer,
                                color: Colors.white,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '$count',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () =>
                          context.go('${Routes.home}/${Routes.createOrder}'),
                      icon: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 20,
                      ),
                      label: Text(
                        context.l10n.newDelivery,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => context.go(
                        '${Routes.wallet}/${Routes.walletRecharge}',
                      ),
                      icon: const Icon(
                        Icons.account_balance_wallet,
                        color: Colors.white,
                        size: 20,
                      ),
                      label: Text(
                        context.l10n.recharge,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white30),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
