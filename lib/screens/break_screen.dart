import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/break_activity.dart';
import '../models/session_state.dart';
import '../theme/app_theme.dart';
import 'start_screen.dart';

class BreakScreen extends StatefulWidget {
  final BreakActivity activity;

  const BreakScreen({
    super.key,
    required this.activity,
  });

  @override
  State<BreakScreen> createState() => _BreakScreenState();
}

class _BreakScreenState extends State<BreakScreen> {
  int _remainingSeconds = 60;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _countdownTimer?.cancel();
          _navigateToStart();
        }
      });
    });
  }

  void _navigateToStart() {
    final sessionState = context.read<SessionState>();
    sessionState.resetCycle();

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const StartScreen()),
      (route) => false,
    );
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 1),

              // "Break time!" header
              Text(
                'Break time!',
                style: AppTheme.headingMedium,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 48),

              // Countdown timer
              Text(
                '${_remainingSeconds}s',
                style: AppTheme.headingLarge.copyWith(
                  fontSize: 72,
                  color: AppTheme.cyan,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 48),

              // Activity suggestion
              Text(
                'How about:',
                style: AppTheme.bodyLarge.copyWith(
                  fontSize: 20,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                '${widget.activity.emoji} ${widget.activity.text}',
                style: AppTheme.headingMedium.copyWith(
                  fontSize: 28,
                ),
                textAlign: TextAlign.center,
              ),

              const Spacer(flex: 2),

              // Show "Back to work" button only in last 3 seconds
              if (_remainingSeconds <= 3 && _remainingSeconds > 0)
                ElevatedButton(
                  onPressed: _navigateToStart,
                  style: AppTheme.primaryButtonStyle,
                  child: const Text('Back to work'),
                ),

              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }
}
