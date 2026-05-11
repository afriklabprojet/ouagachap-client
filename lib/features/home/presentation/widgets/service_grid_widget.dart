import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';

class ServiceGridWidget extends StatelessWidget {
  const ServiceGridWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final services = [
      _ServiceItem(
        icon: Icons.local_shipping_outlined,
        label: context.l10n.translate('service_send'),
        subtitle: context.l10n.translate('service_send_subtitle'),
        color: const Color(0xFFFFF3E0),
        iconColor: AppColors.primary,
        badge: 'Express',
        badgeColor: AppColors.primary,
        onTap: () => context.go('${Routes.home}/${Routes.createOrder}'),
      ),
      _ServiceItem(
        icon: Icons.location_on_outlined,
        label: context.l10n.translate('service_addresses'),
        subtitle: context.l10n.translate('service_addresses_subtitle'),
        color: const Color(0xFFE8EAF6),
        iconColor: const Color(0xFF3F51B5),
        onTap: () => context.go('${Routes.profile}/${Routes.addresses}'),
      ),
      _ServiceItem(
        icon: Icons.inventory_2_outlined,
        label: context.l10n.translate('service_orders'),
        subtitle: context.l10n.translate('service_orders_subtitle'),
        color: const Color(0xFFE3F2FD),
        iconColor: const Color(0xFF1976D2),
        onTap: () => context.go(Routes.ordersHistory),
      ),
      _ServiceItem(
        icon: Icons.account_balance_wallet_outlined,
        label: context.l10n.translate('service_topup'),
        subtitle: context.l10n.translate('service_topup_subtitle'),
        color: const Color(0xFFE8F5E9),
        iconColor: const Color(0xFF388E3C),
        onTap: () => context.go('${Routes.wallet}/${Routes.walletRecharge}'),
      ),
      _ServiceItem(
        icon: Icons.support_agent_outlined,
        label: context.l10n.translate('service_support'),
        subtitle: context.l10n.translate('service_support_subtitle'),
        color: const Color(0xFFF3E5F5),
        iconColor: const Color(0xFF7B1FA2),
        badge: 'Live',
        badgeColor: const Color(0xFF7B1FA2),
        onTap: () => context.go('${Routes.profile}/${Routes.support}'),
      ),
      _ServiceItem(
        icon: Icons.person_outline,
        label: context.l10n.translate('service_profile'),
        subtitle: context.l10n.translate('service_profile_subtitle'),
        color: const Color(0xFFE0F2F1),
        iconColor: const Color(0xFF00897B),
        onTap: () => context.go(Routes.profile),
      ),
    ];

    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildServiceCard(services[0])),
            const SizedBox(width: 12),
            Expanded(child: _buildServiceCard(services[1])),
            const SizedBox(width: 12),
            Expanded(child: _buildServiceCard(services[2])),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildServiceCard(services[3])),
            const SizedBox(width: 12),
            Expanded(child: _buildServiceCard(services[4])),
            const SizedBox(width: 12),
            Expanded(child: _buildServiceCard(services[5])),
          ],
        ),
      ],
    );
  }

  Widget _buildServiceCard(_ServiceItem service) {
    return Ink(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: InkWell(
        onTap: service.onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Stack(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: service.color,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      service.icon,
                      color: service.iconColor,
                      size: 26,
                    ),
                  ),
                  if (service.badge != null)
                    Positioned(
                      top: -2,
                      right: -2,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: service.badgeColor ?? AppColors.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          service.badge!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                service.label,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: Color(0xFF1A1A2E),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 2),
              Text(
                service.subtitle,
                style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ServiceItem {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final Color iconColor;
  final String? badge;
  final Color? badgeColor;
  final VoidCallback onTap;

  const _ServiceItem({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.iconColor,
    this.badge,
    this.badgeColor,
    required this.onTap,
  });
}
