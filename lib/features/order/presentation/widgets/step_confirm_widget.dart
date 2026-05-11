import 'package:flutter/material.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/animations.dart';

/// Étape 3 — Confirmation de la commande.
class StepConfirmWidget extends StatelessWidget {
  final String pickupAddress;
  final String? pickupContactName;
  final String? pickupContactPhone;
  final String deliveryAddress;
  final String recipientName;
  final String recipientPhone;
  final String? packageDescription;
  final double estimatedDistance;
  final double basePrice;
  final double distancePrice;
  final double estimatedPrice;
  final bool isSurge;
  final double surgeMultiplier;
  final String selectedPaymentMethod;
  final ValueChanged<String> onPaymentMethodChanged;

  const StepConfirmWidget({
    super.key,
    required this.pickupAddress,
    this.pickupContactName,
    this.pickupContactPhone,
    required this.deliveryAddress,
    required this.recipientName,
    required this.recipientPhone,
    this.packageDescription,
    required this.estimatedDistance,
    required this.basePrice,
    required this.distancePrice,
    required this.estimatedPrice,
    this.isSurge = false,
    this.surgeMultiplier = 1.0,
    required this.selectedPaymentMethod,
    required this.onPaymentMethodChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const FadeInWidget(
            delay: Duration(milliseconds: 100),
            child: Text(
              'Confirmation',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 8),
          FadeInWidget(
            delay: const Duration(milliseconds: 150),
            child: Text(
              'Vérifiez les informations de votre commande',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          const SizedBox(height: 24),
          // Pickup summary
          SlideInWidget(
            delay: const Duration(milliseconds: 200),
            child: _buildSummaryCard(
              title: 'Récupération',
              icon: Icons.location_on_outlined,
              iconColor: AppColors.primary,
              items: [
                pickupAddress,
                if (pickupContactName != null && pickupContactName!.isNotEmpty)
                  'Contact: $pickupContactName',
                if (pickupContactPhone != null &&
                    pickupContactPhone!.isNotEmpty)
                  'Tél: +226 $pickupContactPhone',
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Delivery summary
          SlideInWidget(
            delay: const Duration(milliseconds: 300),
            child: _buildSummaryCard(
              title: 'Livraison',
              icon: Icons.location_on,
              iconColor: AppColors.secondary,
              items: [
                deliveryAddress,
                'Destinataire: $recipientName',
                'Tél: +226 $recipientPhone',
                if (packageDescription != null &&
                    packageDescription!.isNotEmpty)
                  'Colis: $packageDescription',
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Price summary
          ScaleInWidget(
            delay: const Duration(milliseconds: 400),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Distance estimée'),
                      Text('${estimatedDistance.toStringAsFixed(1)} km'),
                    ],
                  ),
                  if (basePrice > 0) ...[
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Prix de base'),
                        Text('${basePrice.toInt()} FCFA'),
                      ],
                    ),
                  ],
                  if (distancePrice > 0) ...[
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Prix distance'),
                        Text('${distancePrice.toInt()} FCFA'),
                      ],
                    ),
                  ],
                  if (isSurge) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange.shade300),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Text('🔥',
                                  style: TextStyle(fontSize: 14)),
                              const SizedBox(width: 6),
                              Text(
                                'Forte demande',
                                style: TextStyle(
                                  color: Colors.orange.shade700,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade200,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '+${((surgeMultiplier - 1) * 100).round()}%',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.orange.shade900,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  const Divider(),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Prix total',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '${estimatedPrice.toInt()} ${context.l10n.currency}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Payment method selection
          SlideInWidget(
            delay: const Duration(milliseconds: 500),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.paymentMethod,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _buildPaymentOption(
                  id: 'cash',
                  icon: Icons.payments_outlined,
                  color: Colors.green,
                  title: context.l10n.translate('cash'),
                  subtitle: context.l10n.payCashSubtitle,
                ),
                const SizedBox(height: 8),
                _buildPaymentOption(
                  id: 'orange_money',
                  icon: Icons.phone_android,
                  color: Colors.orange,
                  title: 'Orange Money',
                  subtitle: context.l10n.payMobileMoneySubtitle,
                ),
                const SizedBox(height: 8),
                _buildPaymentOption(
                  id: 'moov_money',
                  icon: Icons.phone_android,
                  color: Colors.blue,
                  title: 'Moov Money',
                  subtitle: context.l10n.payMobileMoneySubtitle,
                ),
                const SizedBox(height: 8),
                _buildPaymentOption(
                  id: 'wave',
                  icon: Icons.waves,
                  color: Colors.lightBlue,
                  title: 'Wave',
                  subtitle: context.l10n.payWaveSubtitle,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<String> items,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                item,
                style: TextStyle(color: Colors.grey[700], fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption({
    required String id,
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
  }) {
    final isSelected = selectedPaymentMethod == id;
    return GestureDetector(
      onTap: () => onPaymentMethodChanged(id),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.08) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isSelected ? color : Colors.black87,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected
                          ? color.withValues(alpha: 0.7)
                          : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? color : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
