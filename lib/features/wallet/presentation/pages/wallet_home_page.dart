import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/animations.dart';
import '../../../../core/widgets/cards.dart';
import '../../../../core/widgets/skeleton_loaders.dart';
import '../../data/datasources/jeko_payment_datasource.dart';
import '../bloc/jeko_payment_bloc.dart';
import '../bloc/jeko_payment_event.dart';
import '../bloc/jeko_payment_state.dart';
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
    context.read<JekoPaymentBloc>().add(const LoadTransactionHistory());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<WalletBloc>().add(const LoadWallet());
          context.read<JekoPaymentBloc>().add(const LoadTransactionHistory());
        },
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              title: Text(context.l10n.walletTitle),
              centerTitle: true,
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
            context.push('${Routes.wallet}/${Routes.walletRecharge}'),
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
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              context.l10n.recentTransactions,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () =>
                  context.push('${Routes.wallet}/${Routes.jekoHistory}'),
              child: Text(context.l10n.translate('see_all')),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildRecentTransactions(),
      ],
    );
  }

  Widget _buildRecentTransactions() {
    return BlocBuilder<JekoPaymentBloc, JekoPaymentState>(
      buildWhen: (p, c) =>
          p.status != c.status || p.transactionHistory != c.transactionHistory,
      builder: (context, state) {
        if (state.status == JekoPaymentStatus.loadingHistory &&
            state.transactionHistory.isEmpty) {
          return const SkeletonTransactionListLoader(itemCount: 3);
        }

        if (state.transactionHistory.isEmpty) {
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 32),
            alignment: Alignment.center,
            child: Text(
              context.l10n.noTransactions,
              style: TextStyle(color: Colors.grey[500]),
            ),
          );
        }

        final recent = state.transactionHistory.take(5).toList();
        return Column(
          children: recent.asMap().entries.map((entry) {
            return SlideInWidget(
              delay: Duration(milliseconds: 50 * entry.key),
              child: _buildTransactionTile(entry.value),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildTransactionTile(JekoTransaction transaction) {
    const iconMap = {
      'wave': '🌊',
      'orange': '🟠',
      'mtn': '🟡',
      'moov': '🔵',
      'djamo': '💳',
    };
    final colorMap = <String, Color>{
      'wave': AppColors.wavePrimary,
      'orange': AppColors.orangeMoney,
      'mtn': AppColors.mtnYellow,
      'moov': AppColors.moovBlue,
      'djamo': AppColors.djamoPurple,
    };
    final icon = iconMap[transaction.paymentMethod] ?? '💰';
    final color = colorMap[transaction.paymentMethod] ?? Colors.grey;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(icon, style: const TextStyle(fontSize: 22)),
          ),
        ),
        title: Text(
          transaction.type == 'wallet_recharge'
              ? 'Recharge portefeuille'
              : 'Paiement commande',
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        subtitle: Text(
          transaction.paymentMethodName,
          style: TextStyle(fontSize: 12, color: Colors.grey[500]),
        ),
        trailing: Text(
          transaction.formattedAmount,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: transaction.isSuccessful
                ? Colors.green
                : transaction.isFailed
                ? Colors.red
                : Colors.orange,
          ),
        ),
      ),
    );
  }
}
