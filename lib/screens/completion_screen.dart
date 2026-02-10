import 'package:flutter/material.dart';

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
    return Scaffold(
      body: Center(
        child: Text('Completion Screen'),
      ),
    );
  }
}
