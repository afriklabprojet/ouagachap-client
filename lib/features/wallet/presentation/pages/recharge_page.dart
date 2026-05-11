import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/services/app_config_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/animations.dart';
import '../../../../core/widgets/cards.dart';
import '../../data/datasources/jeko_payment_datasource.dart';
import '../bloc/wallet_bloc.dart';
import '../bloc/wallet_event.dart';
import '../bloc/wallet_state.dart';
import '../bloc/jeko_payment_bloc.dart';
import '../bloc/jeko_payment_event.dart';
import '../bloc/jeko_payment_state.dart';

class RechargePage extends StatefulWidget {
  const RechargePage({super.key});

  @override
  State<RechargePage> createState() => _RechargePageState();
}

class _RechargePageState extends State<RechargePage> {
  int _selectedAmount = 0;
  String _selectedPaymentMethod = '';

  List<int> _amounts = [];

  @override
  void initState() {
    super.initState();
    // Charger les montants depuis la config backend
    _loadRechargeAmounts();
    // Charger les méthodes de paiement JEKO
    context.read<JekoPaymentBloc>().add(LoadPaymentMethods());
  }

  Future<void> _loadRechargeAmounts() async {
    final configService = getIt<AppConfigService>();
    await configService.getConfig();
    if (mounted) {
      setState(() {
        _amounts = configService.cachedRechargeAmounts;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<JekoPaymentBloc, JekoPaymentState>(
      listener: (context, state) {
        // Gérer les états de paiement JEKO
        if (state.status == JekoPaymentStatus.paymentInitiated &&
            state.paymentResult != null) {
          final result = state.paymentResult!;
          if (result.success && result.redirectUrl != null) {
            _showRedirectWarning(context, result.redirectUrl!);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(result.message ?? 'Erreur lors de l\'initiation'),
                backgroundColor: AppColors.error,
              ),
            );
          }
        } else if (state.status == JekoPaymentStatus.success) {
          _showSuccessConfirmation(context, state);
        } else if (state.status == JekoPaymentStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'Une erreur est survenue'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: const Text('Recharger mon compte'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Current Balance Card
              _buildBalanceCard(),
              const SizedBox(height: 32),

              // Amount Selection
              const Text(
                'Choisir un montant',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildAmountGrid(),
              const SizedBox(height: 32),

              // Payment Provider (JEKO)
              const Text(
                'Mode de paiement',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildJekoPaymentMethods(),
              const SizedBox(height: 40),

              // Recharge Button
              _buildRechargeButton(),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showRedirectWarning(BuildContext context, String url) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.open_in_browser, color: AppColors.primary),
            SizedBox(width: 10),
            Text('Redirection vers JEKO'),
          ],
        ),
        content: const Text(
          'Votre navigateur va s\'ouvrir pour finaliser le paiement.\n\n'
          'Une fois le paiement effectué, revenez sur l\'application. '
          'Votre solde sera mis à jour automatiquement.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text(
              'Continuer',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _launchPaymentUrl(url);
    }
  }

  void _showSuccessConfirmation(BuildContext context, JekoPaymentState state) {
    // Rafraîchir le wallet en arrière-plan
    context.read<WalletBloc>().add(const LoadWallet());

    final amount = state.paymentResult?.amount;
    final amountText = amount != null
        ? formatCFA(amount.toInt())
        : 'votre montant';

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: AppColors.success,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 40),
            ),
            const SizedBox(height: 20),
            const Text(
              'Recharge réussie !',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '$amountText ont été ajoutés à votre compte.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  if (context.mounted) context.pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Voir mon solde',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchPaymentUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Impossible d\'ouvrir le lien de paiement'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Widget _buildBalanceCard() {
    return BlocBuilder<WalletBloc, WalletState>(
      buildWhen: (p, c) {
        final pBal = p is WalletLoaded ? p.wallet.balance : -1;
        final cBal = c is WalletLoaded ? c.wallet.balance : -1;
        return pBal != cBal || p.runtimeType != c.runtimeType;
      },
      builder: (context, state) {
        int balance = 0;
        if (state is WalletLoaded) {
          balance = state.wallet.balance;
        }

        return FadeInWidget(
          child: WalletCard(
            balance: balance.toDouble(),
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

  Widget _buildAmountGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _amounts.length,
      itemBuilder: (context, index) {
        final amount = _amounts[index];
        final isSelected = _selectedAmount == amount;

        return GestureDetector(
          onTap: () => setState(() => _selectedAmount = amount),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? AppColors.primary : Colors.grey[300]!,
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                '$amount F',
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Méthodes de paiement JEKO depuis l'API
  Widget _buildJekoPaymentMethods() {
    return BlocBuilder<JekoPaymentBloc, JekoPaymentState>(
      buildWhen: (p, c) =>
          p.status != c.status || p.paymentMethods != c.paymentMethods,
      builder: (context, state) {
        if (state.status == JekoPaymentStatus.loadingMethods) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (state.paymentMethods.isEmpty) {
          return _buildFallbackPaymentMethods();
        }

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: state.paymentMethods.map((method) {
            return _buildJekoPaymentCard(method);
          }).toList(),
        );
      },
    );
  }

  Widget _buildJekoPaymentCard(JekoPaymentMethod method) {
    final isSelected = _selectedPaymentMethod == method.code;
    final color = _getMethodColor(method.code);

    return GestureDetector(
      onTap: () => setState(() => _selectedPaymentMethod = method.code),
      child: Container(
        width: (MediaQuery.of(context).size.width - 72) / 2,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.1) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : Colors.grey[300]!,
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Text(method.icon, style: const TextStyle(fontSize: 24)),
            ),
            const SizedBox(height: 10),
            Text(
              method.name,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: isSelected ? color : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Méthodes de paiement par défaut si l'API échoue
  Widget _buildFallbackPaymentMethods() {
    final fallbackMethods = [
      {'code': 'wave', 'name': 'Wave', 'icon': '🌊'},
      {'code': 'orange', 'name': 'Orange Money', 'icon': '🟠'},
      {'code': 'moov', 'name': 'Moov Money', 'icon': '🔵'},
      {'code': 'mtn', 'name': 'MTN MoMo', 'icon': '🟡'},
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: fallbackMethods.map((method) {
        return _buildJekoPaymentCard(
          JekoPaymentMethod(
            code: method['code']!,
            name: method['name']!,
            icon: method['icon']!,
          ),
        );
      }).toList(),
    );
  }

  Color _getMethodColor(String code) {
    switch (code.toLowerCase()) {
      case 'wave':
        return AppColors.waveLight;
      case 'orange':
        return Colors.orange;
      case 'mtn':
        return AppColors.mtnYellow;
      case 'moov':
        return Colors.blue;
      case 'djamo':
        return AppColors.djamoLight;
      default:
        return AppColors.primary;
    }
  }

  Widget _buildRechargeButton() {
    return BlocBuilder<JekoPaymentBloc, JekoPaymentState>(
      buildWhen: (p, c) => p.status != c.status,
      builder: (context, state) {
        final isLoading = state.status == JekoPaymentStatus.initiatingPayment;
        final isValid =
            _selectedAmount > 0 && _selectedPaymentMethod.isNotEmpty;

        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: isValid && !isLoading ? _onRecharge : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              disabledBackgroundColor: Colors.grey[300],
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.lock, color: Colors.white, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Payer ${formatCFA(_selectedAmount)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }

  void _onRecharge() {
    context.read<JekoPaymentBloc>().add(
      InitiateWalletRecharge(
        amount: _selectedAmount.toDouble(),
        paymentMethod: _selectedPaymentMethod,
      ),
    );
  }
}
