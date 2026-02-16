import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;
  final Color? glowColor;
  final double glowOpacity;
  final double glowSpread;
  final double fillOpacity;
  final EdgeInsets padding;
  final double borderRadius;
  final Gradient? borderGradient;
  final Gradient? fillGradient;

  const GlassContainer({
    super.key,
    required this.child,
    this.glowColor,
    this.glowOpacity = 0.25,
    this.glowSpread = 1.0,
    this.fillOpacity = 0.12,
    this.padding = const EdgeInsets.all(24),
    this.borderRadius = 16.0,
    this.borderGradient,
    this.fillGradient,
  });

  @override
  Widget build(BuildContext context) {
    final boxShadow = glowColor != null
        ? [
            BoxShadow(
              color: glowColor!.withValues(alpha: 0.08),
              blurRadius: glowSpread * 16,
              spreadRadius: glowSpread * 2,
            ),
          ]
        : null;

    // Gradient border: outer container holds gradient, inner holds fill
    if (borderGradient != null) {
      return Container(
        decoration: BoxDecoration(
          gradient: borderGradient,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: boxShadow,
        ),
        child: Container(
          margin: const EdgeInsets.all(1.0),
          padding: padding,
          decoration: BoxDecoration(
            gradient: fillGradient,
            color: fillGradient == null
                ? AppTheme.base
                : null,
            borderRadius: BorderRadius.circular(borderRadius - 1),
          ),
          child: child,
        ),
      );
    }

    // Solid border fallback
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        gradient: fillGradient,
        color: fillGradient == null
            ? AppTheme.surface0.withValues(alpha: fillOpacity)
            : null,
        borderRadius: BorderRadius.circular(borderRadius),
        border: glowColor != null
            ? Border.all(
                color: glowColor!.withValues(alpha: glowOpacity),
                width: 1.0,
              )
            : null,
        boxShadow: boxShadow,
      ),
      child: child,
    );
  }
}
