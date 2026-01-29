import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

/// Chemins des animations Lottie
class LottieAssets {
  LottieAssets._();

  static const String success = 'assets/animations/success.json';
  static const String error = 'assets/animations/error.json';
  static const String loading = 'assets/animations/loading.json';
  static const String empty = 'assets/animations/empty.json';
  static const String delivery = 'assets/animations/delivery.json';
}

/// Widget d'animation Lottie configurable
class LottieAnimation extends StatelessWidget {
  final String asset;
  final double? width;
  final double? height;
  final BoxFit fit;
  final bool repeat;
  final bool reverse;
  final AnimationController? controller;
  final void Function(LottieComposition)? onLoaded;

  const LottieAnimation({
    super.key,
    required this.asset,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.repeat = true,
    this.reverse = false,
    this.controller,
    this.onLoaded,
  });

  /// Animation de succès
  factory LottieAnimation.success({
    double? size,
    bool repeat = false,
    void Function(LottieComposition)? onLoaded,
  }) {
    return LottieAnimation(
      asset: LottieAssets.success,
      width: size ?? 120,
      height: size ?? 120,
      repeat: repeat,
      onLoaded: onLoaded,
    );
  }

  /// Animation d'erreur
  factory LottieAnimation.error({
    double? size,
    bool repeat = false,
  }) {
    return LottieAnimation(
      asset: LottieAssets.error,
      width: size ?? 120,
      height: size ?? 120,
      repeat: repeat,
    );
  }

  /// Animation de chargement
  factory LottieAnimation.loading({
    double? size,
  }) {
    return LottieAnimation(
      asset: LottieAssets.loading,
      width: size ?? 80,
      height: size ?? 80,
      repeat: true,
    );
  }

  /// Animation état vide
  factory LottieAnimation.empty({
    double? size,
  }) {
    return LottieAnimation(
      asset: LottieAssets.empty,
      width: size ?? 150,
      height: size ?? 150,
      repeat: true,
    );
  }

  /// Animation de livraison
  factory LottieAnimation.delivery({
    double? width,
    double? height,
  }) {
    return LottieAnimation(
      asset: LottieAssets.delivery,
      width: width ?? 200,
      height: height ?? 100,
      repeat: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
      asset,
      width: width,
      height: height,
      fit: fit,
      repeat: repeat,
      reverse: reverse,
      controller: controller,
      onLoaded: onLoaded,
      errorBuilder: (context, error, stackTrace) {
        // Fallback si l'animation ne charge pas
        return SizedBox(
          width: width ?? 100,
          height: height ?? 100,
          child: const Icon(
            Icons.animation,
            size: 40,
            color: Colors.grey,
          ),
        );
      },
    );
  }
}

/// Widget de chargement avec animation Lottie
class AnimatedLoadingWidget extends StatelessWidget {
  final String? message;
  final double size;
  final Color? messageColor;

  const AnimatedLoadingWidget({
    super.key,
    this.message,
    this.size = 80,
    this.messageColor,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          LottieAnimation.loading(size: size),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: TextStyle(
                fontSize: 14,
                color: messageColor ?? Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

/// Widget d'état vide avec animation Lottie
class AnimatedEmptyWidget extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? message; // Alias pour subtitle (compatibilité)
  final String? actionText;
  final VoidCallback? onAction;
  final double animationSize;
  final IconData? icon; // Optionnel, ignoré (utilise Lottie)

  const AnimatedEmptyWidget({
    super.key,
    required this.title,
    this.subtitle,
    this.message,
    this.actionText,
    this.onAction,
    this.animationSize = 150,
    this.icon, // Ignoré, pour compatibilité
  });
  
  String? get _displaySubtitle => subtitle ?? message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            LottieAnimation.empty(size: animationSize),
            const SizedBox(height: 24),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            if (_displaySubtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                _displaySubtitle!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionText != null && onAction != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onAction,
                child: Text(actionText!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Widget de succès avec animation Lottie
class AnimatedSuccessWidget extends StatefulWidget {
  final String title;
  final String? subtitle;
  final String? buttonText;
  final VoidCallback? onButtonPressed;
  final double animationSize;
  final Duration? autoDismissAfter;
  final VoidCallback? onAutoDismiss;

  const AnimatedSuccessWidget({
    super.key,
    required this.title,
    this.subtitle,
    this.buttonText,
    this.onButtonPressed,
    this.animationSize = 120,
    this.autoDismissAfter,
    this.onAutoDismiss,
  });

  @override
  State<AnimatedSuccessWidget> createState() => _AnimatedSuccessWidgetState();
}

class _AnimatedSuccessWidgetState extends State<AnimatedSuccessWidget> {
  @override
  void initState() {
    super.initState();
    if (widget.autoDismissAfter != null) {
      Future.delayed(widget.autoDismissAfter!, () {
        if (mounted) {
          widget.onAutoDismiss?.call();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            LottieAnimation.success(size: widget.animationSize),
            const SizedBox(height: 24),
            Text(
              widget.title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.green.shade700,
              ),
              textAlign: TextAlign.center,
            ),
            if (widget.subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                widget.subtitle!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (widget.buttonText != null && widget.onButtonPressed != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: widget.onButtonPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(widget.buttonText!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Widget d'erreur avec animation Lottie
class AnimatedErrorWidget extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? message; // Alias pour subtitle (compatibilité)
  final String? retryText;
  final VoidCallback? onRetry;
  final double animationSize;

  const AnimatedErrorWidget({
    super.key,
    required this.title,
    this.subtitle,
    this.message,
    this.retryText,
    this.onRetry,
    this.animationSize = 120,
  });
  
  String? get _displaySubtitle => subtitle ?? message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            LottieAnimation.error(size: animationSize),
            const SizedBox(height: 24),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.red.shade700,
              ),
              textAlign: TextAlign.center,
            ),
            if (_displaySubtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                _displaySubtitle!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (retryText != null && onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(retryText!),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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

/// Dialogue de succès avec animation Lottie
class AnimatedSuccessDialog extends StatelessWidget {
  final String title;
  final String? message;
  final String buttonText;
  final VoidCallback? onDismiss;
  final VoidCallback? onPressed; // Alias pour onDismiss (compatibilité)

  const AnimatedSuccessDialog({
    super.key,
    required this.title,
    this.message,
    this.buttonText = 'OK',
    this.onDismiss,
    this.onPressed,
  });
  
  VoidCallback? get _callback => onDismiss ?? onPressed;

  static Future<void> show(
    BuildContext context, {
    required String title,
    String? message,
    String buttonText = 'OK',
    VoidCallback? onDismiss,
    VoidCallback? onPressed,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AnimatedSuccessDialog(
        title: title,
        message: message,
        buttonText: buttonText,
        onDismiss: onDismiss ?? onPressed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LottieAnimation.success(size: 100),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            if (message != null) ...[
              const SizedBox(height: 8),
              Text(
                message!,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onDismiss?.call();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(buttonText),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
