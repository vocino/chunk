import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AdvanceArrow extends StatefulWidget {
  final String label;
  final VoidCallback onTap;

  const AdvanceArrow({
    super.key,
    required this.label,
    required this.onTap,
  });

  @override
  State<AdvanceArrow> createState() => _AdvanceArrowState();
}

class _AdvanceArrowState extends State<AdvanceArrow>
    with SingleTickerProviderStateMixin {
  late AnimationController _bounceController;
  late Animation<Offset> _bounceAnimation;

  @override
  void initState() {
    super.initState();

    _bounceController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _bounceAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, 0.15),
    )
        .chain(CurveTween(curve: Curves.easeInOut))
        .animate(_bounceController);

    _bounceController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: SlideTransition(
          position: _bounceAnimation,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.comment,
                ),
              ),
              const SizedBox(height: 4),
              const Icon(
                Icons.keyboard_arrow_down,
                size: 32,
                color: AppTheme.foreground,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
