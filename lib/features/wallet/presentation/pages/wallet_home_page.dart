import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/animations.dart';
import '../../../../core/widgets/cards.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/skeleton_loaders.dart';
import '../bloc/wallet_bloc.dart';
import '../bloc/wallet_event.dart';
import '../bloc/wallet_state.dart';

class WalletHomePage extends StatefulWidget {
  const WalletHomePage({super.key});

  @override
  State<WalletHomePage> createState() => _WalletHomePageState();
}

class _WalletHomePageState extends State<WalletHomePage> {
  @override
  void initState() {
    super.initState();
    context.read<WalletBloc>().add(const LoadWallet());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<WalletBloc>().add(const LoadWallet());
          await context
              .read<WalletBloc>()
              .stream
              .firstWhere(
                (s) => s is! WalletLoading,
                orElse: () => WalletInitial(),
              )
              .timeout(
                const Duration(seconds: 5),
                onTimeout: () => WalletInitial(),
              );
        },
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              title: Text(context.l10n.walletTitle),
              floating: true,
              backgroundColor: Theme.of(context).colorScheme.surface,
              foregroundColor: Theme.of(context).colorScheme.onSurface,
              elevation: 0,
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBalanceCard(),
                    const SizedBox(height: 16),
                    _buildRechargeButton(),
                    const SizedBox(height: 28),
                    _buildTransactionsSection(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard() {
    return BlocBuilder<WalletBloc, WalletState>(
      buildWhen: (p, c) {
        final pBal = p is WalletLoaded ? p.wallet.balance : -1;
        final cBal = c is WalletLoaded ? c.wallet.balance : -1;
        return pBal != cBal || p.runtimeType != c.runtimeType;
      },
      builder: (context, state) {
        if (state is WalletLoading || state is WalletInitial) {
          return Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(
              height: 160,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          );
        }

        if (state is WalletError) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.red),
                const SizedBox(width: 12),
                Expanded(child: Text(state.message)),
                TextButton(
                  onPressed: () =>
                      context.read<WalletBloc>().add(const LoadWallet()),
                  child: const Text('Réessayer'),
                ),
              ],
            ),
          );
        }

        final balance = state is WalletLoaded
            ? state.wallet.balance.toDouble()
            : 0.0;
        return FadeInWidget(
          child: WalletCard(
            balance: balance,
            currency: 'FCFA',
            gradientColors: const [
              AppColors.walletBannerDark,
              AppColors.walletBannerDarker,
            ],
          ),
        );
      },
    );
  }

  Widget _buildRechargeButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () =>
            context.push('${Routes.wallet}/${Routes.sappayRecharge}'),
        icon: const Icon(Icons.add_circle_outline, color: Colors.white),
        label: Text(
          context.l10n.recharge,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionsSection() {
    return BlocBuilder<WalletBloc, WalletState>(
      builder: (context, state) {
        if (state is WalletLoading || state is WalletInitial) {
          return Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Column(
              children: List.generate(
                3,
                (_) => const Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: TransactionCardSkeleton(),
                ),
              ),
            ),
          );
        }

        if (state is WalletError) {
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 24),
            alignment: Alignment.center,
            child: Column(
              children: [
                Icon(Icons.error_outline, color: Colors.red.shade300, size: 40),
                const SizedBox(height: 8),
                Text(
                  'Impossible de charger les transactions',
                  style: TextStyle(color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () =>
                      context.read<WalletBloc>().add(const LoadWallet()),
                  child: const Text('Réessayer'),
                ),
              ],
            ),
          );
        }

        // WalletLoaded : le repository ne retourne pas de transactions pour l'instant
        return EmptyStateWidget.transactions();
      },
    );
  }
}
