import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/theme_provider.dart';
import '../../core/constants/app_constants.dart';

/// Base Neumorphic Card with pop-out effect
class NeuCard extends ConsumerWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsets? padding;
  final double shadowDistance;
  final double shadowBlur;
  final VoidCallback? onTap;

  const NeuCard({
    super.key,
    required this.child,
    this.borderRadius = AppConstants.borderRadiusCard,
    this.padding,
    this.shadowDistance = AppConstants.shadowDistanceLarge,
    this.shadowBlur = AppConstants.shadowBlurLarge,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding ?? const EdgeInsets.all(AppConstants.paddingLarge),
        decoration: BoxDecoration(
          color: theme.background,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: theme.getPopOutShadows(
            distance: shadowDistance,
            blur: shadowBlur,
          ),
        ),
        child: child,
      ),
    );
  }
}

/// Neumorphic Card with pressed-in effect (for containers)
class NeuPressedCard extends ConsumerWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsets? padding;
  final double shadowDistance;
  final double shadowBlur;

  const NeuPressedCard({
    super.key,
    required this.child,
    this.borderRadius = AppConstants.borderRadiusCard,
    this.padding,
    this.shadowDistance = AppConstants.shadowDistanceSmall,
    this.shadowBlur = AppConstants.shadowBlurSmall,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);

    return Container(
      padding: padding ?? const EdgeInsets.all(AppConstants.paddingLarge),
      decoration: BoxDecoration(
        color: theme.background,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: theme.getPressedInShadows(
          distance: shadowDistance,
          blur: shadowBlur,
        ),
      ),
      child: child,
    );
  }
}
