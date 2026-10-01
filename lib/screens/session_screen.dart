import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/session_state.dart';
import '../models/session_step.dart';
import '../services/timer_service.dart';
import '../services/activity_service.dart';
import '../services/sound_service.dart';
import '../theme/app_theme.dart';
import '../widgets/advance_arrow.dart';
import '../widgets/ambient_background.dart';
import '../widgets/break_card.dart';
import '../widgets/break_timer_selector.dart';
import '../widgets/breathing_circle.dart';
import '../widgets/completion_card.dart';
import '../widgets/summary_card.dart';

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
          sessionState.recordQuestion(elapsed);
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

        case StepType.summary:
          break;
      }

      _currentStepIndex = _steps.length - 1;
    });
  }

  void _endSession() {
    if (_isTransitioning) return;
    _isTransitioning = true;
    setState(() {
      _steps.add(SessionStep(StepType.summary));
      _currentStepIndex = _steps.length - 1;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }

  void _onPageChanged(int index) {
    _isTransitioning = false;
    if (index < _steps.length) {
      HapticFeedback.mediumImpact();
      final step = _steps[index];
      final soundService = context.read<SoundService>();
      if (step.type == StepType.completion) {
        soundService.playPop();
      } else if (step.type == StepType.break_) {
        soundService.playChime();
      }
    }
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
      backgroundColor: AppTheme.base,
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
      case StepType.summary:
        return _buildSummaryCard();
    }
  }

  Widget _buildStartCard(int index) {
    final sessionState = context.watch<SessionState>();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Spacer(),
            Text(
              'Ready?',
              textAlign: TextAlign.center,
              style: AppTheme.headingLarge(context).copyWith(color: AppTheme.mauve),
            ),
            const SizedBox(height: 8),
            Text(
              'One question at a time',
              style: TextStyle(
                fontSize: 16 * AppTheme.scaleFactor(context),
                fontWeight: FontWeight.w400,
                color: AppTheme.subtext0,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'break time',
              style: TextStyle(
                fontSize: 14 * AppTheme.scaleFactor(context),
                fontWeight: FontWeight.w400,
                color: AppTheme.overlay1,
              ),
            ),
            const SizedBox(height: 12),
            BreakTimerSelector(
              selectedDuration: sessionState.breakDuration,
              onChanged: (d) => sessionState.setBreakDuration(d),
            ),
            const Spacer(),
            AdvanceArrow(
              label: 'swipe to start',
              onTap: _advance,
              enlarged: true,
            ),
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

    return CompletionCard(
      formattedTime: formattedTime,
      shouldBreak: shouldBreak,
      questionsUntilBreak: step.questionsUntilBreak ?? 0,
      onAdvance: _advance,
      onDone: _endSession,
    );
  }

  Widget _buildBreakCard(SessionStep step) {
    return BreakCard(
      activity: step.activity!,
      onComplete: _advance,
      onDone: _endSession,
    );
  }

  Widget _buildSummaryCard() {
    final sessionState = context.read<SessionState>();
    final timerService = context.read<TimerService>();
    return SummaryCard(
      questionTimes: sessionState.questionTimes,
      totalSessionSeconds: sessionState.totalSessionSeconds,
      formatElapsed: timerService.formatElapsed,
    );
  }
}
