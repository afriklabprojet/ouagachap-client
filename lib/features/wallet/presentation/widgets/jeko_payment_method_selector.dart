import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/datasources/jeko_payment_datasource.dart';

/// Widget de sélection de méthode de paiement JEKO
class JekoPaymentMethodSelector extends StatelessWidget {
  final List<JekoPaymentMethod> methods;
  final String? selectedMethod;
  final ValueChanged<String?> onMethodSelected;
  final bool isLoading;

  const JekoPaymentMethodSelector({
    super.key,
    required this.methods,
    required this.selectedMethod,
    required this.onMethodSelected,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (methods.isEmpty) {
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
      children: methods.map((method) => _buildMethodTile(method)).toList(),
    );
  }

  Widget _buildMethodTile(JekoPaymentMethod method) {
    final isSelected = selectedMethod == method.code;
    
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
        groupValue: selectedMethod,
        onChanged: onMethodSelected,
        title: Row(
          children: [
            _buildMethodIcon(method),
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

  Widget _buildMethodIcon(JekoPaymentMethod method) {
    // Mapping des codes vers des couleurs
    final colorMap = {
      'wave': const Color(0xFF1DC3E8),
      'orange': const Color(0xFFFF6600),
      'mtn': const Color(0xFFFFCC00),
      'moov': const Color(0xFF0066CC),
      'djamo': const Color(0xFF6C5CE7),
    };

    final color = colorMap[method.code] ?? Colors.grey;

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Text(
          method.icon,
          style: const TextStyle(fontSize: 22),
        ),
      ),
    );
  }
}

/// Bottom sheet pour sélectionner une méthode de paiement
class JekoPaymentMethodBottomSheet extends StatefulWidget {
  final List<JekoPaymentMethod> methods;
  final String? initialMethod;
  final double amount;
  final String currency;

  const JekoPaymentMethodBottomSheet({
    super.key,
    required this.methods,
    this.initialMethod,
    required this.amount,
    this.currency = 'FCFA',
  });

  /// Afficher le bottom sheet et retourner la méthode sélectionnée
  static Future<String?> show({
    required BuildContext context,
    required List<JekoPaymentMethod> methods,
    String? initialMethod,
    required double amount,
    String currency = 'FCFA',
  }) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => JekoPaymentMethodBottomSheet(
        methods: methods,
        initialMethod: initialMethod,
        amount: amount,
        currency: currency,
      ),
    );
  }

  @override
  State<JekoPaymentMethodBottomSheet> createState() =>
      _JekoPaymentMethodBottomSheetState();
}

class _JekoPaymentMethodBottomSheetState
    extends State<JekoPaymentMethodBottomSheet> {
  String? _selectedMethod;

  @override
  void initState() {
    super.initState();
    _selectedMethod = widget.initialMethod;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // Titre
          const Text(
            'Choisir le mode de paiement',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          // Montant
          Text(
            '${widget.amount.toStringAsFixed(0)} ${widget.currency}',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 20),

          // Liste des méthodes
          JekoPaymentMethodSelector(
            methods: widget.methods,
            selectedMethod: _selectedMethod,
            onMethodSelected: (value) {
              setState(() {
                _selectedMethod = value;
              });
            },
          ),
          const SizedBox(height: 20),

          // Bouton confirmer
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _selectedMethod != null
                  ? () => Navigator.pop(context, _selectedMethod)
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Confirmer',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
