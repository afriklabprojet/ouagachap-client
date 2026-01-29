import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Widget d'erreur réutilisable avec option de retry
class ErrorWidget extends StatelessWidget {
  final String title;
  final String? message;
  final VoidCallback? onRetry;
  final IconData icon;
  final Color? iconColor;
  final bool compact;

  const ErrorWidget({
    super.key,
    this.title = 'Une erreur est survenue',
    this.message,
    this.onRetry,
    this.icon = Icons.error_outline,
    this.iconColor,
    this.compact = false,
  });

  /// Erreur de connexion réseau
  factory ErrorWidget.network({VoidCallback? onRetry}) {
    return ErrorWidget(
      icon: Icons.wifi_off_outlined,
      title: 'Pas de connexion',
      message: 'Vérifiez votre connexion internet',
      onRetry: onRetry,
    );
  }

  /// Erreur serveur
  factory ErrorWidget.server({VoidCallback? onRetry}) {
    return ErrorWidget(
      icon: Icons.cloud_off_outlined,
      title: 'Erreur serveur',
      message: 'Le serveur est indisponible. Réessayez plus tard.',
      onRetry: onRetry,
    );
  }

  /// Timeout
  factory ErrorWidget.timeout({VoidCallback? onRetry}) {
    return ErrorWidget(
      icon: Icons.hourglass_empty,
      title: 'Délai dépassé',
      message: 'La requête a pris trop de temps',
      onRetry: onRetry,
    );
  }

  /// Session expirée
  factory ErrorWidget.sessionExpired({VoidCallback? onLogin}) {
    return ErrorWidget(
      icon: Icons.lock_outline,
      title: 'Session expirée',
      message: 'Veuillez vous reconnecter',
      onRetry: onLogin,
    );
  }

  /// Erreur de localisation
  factory ErrorWidget.location({VoidCallback? onRetry}) {
    return ErrorWidget(
      icon: Icons.location_off_outlined,
      title: 'Localisation indisponible',
      message: 'Impossible d\'obtenir votre position',
      onRetry: onRetry,
    );
  }

  /// Erreur de permission
  factory ErrorWidget.permission({VoidCallback? onSettings}) {
    return ErrorWidget(
      icon: Icons.block_outlined,
      title: 'Permission refusée',
      message: 'Activez les permissions dans les paramètres',
      onRetry: onSettings,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return _buildCompact(context);
    }
    return _buildFull(context);
  }

  Widget _buildCompact(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.error.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: iconColor ?? AppColors.error,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.error,
                  ),
                ),
                if (message != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    message!,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.error.withOpacity(0.8),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.refresh, size: 20),
              color: AppColors.error,
              onPressed: onRetry,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(
                minWidth: 36,
                minHeight: 36,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFull(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: (iconColor ?? AppColors.error).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 64,
                color: iconColor ?? AppColors.error,
              ),
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
            if (message != null) ...[
              const SizedBox(height: 8),
              Text(
                message!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh, size: 20),
                label: const Text('Réessayer'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
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
