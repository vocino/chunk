import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'advance_arrow.dart';
import 'glass_container.dart';

class CompletionCard extends StatefulWidget {
  final String formattedTime;
  final bool shouldBreak;
  final int questionsUntilBreak;
  final VoidCallback onAdvance;
  final VoidCallback onDone;

  const CompletionCard({
    super.key,
    required this.formattedTime,
    required this.shouldBreak,
    required this.questionsUntilBreak,
    required this.onAdvance,
    required this.onDone,
  });

  @override
  State<CompletionCard> createState() => _CompletionCardState();
}

class _CompletionCardState extends State<CompletionCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _revealController;
  late Animation<double> _labelOpacity;
  late Animation<double> _timeOpacity;
  late Animation<double> _timeScale;
  late Animation<double> _counterOpacity;
  late Animation<Offset> _counterSlide;

  @override
  void initState() {
    super.initState();

    _revealController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // "That took" label fades in first (0–300ms)
    _labelOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _revealController,
        curve: const Interval(0, 0.375, curve: Curves.easeOut),
      ),
    );

    // Time fades in and scales up (150–600ms)
    _timeOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _revealController,
        curve: const Interval(0.1875, 0.75, curve: Curves.easeOut),
      ),
    );

    _timeScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _revealController,
        curve: const Interval(0.1875, 0.75, curve: Curves.easeOutBack),
      ),
    );

    // Progress counter slides up and fades in (400–800ms)
    _counterOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _revealController,
        curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
      ),
    );

    _counterSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _revealController,
        curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
      ),
    );

    _revealController.forward();
  }

  @override
  void dispose() {
    _revealController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Spacer(),
            GlassContainer(
              glowColor: AppTheme.green,
              borderGradient: AppTheme.borderGradient(
                from: AppTheme.green,
                to: AppTheme.teal,
              ),
              fillOpacity: 0.10,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FadeTransition(
                    opacity: _labelOpacity,
                    child: Text(
                      'That took',
                      style:
                          AppTheme.bodyLarge(context).copyWith(color: AppTheme.overlay1),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 8),
                  AnimatedBuilder(
                    animation: _revealController,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _timeOpacity.value,
                        child: Transform.scale(
                          scale: _timeScale.value,
                          child: child,
                        ),
                      );
                    },
                    child: Text(
                      widget.formattedTime,
                      style: AppTheme.headingLarge(context).copyWith(
                        fontSize: 72 * AppTheme.scaleFactor(context),
                        color: AppTheme.green,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 32),
                  if (!widget.shouldBreak)
                    SlideTransition(
                      position: _counterSlide,
                      child: FadeTransition(
                        opacity: _counterOpacity,
                        child: Text(
                          '${widget.questionsUntilBreak} more until break',
                          style: AppTheme.bodyLarge(context)
                              .copyWith(color: AppTheme.overlay1),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const Spacer(),
            AdvanceArrow(
              label: widget.shouldBreak ? 'break time' : 'ready',
              onTap: widget.onAdvance,
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: widget.onDone,
              child: Text(
                'all done',
                style: AppTheme.bodyLarge(context).copyWith(
                  color: AppTheme.overlay1,
                  fontSize: 16 * AppTheme.scaleFactor(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
