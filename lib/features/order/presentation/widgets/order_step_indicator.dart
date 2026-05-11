import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Indicateur de progression 3 étapes pour le flow de création de commande.
class OrderStepIndicator extends StatelessWidget {
  final int currentStep;

  const OrderStepIndicator({super.key, required this.currentStep});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _buildStep(0, 'Récupération'),
          _buildLine(0),
          _buildStep(1, 'Livraison'),
          _buildLine(1),
          _buildStep(2, 'Confirmation'),
        ],
      ),
    );
  }

  Widget _buildStep(int step, String label) {
    final isActive = currentStep >= step;
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: isActive ? AppColors.primary : Colors.grey[300],
              shape: BoxShape.circle,
            ),
            child: Center(
              child: isActive && currentStep > step
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : Text(
                      '${step + 1}',
                      style: TextStyle(
                        color: isActive ? Colors.white : Colors.grey[600],
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: isActive ? AppColors.primary : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLine(int afterStep) {
    return Container(
      width: 40,
      height: 2,
      color: currentStep > afterStep ? AppColors.primary : Colors.grey[300],
    );
  }
}
