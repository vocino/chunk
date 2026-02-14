import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class BreathingCircle extends StatefulWidget {
  const BreathingCircle({super.key});

  @override
  State<BreathingCircle> createState() => _BreathingCircleState();
}

class _BreathingCircleState extends State<BreathingCircle>
    with TickerProviderStateMixin {
  late AnimationController _breathController;
  late AnimationController _driftController;
  late Animation<double> _breathAnimation;
  late Animation<double> _driftAnimation;

  // Random offsets generated per instance
  late final List<_CircleConfig> _circles;

  @override
  void initState() {
    super.initState();
    final rng = Random();

    // Each instance gets a unique arrangement
    _circles = [
      _CircleConfig(
        color: AppTheme.purple,
        baseOpacity: 0.2 + rng.nextDouble() * 0.1,
        minScale: 0.4 + rng.nextDouble() * 0.1,
        maxScale: 0.8 + rng.nextDouble() * 0.15,
        angle: rng.nextDouble() * 2 * pi,
        spread: 0.1 + rng.nextDouble() * 0.08,
        driftAngle: rng.nextDouble() * 2 * pi,
        driftAmount: 0.02 + rng.nextDouble() * 0.03,
      ),
      _CircleConfig(
        color: AppTheme.cyan,
        baseOpacity: 0.2 + rng.nextDouble() * 0.15,
        minScale: 0.35 + rng.nextDouble() * 0.1,
        maxScale: 0.75 + rng.nextDouble() * 0.15,
        angle: rng.nextDouble() * 2 * pi,
        spread: 0.1 + rng.nextDouble() * 0.08,
        driftAngle: rng.nextDouble() * 2 * pi,
        driftAmount: 0.02 + rng.nextDouble() * 0.03,
      ),
      _CircleConfig(
        color: AppTheme.pink,
        baseOpacity: 0.2 + rng.nextDouble() * 0.1,
        minScale: 0.35 + rng.nextDouble() * 0.1,
        maxScale: 0.75 + rng.nextDouble() * 0.15,
        angle: rng.nextDouble() * 2 * pi,
        spread: 0.1 + rng.nextDouble() * 0.08,
        driftAngle: rng.nextDouble() * 2 * pi,
        driftAmount: 0.02 + rng.nextDouble() * 0.03,
      ),
    ];

    // 19-second 4-7-8 breath cycle (4s inhale, 7s hold, 8s exhale)
    _breathController = AnimationController(
      duration: const Duration(seconds: 19),
      vsync: this,
    );

    _breathAnimation = TweenSequence<double>([
      // Inhale: 4s — expand 0→1
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 4,
      ),
      // Hold: 7s — stay at 1
      TweenSequenceItem(
        tween: ConstantTween(1.0),
        weight: 7,
      ),
      // Exhale: 8s — contract 1→0
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 8,
      ),
    ]).animate(_breathController);

    // Slow drift for gentle circle wandering
    _driftController = AnimationController(
      duration: const Duration(seconds: 7),
      vsync: this,
    );

    _driftAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .chain(CurveTween(curve: Curves.easeInOut))
        .animate(_driftController);

    _breathController.repeat();
    _driftController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _breathController.dispose();
    _driftController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Calm breathing animation',
      child: AnimatedBuilder(
        animation: Listenable.merge([_breathAnimation, _driftAnimation]),
        builder: (context, child) {
          final p = _breathAnimation.value;
          final d = _driftAnimation.value;
          return LayoutBuilder(
            builder: (context, constraints) {
              final maxSize = min(constraints.maxWidth, constraints.maxHeight);
              return Stack(
                alignment: Alignment.center,
                children: [
                  for (final c in _circles)
                    _buildCircle(
                      size: maxSize * (c.minScale + p * (c.maxScale - c.minScale)),
                      color: c.color,
                      opacity: c.baseOpacity,
                      offset: Offset(
                        cos(c.angle) * maxSize * c.spread * p +
                            cos(c.driftAngle) * maxSize * c.driftAmount * d,
                        sin(c.angle) * maxSize * c.spread * p +
                            sin(c.driftAngle) * maxSize * c.driftAmount * d,
                      ),
                    ),
                  // Center circle stays fixed
                  _buildCircle(
                    size: maxSize * (0.2 + p * 0.4),
                    color: AppTheme.foreground,
                    opacity: 0.06 + p * 0.06,
                    offset: Offset.zero,
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildCircle({
    required double size,
    required Color color,
    required double opacity,
    required Offset offset,
  }) {
    return Transform.translate(
      offset: offset,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: opacity),
        ),
      ),
    );
  }
}

class _CircleConfig {
  final Color color;
  final double baseOpacity;
  final double minScale;
  final double maxScale;
  final double angle;     // direction this circle spreads when breathing expands
  final double spread;    // how far it moves from center on expand
  final double driftAngle; // direction of gentle wander
  final double driftAmount; // how far it drifts

  const _CircleConfig({
    required this.color,
    required this.baseOpacity,
    required this.minScale,
    required this.maxScale,
    required this.angle,
    required this.spread,
    required this.driftAngle,
    required this.driftAmount,
  });
}
