import 'package:flutter/material.dart';

class BreathingCircle extends StatefulWidget {
  const BreathingCircle({super.key});

  @override
  State<BreathingCircle> createState() => _BreathingCircleState();
}

class _BreathingCircleState extends State<BreathingCircle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // Total duration: 4 + 7 + 8 = 19 seconds
    _controller = AnimationController(
      duration: const Duration(seconds: 19),
      vsync: this,
    );

    // TweenSequence with weight-based timing
    // Weights: 4 (expand), 7 (hold), 8 (contract)
    _animation = TweenSequence<double>([
      // Phase 1: Expand (4 seconds, 0.0 → 1.0)
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 4,
      ),
      // Phase 2: Hold (7 seconds, stays at 1.0)
      TweenSequenceItem(
        tween: ConstantTween<double>(1.0),
        weight: 7,
      ),
      // Phase 3: Contract (8 seconds, 1.0 → 0.0)
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 8,
      ),
    ]).animate(_controller);

    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return CustomPaint(
          painter: BreathingCirclePainter(progress: _animation.value),
          child: Container(),
        );
      },
    );
  }
}

class BreathingCirclePainter extends CustomPainter {
  final double progress;

  BreathingCirclePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width < size.height ? size.width / 2 : size.height / 2;

    // Circle size ranges from 20% to 35% of container
    final minScale = 0.20;
    final maxScale = 0.35;
    final currentScale = minScale + (progress * (maxScale - minScale));
    final radius = maxRadius * currentScale;

    // Color shift based on progress
    // Blue at start (contracted), purple at peak (expanded)
    final startColor = const Color(0xFF4A90E2); // Soft blue
    final endColor = const Color(0xFF9B59B6);   // Purple
    final currentColor = Color.lerp(startColor, endColor, progress)!;

    // Radial gradient
    final gradient = RadialGradient(
      colors: [
        currentColor.withValues(alpha: 0.8),
        currentColor.withValues(alpha: 0.4),
        currentColor.withValues(alpha: 0.1),
      ],
      stops: const [0.0, 0.7, 1.0],
    );

    final paint = Paint()
      ..shader = gradient.createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(BreathingCirclePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
