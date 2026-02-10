import 'package:flutter/material.dart';

class BreathingCircle extends StatefulWidget {
  const BreathingCircle({super.key});

  @override
  State<BreathingCircle> createState() => _BreathingCircleState();
}

class _BreathingCircleState extends State<BreathingCircle> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Text('Breathing Circle'),
      ),
    );
  }
}
