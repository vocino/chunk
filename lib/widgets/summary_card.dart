import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'glass_container.dart';

class SummaryCard extends StatefulWidget {
  final List<int> questionTimes;
  final int totalSessionSeconds;
  final String Function(int) formatElapsed;

  const SummaryCard({
    super.key,
    required this.questionTimes,
    required this.totalSessionSeconds,
    required this.formatElapsed,
  });

  @override
  State<SummaryCard> createState() => _SummaryCardState();
}

class _SummaryCardState extends State<SummaryCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _revealController;
  late Animation<double> _headingOpacity;
  late Animation<double> _countOpacity;
  late Animation<double> _listOpacity;
  late Animation<Offset> _listSlide;
  late Animation<double> _totalOpacity;
  late Animation<Offset> _totalSlide;

  @override
  void initState() {
    super.initState();

    _revealController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _headingOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _revealController,
        curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
      ),
    );

    _countOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _revealController,
        curve: const Interval(0.2, 0.5, curve: Curves.easeOut),
      ),
    );

    _listOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _revealController,
        curve: const Interval(0.4, 0.75, curve: Curves.easeOut),
      ),
    );

    _listSlide = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _revealController,
        curve: const Interval(0.4, 0.75, curve: Curves.easeOut),
      ),
    );

    _totalOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _revealController,
        curve: const Interval(0.7, 1.0, curve: Curves.easeOut),
      ),
    );

    _totalSlide = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _revealController,
        curve: const Interval(0.7, 1.0, curve: Curves.easeOut),
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
    final n = widget.questionTimes.length;
    final totalFormatted = widget.formatElapsed(widget.totalSessionSeconds);

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
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FadeTransition(
                    opacity: _headingOpacity,
                    child: Text(
                      'Nice work!',
                      style: AppTheme.headingMedium(context)
                          .copyWith(color: AppTheme.green),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),
                  FadeTransition(
                    opacity: _countOpacity,
                    child: Text(
                      '$n ${n == 1 ? 'question' : 'questions'} done',
                      style: AppTheme.bodyLarge(context)
                          .copyWith(color: AppTheme.overlay1),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SlideTransition(
                    position: _listSlide,
                    child: FadeTransition(
                      opacity: _listOpacity,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 260),
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: const BouncingScrollPhysics(),
                          itemCount: widget.questionTimes.length,
                          itemBuilder: (context, i) {
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                children: [
                                  Text(
                                    'Q${i + 1}',
                                    style: AppTheme.bodyLarge(context)
                                        .copyWith(color: AppTheme.overlay1),
                                  ),
                                  const Spacer(),
                                  Text(
                                    widget.formatElapsed(
                                        widget.questionTimes[i]),
                                    style: AppTheme.bodyLarge(context)
                                        .copyWith(color: AppTheme.subtext1),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SlideTransition(
                    position: _totalSlide,
                    child: FadeTransition(
                      opacity: _totalOpacity,
                      child: Column(
                        children: [
                          Divider(color: AppTheme.surface1),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Text(
                                'Total time',
                                style: AppTheme.bodyLarge(context).copyWith(
                                  color: AppTheme.subtext1,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                totalFormatted,
                                style: AppTheme.bodyLarge(context).copyWith(
                                  color: AppTheme.text,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
