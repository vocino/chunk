import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/timer_service.dart';
import '../models/session_state.dart';
import '../widgets/breathing_circle.dart';
import '../theme/app_theme.dart';
import 'completion_screen.dart';

class TimerScreen extends StatelessWidget {
  const TimerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),

              // Breathing circle (50% of screen height)
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.5,
                child: const BreathingCircle(),
              ),

              const Spacer(),

              // Done button
              ElevatedButton(
                onPressed: () {
                  final timerService = context.read<TimerService>();
                  final sessionState = context.read<SessionState>();

                  // Stop timer and get elapsed time
                  final elapsedSeconds = timerService.stop();

                  // Increment question count
                  sessionState.incrementQuestion();

                  // Get questions until break (after incrementing)
                  final questionsUntilBreak = sessionState.questionsUntilBreak;

                  // Navigate to completion screen (replace to clean nav stack)
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CompletionScreen(
                        elapsedSeconds: elapsedSeconds,
                        questionsUntilBreak: questionsUntilBreak,
                      ),
                    ),
                  );
                },
                style: AppTheme.primaryButtonStyle,
                child: const Text(
                  'Done',
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
