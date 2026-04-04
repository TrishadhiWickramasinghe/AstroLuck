import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final Gradient? gradient;
  final Color? backgroundColor;
  final EdgeInsets padding;
  final BorderRadius? borderRadius;
  final List<BoxShadow>? boxShadow;
  final Border? border;
  final double? elevation;
  final VoidCallback? onTap;

  const CustomCard({
    super.key,
    required this.child,
    this.gradient,
    this.backgroundColor,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius,
    this.boxShadow,
    this.border,
    this.elevation,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveRadius = borderRadius ?? const BorderRadius.all(Radius.circular(16));
    final effectiveShadow = boxShadow ?? AppColors.cardShadow;
    
    final container = Container(
      padding: padding,
      decoration: BoxDecoration(
        gradient: gradient ?? const LinearGradient(
          colors: [AppColors.cardBackground, AppColors.darkPurple],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        color: gradient == null ? backgroundColor ?? AppColors.cardBackground : null,
        borderRadius: effectiveRadius,
        boxShadow: effectiveShadow,
        border: border,
      ),
      child: child,
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: container,
      );
    }

    return container;
  }
}
