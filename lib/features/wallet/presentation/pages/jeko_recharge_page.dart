import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/lottie_animations.dart';
import '../../../../core/widgets/loading_button.dart';
import '../../data/datasources/jeko_payment_datasource.dart';
import '../bloc/jeko_payment_bloc.dart';
import '../bloc/jeko_payment_event.dart';
import '../bloc/jeko_payment_state.dart';

/// Page de recharge du wallet via JEKO Mobile Money
class JekoRechargePage extends StatefulWidget {
  const JekoRechargePage({super.key});

  @override
  State<JekoRechargePage> createState() => _JekoRechargePageState();
}

class _JekoRechargePageState extends State<JekoRechargePage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  String? _selectedPaymentMethod;

  // Montants prédéfinis
  final List<int> _presetAmounts = [500, 1000, 2000, 5000, 10000, 20000];

  @override
  void initState() {
    super.initState();
    context.read<JekoPaymentBloc>().add(LoadPaymentMethods());
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _selectPresetAmount(int amount) {
    setState(() {
      _amountController.text = amount.toString();
    });
  }

  Future<void> _initiatePayment() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedPaymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner un mode de paiement'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount < 100) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Montant minimum: 100 FCFA'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    context.read<JekoPaymentBloc>().add(
      InitiateWalletRecharge(
        amount: amount,
        paymentMethod: _selectedPaymentMethod!,
      ),
    );
  }

  Future<void> _openPaymentUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Impossible d\'ouvrir le lien de paiement'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recharger mon portefeuille'),
        centerTitle: true,
      ),
      body: BlocConsumer<JekoPaymentBloc, JekoPaymentState>(
        listener: (context, state) {
          if (state.status == JekoPaymentStatus.paymentInitiated) {
            if (state.hasRedirectUrl) {
              _openPaymentUrl(state.paymentResult!.redirectUrl!);
              // Afficher le dialogue de confirmation
              _showPaymentPendingDialog(state.paymentResult!.transactionId!);
            }
          } else if (state.status == JekoPaymentStatus.success) {
            _showSuccessDialog(state.currentTransaction!);
          } else if (state.status == JekoPaymentStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'Une erreur est survenue'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  _buildHeader(),
                  const SizedBox(height: 24),

                  // Montants prédéfinis
                  _buildPresetAmounts(),
                  const SizedBox(height: 16),

                  // Champ montant personnalisé
                  _buildAmountField(),
                  const SizedBox(height: 24),

                  // Méthodes de paiement
                  _buildPaymentMethodsSection(state),
                  const SizedBox(height: 32),

                  // Bouton de paiement
                  _buildPaymentButton(state),
                  const SizedBox(height: 16),

                  // Note de sécurité
                  _buildSecurityNote(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.account_balance_wallet,
            size: 48,
            color: Colors.white,
          ),
          const SizedBox(height: 12),
          const Text(
            'Recharge Mobile Money',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Rechargez votre portefeuille facilement',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPresetAmounts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Montants rapides',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _presetAmounts.map((amount) {
            final isSelected = _amountController.text == amount.toString();
            return ChoiceChip(
              label: Text('$amount F'),
              selected: isSelected,
              onSelected: (_) => _selectPresetAmount(amount),
              selectedColor: AppColors.primary.withValues(alpha: 0.2),
              labelStyle: TextStyle(
                color: isSelected ? AppColors.primary : Colors.black87,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildAmountField() {
    return TextFormField(
      controller: _amountController,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(
        labelText: 'Montant personnalisé',
        hintText: 'Entrez le montant',
        prefixIcon: const Icon(Icons.attach_money),
        suffixText: 'FCFA',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Veuillez entrer un montant';
        }
        final amount = int.tryParse(value);
        if (amount == null || amount < 100) {
          return 'Montant minimum: 100 FCFA';
        }
        if (amount > 1000000) {
          return 'Montant maximum: 1,000,000 FCFA';
        }
        return null;
      },
    );
  }

  Widget _buildPaymentMethodsSection(JekoPaymentState state) {
    if (state.status == JekoPaymentStatus.loadingMethods) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: AnimatedLoadingWidget(
            size: 80,
            message: 'Chargement des méthodes...',
          ),
        ),
      );
    }

    if (state.paymentMethods.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.orange.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          children: [
            Icon(Icons.warning_amber, color: Colors.orange),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Aucune méthode de paiement disponible',
                style: TextStyle(color: Colors.orange),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Mode de paiement',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        ...state.paymentMethods.map((method) => _buildPaymentMethodTile(method)),
      ],
    );
  }

  Widget _buildPaymentMethodTile(JekoPaymentMethod method) {
    final isSelected = _selectedPaymentMethod == method.code;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border.all(
          color: isSelected ? AppColors.primary : Colors.grey.shade300,
          width: isSelected ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(12),
        color: isSelected ? AppColors.primary.withValues(alpha: 0.05) : null,
      ),
      child: RadioListTile<String>(
        value: method.code,
        groupValue: _selectedPaymentMethod,
        onChanged: (value) {
          setState(() {
            _selectedPaymentMethod = value;
          });
        },
        title: Row(
          children: [
            Text(
              method.icon,
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(width: 12),
            Text(
              method.name,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        activeColor: AppColors.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildPaymentButton(JekoPaymentState state) {
    final isLoading = state.status == JekoPaymentStatus.initiatingPayment;

    return LoadingButton(
      onPressed: _initiatePayment,
      isLoading: isLoading,
      label: 'Procéder au paiement',
      icon: Icons.payment,
      backgroundColor: AppColors.primary,
    );
  }

  Widget _buildSecurityNote() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.security,
            color: Colors.blue.shade700,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Paiement sécurisé via JEKO. Vous serez redirigé vers votre application de paiement.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.blue.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPaymentPendingDialog(int transactionId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.hourglass_empty, color: Colors.orange),
            SizedBox(width: 12),
            Text('Paiement en cours'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Vous avez été redirigé vers votre application de paiement.',
            ),
            SizedBox(height: 12),
            Text(
              'Complétez le paiement puis revenez ici pour vérifier le statut.',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Annuler
              context.read<JekoPaymentBloc>().add(
                PaymentErrorCallback(transactionId),
              );
            },
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Vérifier le statut
              context.read<JekoPaymentBloc>().add(
                PaymentSuccessCallback(transactionId),
              );
            },
            child: const Text('J\'ai payé'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(JekoTransaction transaction) {
    AnimatedSuccessDialog.show(
      context,
      title: 'Paiement réussi',
      message: 'Votre portefeuille a été crédité via ${transaction.paymentMethodName}\n${transaction.formattedAmount}',
      buttonText: 'Fermer',
      onDismiss: () {
        Navigator.of(context).pop(); // Retour à l'écran précédent
      },
    );
  }
}
