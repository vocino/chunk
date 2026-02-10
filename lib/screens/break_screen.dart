import 'package:flutter/material.dart';
import '../models/break_activity.dart';

class BreakScreen extends StatelessWidget {
  final BreakActivity activity;

  const BreakScreen({
    super.key,
    required this.activity,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Break Screen'),
      ),
    );
  }
}
