import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Dialogue de succès animé
class SuccessDialog extends StatefulWidget {
  final String title;
  final String? message;
  final String? buttonText;
  final VoidCallback? onDismiss;
  final Duration autoDismiss;
  final IconData icon;

  const SuccessDialog({
    super.key,
    this.title = 'Succès !',
    this.message,
    this.buttonText,
    this.onDismiss,
    this.autoDismiss = Duration.zero,
    this.icon = Icons.check_circle,
  });

  /// Affiche le dialogue de succès
  static Future<void> show(
    BuildContext context, {
    String title = 'Succès !',
    String? message,
    String? buttonText,
    VoidCallback? onDismiss,
    Duration autoDismiss = Duration.zero,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => SuccessDialog(
        title: title,
        message: message,
        buttonText: buttonText,
        onDismiss: onDismiss,
        autoDismiss: autoDismiss,
      ),
    );
  }

  /// Commande confirmée
  static Future<void> orderConfirmed(BuildContext context, {VoidCallback? onDismiss}) {
    return show(
      context,
      title: 'Commande confirmée !',
      message: 'Votre commande a été créée avec succès',
      buttonText: 'Continuer',
      onDismiss: onDismiss,
    );
  }

  /// Paiement réussi
  static Future<void> paymentSuccess(BuildContext context, {VoidCallback? onDismiss}) {
    return show(
      context,
      title: 'Paiement réussi !',
      message: 'Votre paiement a été effectué avec succès',
      buttonText: 'OK',
      onDismiss: onDismiss,
    );
  }

  /// Profil mis à jour
  static Future<void> profileUpdated(BuildContext context, {VoidCallback? onDismiss}) {
    return show(
      context,
      title: 'Profil mis à jour !',
      message: 'Vos informations ont été enregistrées',
      autoDismiss: const Duration(seconds: 2),
      onDismiss: onDismiss,
    );
  }

  @override
  State<SuccessDialog> createState() => _SuccessDialogState();
}

class _SuccessDialogState extends State<SuccessDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ),
    );
    
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );
    
    _controller.forward();
    
    // Auto-dismiss si configuré
    if (widget.autoDismiss > Duration.zero) {
      Future.delayed(widget.autoDismiss, _dismiss);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _dismiss() {
    if (mounted) {
      Navigator.of(context).pop();
      widget.onDismiss?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnimation.value,
          child: Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: child,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icône animée
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 800),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      widget.icon,
                      size: 48,
                      color: AppColors.success,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            
            // Titre
            Text(
              widget.title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            
            // Message
            if (widget.message != null) ...[
              const SizedBox(height: 8),
              Text(
                widget.message!,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            
            // Bouton
            if (widget.buttonText != null) ...[
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _dismiss,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    widget.buttonText!,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
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

/// Dialogue de confirmation
class ConfirmDialog extends StatelessWidget {
  final String title;
  final String? message;
  final String confirmText;
  final String cancelText;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final Color confirmColor;
  final IconData? icon;
  final bool isDangerous;

  const ConfirmDialog({
    super.key,
    required this.title,
    this.message,
    this.confirmText = 'Confirmer',
    this.cancelText = 'Annuler',
    this.onConfirm,
    this.onCancel,
    this.confirmColor = AppColors.primary,
    this.icon,
    this.isDangerous = false,
  });

  /// Affiche le dialogue de confirmation
  static Future<bool?> show(
    BuildContext context, {
    required String title,
    String? message,
    String confirmText = 'Confirmer',
    String cancelText = 'Annuler',
    bool isDangerous = false,
    bool isDestructive = false, // Alias pour isDangerous (compatibilité)
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => ConfirmDialog(
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
        isDangerous: isDangerous || isDestructive,
        onConfirm: () => Navigator.of(context).pop(true),
        onCancel: () => Navigator.of(context).pop(false),
      ),
    );
  }

  /// Confirmation de déconnexion
  static Future<bool?> logout(BuildContext context) {
    return show(
      context,
      title: 'Déconnexion',
      message: 'Voulez-vous vraiment vous déconnecter ?',
      confirmText: 'Se déconnecter',
      isDangerous: true,
    );
  }

  /// Confirmation d'annulation de commande
  static Future<bool?> cancelOrder(BuildContext context) {
    return show(
      context,
      title: 'Annuler la commande',
      message: 'Voulez-vous vraiment annuler cette commande ?',
      confirmText: 'Annuler la commande',
      isDangerous: true,
    );
  }

  /// Confirmation de suppression
  static Future<bool?> delete(BuildContext context, {String? itemName}) {
    return show(
      context,
      title: 'Supprimer',
      message: itemName != null 
          ? 'Voulez-vous vraiment supprimer "$itemName" ?' 
          : 'Voulez-vous vraiment supprimer cet élément ?',
      confirmText: 'Supprimer',
      isDangerous: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final effectiveConfirmColor = isDangerous ? AppColors.error : confirmColor;
    
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: effectiveConfirmColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: effectiveConfirmColor,
                ),
              ),
              const SizedBox(height: 16),
            ],
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            if (message != null) ...[
              const SizedBox(height: 8),
              Text(
                message!,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onCancel,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(cancelText),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onConfirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: effectiveConfirmColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(confirmText),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
