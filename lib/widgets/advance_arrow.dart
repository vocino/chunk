import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

class AdvanceArrow extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  final bool enlarged;

  const AdvanceArrow({
    super.key,
    required this.label,
    required this.onTap,
    this.enlarged = false,
  });

  @override
  State<AdvanceArrow> createState() => _AdvanceArrowState();
}

class _AdvanceArrowState extends State<AdvanceArrow>
    with TickerProviderStateMixin {
  late AnimationController _bounceController;
  late Animation<Offset> _bounceAnimation;
  late AnimationController _tapController;
  late Animation<double> _tapScale;

  @override
  void initState() {
    super.initState();

    _bounceController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _bounceAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset(0, widget.enlarged ? 0.2 : 0.15),
    )
        .chain(CurveTween(curve: Curves.easeInOut))
        .animate(_bounceController);

    _bounceController.repeat(reverse: true);

    _tapController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _tapScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.85)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.85, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
    ]).animate(_tapController);
  }

  void _handleTap() {
    HapticFeedback.lightImpact();
    _tapController.forward(from: 0).then((_) {
      widget.onTap();
    });
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _tapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: ScaleTransition(
          scale: _tapScale,
          child: SlideTransition(
            position: _bounceAnimation,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.label,
                  style: TextStyle(
                    fontSize: (widget.enlarged ? 18 : 14) * AppTheme.scaleFactor(context),
                    fontWeight: FontWeight.w400,
                    color: AppTheme.comment,
                    shadows: [
                      Shadow(
                        color: AppTheme.purple.withValues(alpha: 0.3),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Icon(
                  Icons.keyboard_arrow_down,
                  size: (widget.enlarged ? 48 : 32) * AppTheme.scaleFactor(context),
                  color: AppTheme.foreground,
                  shadows: [
                    Shadow(
                      color: AppTheme.purple.withValues(alpha: 0.2),
                      blurRadius: 12,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
