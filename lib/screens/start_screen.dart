import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/timer_service.dart';
import '../theme/app_theme.dart';
import 'timer_screen.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

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
              // Settings icon (top-right corner placeholder)
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: const Icon(Icons.settings, size: 32),
                  onPressed: () {
                    // TODO: Navigate to settings screen
                  },
                ),
              ),

              const Spacer(),

              // "Ready?" heading
              const Text(
                'Ready?',
                textAlign: TextAlign.center,
                style: AppTheme.headingLarge,
              ),

              const SizedBox(height: 60),

              // Start button
              ElevatedButton(
                onPressed: () {
                  // Start the timer and navigate to timer screen
                  final timerService = Provider.of<TimerService>(context, listen: false);
                  timerService.start();

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TimerScreen(),
                    ),
                  );
                },
                style: AppTheme.primaryButtonStyle,
                child: const Text(
                  'Start',
                  style: AppTheme.buttonText,
                ),
              ),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
