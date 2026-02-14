import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/session_state.dart';
import '../models/session_step.dart';
import '../services/timer_service.dart';
import '../services/activity_service.dart';
import '../services/sound_service.dart';
import '../theme/app_theme.dart';
import '../widgets/advance_arrow.dart';
import '../widgets/ambient_background.dart';
import '../widgets/breathing_circle.dart';
import '../widgets/glass_container.dart';

class SessionScreen extends StatefulWidget {
  const SessionScreen({super.key});

  @override
  State<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends State<SessionScreen> {
  final PageController _pageController = PageController();
  final List<SessionStep> _steps = [SessionStep(StepType.start)];
  int _currentStepIndex = 0;
  bool _isTransitioning = false;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_isTransitioning) return;
    final page = _pageController.page;
    if (page == null) return;

    // User is swiping forward past the current step
    if (page > _currentStepIndex + 0.15) {
      _isTransitioning = true;
      _createNextStep(_currentStepIndex);
    }
  }

  void _advance() {
    if (_isTransitioning) return;
    final currentPage = _pageController.page?.round();
    if (currentPage != _currentStepIndex) return;

    _isTransitioning = true;
    _createNextStep(_currentStepIndex);
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  void _createNextStep(int fromIndex) {
    final fromStep = _steps[fromIndex];
    final timerService = context.read<TimerService>();
    final sessionState = context.read<SessionState>();
    final activityService = context.read<ActivityService>();

    setState(() {
      switch (fromStep.type) {
        case StepType.start:
          timerService.start();
          _steps.add(SessionStep(StepType.timer));
          break;

        case StepType.timer:
          final elapsed = timerService.stop();
          sessionState.incrementQuestion();
          _steps.add(SessionStep(
            StepType.completion,
            elapsedSeconds: elapsed,
            questionsUntilBreak: sessionState.questionsUntilBreak,
          ));
          break;

        case StepType.completion:
          if (sessionState.shouldTriggerBreak()) {
            final activity = activityService.getRandomActivity(
              sessionState.recentActivityIds,
            );
            sessionState.addRecentActivity(activity.id);
            _steps.add(SessionStep(StepType.break_, activity: activity));
          } else {
            timerService.start();
            _steps.add(SessionStep(StepType.timer));
          }
          break;

        case StepType.break_:
          sessionState.resetCycle();
          _steps.add(SessionStep(StepType.start));
          break;
      }

      _currentStepIndex = _steps.length - 1;
    });
  }

  void _onPageChanged(int index) {
    _isTransitioning = false;
  }

  @override
  void dispose() {
    _pageController.removeListener(_onScroll);
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          const RepaintBoundary(
            child: AmbientBackground(),
          ),
          RepaintBoundary(
            child: PageView.builder(
              controller: _pageController,
              scrollDirection: Axis.vertical,
              physics: const PageScrollPhysics(),
              itemCount: _currentStepIndex + 2,
              onPageChanged: _onPageChanged,
              itemBuilder: (context, index) {
                if (index >= _steps.length) {
                  return const SizedBox.shrink();
                }
                final child = _buildCard(_steps[index], index);
                return AnimatedBuilder(
                  animation: _pageController,
                  builder: (context, child) {
                    double pageOffset = 0;
                    if (_pageController.hasClients) {
                      pageOffset =
                          (_pageController.page ?? index.toDouble()) - index;
                    }

                    // Outgoing card: fade out and shift up slightly for parallax
                    if (pageOffset > 0) {
                      final opacity = (1 - pageOffset * 0.6).clamp(0.0, 1.0);
                      final translateY = pageOffset * -40;
                      return Opacity(
                        opacity: opacity,
                        child: Transform.translate(
                          offset: Offset(0, translateY),
                          child: child,
                        ),
                      );
                    }

                    return child!;
                  },
                  child: child,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(SessionStep step, int index) {
    switch (step.type) {
      case StepType.start:
        return _buildStartCard(index);
      case StepType.timer:
        return _buildTimerCard(index);
      case StepType.completion:
        return _buildCompletionCard(step, index);
      case StepType.break_:
        return _buildBreakCard(step);
    }
  }

  Widget _buildStartCard(int index) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(Icons.settings, size: 32),
                onPressed: () {
                  // TODO: Navigate to settings
                },
              ),
            ),
            const Spacer(),
            Text(
              'Ready?',
              textAlign: TextAlign.center,
              style: AppTheme.headingLarge.copyWith(color: AppTheme.purple),
            ),
            const Spacer(),
            AdvanceArrow(label: 'start', onTap: _advance),
          ],
        ),
      ),
    );
  }

  Widget _buildTimerCard(int index) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Expanded(
              child: BreathingCircle(),
            ),
            AdvanceArrow(label: 'finished', onTap: _advance),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletionCard(SessionStep step, int index) {
    final timerService = context.read<TimerService>();
    final sessionState = context.read<SessionState>();
    final formattedTime = timerService.formatElapsed(step.elapsedSeconds ?? 0);
    final shouldBreak = sessionState.shouldTriggerBreak();

    return _CompletionCard(
      formattedTime: formattedTime,
      shouldBreak: shouldBreak,
      questionsUntilBreak: step.questionsUntilBreak ?? 0,
      onAdvance: _advance,
    );
  }

  Widget _buildBreakCard(SessionStep step) {
    return _BreakCard(
      activity: step.activity!,
      onComplete: _advance,
    );
  }
}

class _CompletionCard extends StatefulWidget {
  final String formattedTime;
  final bool shouldBreak;
  final int questionsUntilBreak;
  final VoidCallback onAdvance;

  const _CompletionCard({
    required this.formattedTime,
    required this.shouldBreak,
    required this.questionsUntilBreak,
    required this.onAdvance,
  });

  @override
  State<_CompletionCard> createState() => _CompletionCardState();
}

class _CompletionCardState extends State<_CompletionCard>
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
              fillOpacity: 0.10,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FadeTransition(
                    opacity: _labelOpacity,
                    child: Text(
                      'That took',
                      style:
                          AppTheme.bodyLarge.copyWith(color: AppTheme.comment),
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
                      style: AppTheme.headingLarge.copyWith(
                        fontSize: 72,
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
                          style: AppTheme.bodyLarge
                              .copyWith(color: AppTheme.comment),
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
          ],
        ),
      ),
    );
  }
}

class _BreakCard extends StatefulWidget {
  final dynamic activity;
  final VoidCallback onComplete;

  const _BreakCard({
    required this.activity,
    required this.onComplete,
  });

  @override
  State<_BreakCard> createState() => _BreakCardState();
}

class _BreakCardState extends State<_BreakCard> {
  int _remainingSeconds = 60;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _countdownTimer?.cancel();
          context.read<SoundService>().playDing();
          widget.onComplete();
        }
      });
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            const Spacer(),
            GlassContainer(
              glowColor: AppTheme.pink,
              fillOpacity: 0.12,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Break time!',
                    style:
                        AppTheme.headingMedium.copyWith(color: AppTheme.pink),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),
                  Text(
                    '$_remainingSeconds',
                    style: AppTheme.headingLarge.copyWith(
                      fontSize: 72,
                      color: AppTheme.cyan,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),
                  Text(
                    'How about:',
                    style: AppTheme.bodyLarge.copyWith(
                      fontSize: 20,
                      color: AppTheme.comment,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${widget.activity.emoji} ${widget.activity.text}',
                    style: AppTheme.headingMedium.copyWith(fontSize: 28),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const Spacer(),
            AdvanceArrow(
              label: 'back to work',
              onTap: widget.onComplete,
            ),
          ],
        ),
      ),
    );
  }
}
