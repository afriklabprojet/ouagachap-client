import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Widget d'état vide réutilisable
class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final String? actionText;
  final VoidCallback? onAction;
  final Color? iconColor;
  final double iconSize;
  final Widget? customImage;

  const EmptyStateWidget({
    super.key,
    required this.title,
    this.subtitle,
    this.icon = Icons.inbox_outlined,
    this.actionText,
    this.onAction,
    this.iconColor,
    this.iconSize = 80,
    this.customImage,
  });

  /// État vide pour les commandes
  factory EmptyStateWidget.orders({
    VoidCallback? onCreate,
    String? title,
    String? subtitle,
  }) {
    return EmptyStateWidget(
      icon: Icons.receipt_long_outlined,
      title: title ?? 'Aucune commande',
      subtitle: subtitle ?? 'Vous n\'avez pas encore de commande',
      actionText: onCreate != null ? 'Créer une commande' : null,
      onAction: onCreate,
    );
  }

  /// État vide pour les notifications
  factory EmptyStateWidget.notifications() {
    return const EmptyStateWidget(
      icon: Icons.notifications_none_outlined,
      title: 'Aucune notification',
      subtitle: 'Vous êtes à jour !',
    );
  }

  /// État vide pour les transactions
  factory EmptyStateWidget.transactions() {
    return const EmptyStateWidget(
      icon: Icons.account_balance_wallet_outlined,
      title: 'Aucune transaction',
      subtitle: 'Vos transactions apparaîtront ici',
    );
  }

  /// État vide pour la recherche
  factory EmptyStateWidget.search({String? query}) {
    return EmptyStateWidget(
      icon: Icons.search_off_outlined,
      title: 'Aucun résultat',
      subtitle: query != null 
          ? 'Aucun résultat pour "$query"' 
          : 'Essayez une autre recherche',
    );
  }

  /// État vide pour les coursiers disponibles
  factory EmptyStateWidget.noCouriers() {
    return const EmptyStateWidget(
      icon: Icons.delivery_dining_outlined,
      title: 'Aucun coursier disponible',
      subtitle: 'Réessayez dans quelques instants',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            customImage ?? Icon(
              icon,
              size: iconSize,
              color: iconColor ?? AppColors.textTertiary.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionText != null && onAction != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  actionText!,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
