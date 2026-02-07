import 'package:flutter/material.dart';

/// Transitions de pages personnalisées pour l'app
class AppPageTransitions {
  AppPageTransitions._();

  /// Transition slide de droite à gauche (par défaut iOS)
  static PageRouteBuilder<T> slideRight<T>({
    required Widget page,
    RouteSettings? settings,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOutCubic;

        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  /// Transition slide de bas en haut (modal style)
  static PageRouteBuilder<T> slideUp<T>({
    required Widget page,
    RouteSettings? settings,
    Duration duration = const Duration(milliseconds: 350),
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.easeOutCubic;

        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  /// Transition fade
  static PageRouteBuilder<T> fade<T>({
    required Widget page,
    RouteSettings? settings,
    Duration duration = const Duration(milliseconds: 250),
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    );
  }

  /// Transition scale (zoom in)
  static PageRouteBuilder<T> scale<T>({
    required Widget page,
    RouteSettings? settings,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const curve = Curves.easeOutBack;

        var scaleAnimation = Tween(begin: 0.8, end: 1.0).chain(
          CurveTween(curve: curve),
        );

        var fadeAnimation = Tween(begin: 0.0, end: 1.0).chain(
          CurveTween(curve: Curves.easeOut),
        );

        return ScaleTransition(
          scale: animation.drive(scaleAnimation),
          child: FadeTransition(
            opacity: animation.drive(fadeAnimation),
            child: child,
          ),
        );
      },
    );
  }

  /// Transition shared axis (Material Design)
  static PageRouteBuilder<T> sharedAxis<T>({
    required Widget page,
    RouteSettings? settings,
    SharedAxisDirection direction = SharedAxisDirection.horizontal,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final Offset begin;
        switch (direction) {
          case SharedAxisDirection.horizontal:
            begin = const Offset(0.3, 0.0);
            break;
          case SharedAxisDirection.vertical:
            begin = const Offset(0.0, 0.3);
            break;
        }

        var slideAnimation = Tween(begin: begin, end: Offset.zero).chain(
          CurveTween(curve: Curves.easeOutCubic),
        );

        var fadeAnimation = Tween(begin: 0.0, end: 1.0).chain(
          CurveTween(curve: Curves.easeOut),
        );

        return SlideTransition(
          position: animation.drive(slideAnimation),
          child: FadeTransition(
            opacity: animation.drive(fadeAnimation),
            child: child,
          ),
        );
      },
    );
  }
}

enum SharedAxisDirection { horizontal, vertical }

/// Extension pour les animations de widgets
extension AnimatedWidgetExtensions on Widget {
  /// Anime l'apparition avec un fade in
  Widget fadeIn({
    Duration duration = const Duration(milliseconds: 300),
    Duration delay = Duration.zero,
    Curve curve = Curves.easeOut,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: duration + delay,
      curve: curve,
      builder: (context, value, child) {
        final progress = delay.inMilliseconds > 0
            ? ((value * (duration + delay).inMilliseconds) - delay.inMilliseconds) /
                duration.inMilliseconds
            : value;
        return Opacity(
          opacity: progress.clamp(0.0, 1.0),
          child: child,
        );
      },
      child: this,
    );
  }

  /// Anime avec un slide depuis une direction
  Widget slideIn({
    Duration duration = const Duration(milliseconds: 300),
    Duration delay = Duration.zero,
    Offset begin = const Offset(0.0, 0.3),
    Curve curve = Curves.easeOutCubic,
  }) {
    return TweenAnimationBuilder<Offset>(
      tween: Tween(begin: begin, end: Offset.zero),
      duration: duration + delay,
      curve: curve,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(value.dx * 100, value.dy * 100),
          child: child,
        );
      },
      child: this,
    );
  }

  /// Anime avec un scale
  Widget scaleIn({
    Duration duration = const Duration(milliseconds: 300),
    Duration delay = Duration.zero,
    double begin = 0.8,
    Curve curve = Curves.easeOutBack,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: begin, end: 1.0),
      duration: duration + delay,
      curve: curve,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      child: this,
    );
  }
}

/// Widget pour animer une liste d'éléments de manière échelonnée
class StaggeredAnimationList extends StatelessWidget {
  final List<Widget> children;
  final Duration itemDuration;
  final Duration staggerDelay;
  final Axis direction;

  const StaggeredAnimationList({
    super.key,
    required this.children,
    this.itemDuration = const Duration(milliseconds: 300),
    this.staggerDelay = const Duration(milliseconds: 50),
    this.direction = Axis.vertical,
  });

  @override
  Widget build(BuildContext context) {
    return direction == Axis.vertical
        ? Column(
            children: _buildAnimatedChildren(),
          )
        : Row(
            children: _buildAnimatedChildren(),
          );
  }

  List<Widget> _buildAnimatedChildren() {
    return children.asMap().entries.map((entry) {
      final index = entry.key;
      final child = entry.value;
      final delay = Duration(milliseconds: staggerDelay.inMilliseconds * index);

      return TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: itemDuration + delay,
        curve: Curves.easeOutCubic,
        builder: (context, value, _) {
          final progress = delay.inMilliseconds > 0
              ? ((value * (itemDuration + delay).inMilliseconds) - delay.inMilliseconds) /
                  itemDuration.inMilliseconds
              : value;
          final clampedProgress = progress.clamp(0.0, 1.0);
          
          return Opacity(
            opacity: clampedProgress,
            child: Transform.translate(
              offset: Offset(0, 20 * (1 - clampedProgress)),
              child: child,
            ),
          );
        },
      );
    }).toList();
  }
}

/// Bouton avec animation de pression
class AnimatedPressButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final double scaleDown;

  const AnimatedPressButton({
    super.key,
    required this.child,
    this.onPressed,
    this.scaleDown = 0.95,
  });

  @override
  State<AnimatedPressButton> createState() => _AnimatedPressButtonState();
}

class _AnimatedPressButtonState extends State<AnimatedPressButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.scaleDown,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onPressed?.call();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: widget.child,
      ),
    );
  }
}

/// Shimmer loading effect
class ShimmerLoading extends StatefulWidget {
  final Widget child;
  final bool isLoading;
  final Color? baseColor;
  final Color? highlightColor;

  const ShimmerLoading({
    super.key,
    required this.child,
    this.isLoading = true,
    this.baseColor,
    this.highlightColor,
  });

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isLoading) return widget.child;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = widget.baseColor ?? 
        (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0));
    final highlightColor = widget.highlightColor ?? 
        (isDark ? const Color(0xFF475569) : const Color(0xFFF1F5F9));

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [baseColor, highlightColor, baseColor],
              stops: [
                _controller.value - 0.3,
                _controller.value,
                _controller.value + 0.3,
              ].map((s) => s.clamp(0.0, 1.0)).toList(),
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcATop,
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

/// Pulse animation pour attirer l'attention
class PulseAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double minScale;
  final double maxScale;

  const PulseAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1000),
    this.minScale = 1.0,
    this.maxScale = 1.1,
  });

  @override
  State<PulseAnimation> createState() => _PulseAnimationState();
}

class _PulseAnimationState extends State<PulseAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _animation = Tween<double>(
      begin: widget.minScale,
      end: widget.maxScale,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: _animation.value,
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
