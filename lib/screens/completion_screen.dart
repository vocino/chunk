import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/timer_service.dart';
import '../services/activity_service.dart';
import '../models/session_state.dart';
import '../theme/app_theme.dart';
import 'timer_screen.dart';
import 'break_screen.dart';

class CompletionScreen extends StatelessWidget {
  final int elapsedSeconds;
  final int questionsUntilBreak;

  const CompletionScreen({
    super.key,
    required this.elapsedSeconds,
    required this.questionsUntilBreak,
  });

  @override
  Widget build(BuildContext context) {
    final timerService = context.read<TimerService>();
    final sessionState = context.read<SessionState>();
    final activityService = context.read<ActivityService>();

    // Determine if break should trigger
    final shouldBreak = sessionState.shouldTriggerBreak();

    // Format elapsed time
    final formattedTime = timerService.formatElapsed(elapsedSeconds);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),

              // Time taken display
              Center(
                child: Column(
                  children: [
                    const Text(
                      'That took',
                      style: AppTheme.bodyLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      formattedTime,
                      style: AppTheme.headingLarge,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Progress counter (only show if NOT triggering break)
              if (!shouldBreak)
                Center(
                  child: Text(
                    '$questionsUntilBreak/5 until break',
                    style: AppTheme.bodyLarge,
                  ),
                ),

              const Spacer(),

              // Next button (text changes based on break status)
              ElevatedButton(
                onPressed: () {
                  if (shouldBreak) {
                    // Get random activity
                    final activity = activityService.getRandomActivity(
                      sessionState.recentActivityIds,
                    );

                    // Add to recent history
                    sessionState.addRecentActivity(activity.id);

                    // Navigate to break screen
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BreakScreen(activity: activity),
                      ),
                    );
                  } else {
                    // Start timer for next question
                    timerService.start();

                    // Navigate back to timer screen
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TimerScreen(),
                      ),
                    );
                  }
                },
                style: AppTheme.primaryButtonStyle,
                child: Text(
                  shouldBreak ? 'Break time!' : 'Next question',
                  style: AppTheme.buttonText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
