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

  const GlassContainer({
    super.key,
    required this.child,
    this.glowColor,
    this.glowOpacity = 0.25,
    this.glowSpread = 1.0,
    this.fillOpacity = 0.12,
    this.padding = const EdgeInsets.all(24),
    this.borderRadius = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AppTheme.selection.withValues(alpha: fillOpacity),
        borderRadius: BorderRadius.circular(borderRadius),
        border: glowColor != null
            ? Border.all(
                color: glowColor!.withValues(alpha: glowOpacity),
                width: 1.0,
              )
            : null,
        boxShadow: glowColor != null
            ? [
                BoxShadow(
                  color: glowColor!.withValues(alpha: 0.08),
                  blurRadius: glowSpread * 16,
                  spreadRadius: glowSpread * 2,
                ),
              ]
            : null,
      ),
      child: child,
    );
  }
}
