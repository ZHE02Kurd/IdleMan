import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/theme_provider.dart';
import '../../core/constants/app_constants.dart';

/// Neumorphic Button with jelly animation
class NeuButton extends ConsumerStatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double borderRadius;
  final EdgeInsets? padding;
  final double shadowDistance;
  final double shadowBlur;
  final bool enabled;

  const NeuButton({
    super.key,
    required this.child,
    this.onTap,
    this.borderRadius = AppConstants.borderRadiusButton,
    this.padding,
    this.shadowDistance = AppConstants.shadowDistanceMedium,
    this.shadowBlur = AppConstants.shadowBlurMedium,
    this.enabled = true,
  });

  @override
  ConsumerState<NeuButton> createState() => _NeuButtonState();
}

class _NeuButtonState extends ConsumerState<NeuButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: AppConstants.animationFast),
      vsync: this,
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: AppConstants.jellyScaleDown)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
                begin: AppConstants.jellyScaleDown,
                end: AppConstants.jellyScaleUp)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 60,
      ),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (!widget.enabled) return;
    setState(() => _isPressed = true);
    HapticFeedback.lightImpact();
  }

  void _handleTapUp(TapUpDetails details) {
    if (!widget.enabled) return;
    setState(() => _isPressed = false);
    _controller.forward(from: 0.0);
    widget.onTap?.call();
  }

  void _handleTapCancel() {
    if (!widget.enabled) return;
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _isPressed
                ? AppConstants.jellyScaleDown
                : _scaleAnimation.value,
            child: child,
          );
        },
        child: Container(
          padding: widget.padding ??
              const EdgeInsets.symmetric(
                horizontal: AppConstants.paddingLarge,
                vertical: AppConstants.paddingMedium,
              ),
          decoration: BoxDecoration(
            color: theme.background,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            boxShadow: _isPressed
                ? theme.getPressedInShadows()
                : theme.getPopOutShadows(
                    distance: widget.shadowDistance,
                    blur: widget.shadowBlur,
                  ),
          ),
          child: Opacity(
            opacity: widget.enabled ? 1.0 : 0.5,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

/// Icon Button variant
class NeuIconButton extends ConsumerWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final double size;
  final double iconSize;

  const NeuIconButton({
    super.key,
    required this.icon,
    this.onTap,
    this.size = 56.0,
    this.iconSize = 24.0,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);

    return NeuButton(
      onTap: onTap,
      padding: EdgeInsets.zero,
      child: SizedBox(
        width: size,
        height: size,
        child: Icon(
          icon,
          size: iconSize,
          color: theme.mainText,
        ),
      ),
    );
  }
}
