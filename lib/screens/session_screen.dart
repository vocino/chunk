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
import '../widgets/breathing_circle.dart';

class SessionScreen extends StatefulWidget {
  const SessionScreen({super.key});

  @override
  State<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends State<SessionScreen> {
  final PageController _pageController = PageController();
  final List<SessionStep> _steps = [SessionStep(StepType.start)];
  int _currentStepIndex = 0;

  void _advance() {
    if (_pageController.page?.round() != _currentStepIndex) return;
    _handleForwardTransition(_currentStepIndex);
  }

  void _handleForwardTransition(int fromIndex) {
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

    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  void _onPageChanged(int index) {
    // Only handle forward transitions beyond what we've seen
    if (index > _currentStepIndex) {
      // This shouldn't happen since itemCount limits it,
      // but guard against it
      _pageController.animateToPage(
        _currentStepIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        physics: const PageScrollPhysics(),
        itemCount: _currentStepIndex + 1,
        onPageChanged: _onPageChanged,
        itemBuilder: (context, index) => _buildCard(_steps[index], index),
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

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Spacer(),
            Text(
              'That took',
              style: AppTheme.bodyLarge.copyWith(color: AppTheme.comment),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              formattedTime,
              style: AppTheme.headingLarge.copyWith(
                fontSize: 72,
                color: AppTheme.green,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            if (!shouldBreak)
              Text(
                '${step.questionsUntilBreak} more until break',
                style: AppTheme.bodyLarge.copyWith(color: AppTheme.comment),
                textAlign: TextAlign.center,
              ),
            const Spacer(),
            AdvanceArrow(
              label: shouldBreak ? 'break time' : 'ready',
              onTap: _advance,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBreakCard(SessionStep step) {
    return _BreakCard(
      activity: step.activity!,
      onComplete: _advance,
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
            Text(
              'Break time!',
              style: AppTheme.headingMedium.copyWith(color: AppTheme.pink),
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
