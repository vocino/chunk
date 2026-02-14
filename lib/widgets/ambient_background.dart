import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AmbientBackground extends StatefulWidget {
  const AmbientBackground({super.key});

  @override
  State<AmbientBackground> createState() => _AmbientBackgroundState();
}

class _AmbientBackgroundState extends State<AmbientBackground>
    with TickerProviderStateMixin {
  late AnimationController _driftA;
  late AnimationController _driftB;
  late Animation<double> _animA;
  late Animation<double> _animB;
  late final List<_AmbientOrbConfig> _orbs;

  @override
  void initState() {
    super.initState();
    final rng = Random();

    _orbs = [
      _AmbientOrbConfig(
        color: AppTheme.purple,
        opacity: 0.08,
        sizeRatio: 0.7 + rng.nextDouble() * 0.2,
        anchor: const Offset(-0.3, -0.3),
        driftRadius: 0.08 + rng.nextDouble() * 0.07,
        driftAngle: rng.nextDouble() * 2 * pi,
        useControllerA: true,
      ),
      _AmbientOrbConfig(
        color: AppTheme.cyan,
        opacity: 0.06,
        sizeRatio: 0.6 + rng.nextDouble() * 0.2,
        anchor: const Offset(0.3, 0.3),
        driftRadius: 0.08 + rng.nextDouble() * 0.07,
        driftAngle: rng.nextDouble() * 2 * pi,
        useControllerA: false,
      ),
      _AmbientOrbConfig(
        color: AppTheme.pink,
        opacity: 0.05,
        sizeRatio: 0.65 + rng.nextDouble() * 0.2,
        anchor: const Offset(0.3, -0.25),
        driftRadius: 0.08 + rng.nextDouble() * 0.07,
        driftAngle: rng.nextDouble() * 2 * pi,
        useControllerA: true,
      ),
      _AmbientOrbConfig(
        color: AppTheme.purple,
        opacity: 0.04,
        sizeRatio: 0.55 + rng.nextDouble() * 0.2,
        anchor: const Offset(-0.25, 0.3),
        driftRadius: 0.08 + rng.nextDouble() * 0.07,
        driftAngle: rng.nextDouble() * 2 * pi,
        useControllerA: false,
      ),
    ];

    _driftA = AnimationController(
      duration: const Duration(seconds: 25),
      vsync: this,
    );
    _animA = Tween<double>(begin: 0.0, end: 1.0)
        .chain(CurveTween(curve: Curves.easeInOut))
        .animate(_driftA);

    _driftB = AnimationController(
      duration: const Duration(seconds: 31),
      vsync: this,
    );
    _animB = Tween<double>(begin: 0.0, end: 1.0)
        .chain(CurveTween(curve: Curves.easeInOut))
        .animate(_driftB);

    _driftA.repeat(reverse: true);
    _driftB.repeat(reverse: true);
  }

  @override
  void dispose() {
    _driftA.dispose();
    _driftB.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_animA, _animB]),
      builder: (context, child) {
        return CustomPaint(
          painter: _AmbientOrbPainter(
            orbs: _orbs,
            valueA: _animA.value,
            valueB: _animB.value,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class _AmbientOrbPainter extends CustomPainter {
  final List<_AmbientOrbConfig> orbs;
  final double valueA;
  final double valueB;

  _AmbientOrbPainter({
    required this.orbs,
    required this.valueA,
    required this.valueB,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipRect(Offset.zero & size);

    final diagonal = sqrt(size.width * size.width + size.height * size.height);
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    for (final orb in orbs) {
      final t = orb.useControllerA ? valueA : valueB;
      final driftX = cos(orb.driftAngle + t * 2 * pi) * orb.driftRadius;
      final driftY = sin(orb.driftAngle + t * 2 * pi * 0.7) * orb.driftRadius;

      final x = centerX + (orb.anchor.dx + driftX) * size.width;
      final y = centerY + (orb.anchor.dy + driftY) * size.height;
      final radius = diagonal * orb.sizeRatio / 2;

      final shader = RadialGradient(
        colors: [
          orb.color.withValues(alpha: orb.opacity),
          orb.color.withValues(alpha: 0.0),
        ],
        stops: const [0.0, 1.0],
      ).createShader(Rect.fromCircle(center: Offset(x, y), radius: radius));

      final paint = Paint()..shader = shader;
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(_AmbientOrbPainter oldDelegate) {
    return oldDelegate.valueA != valueA || oldDelegate.valueB != valueB;
  }
}

class _AmbientOrbConfig {
  final Color color;
  final double opacity;
  final double sizeRatio;
  final Offset anchor;
  final double driftRadius;
  final double driftAngle;
  final bool useControllerA;

  const _AmbientOrbConfig({
    required this.color,
    required this.opacity,
    required this.sizeRatio,
    required this.anchor,
    required this.driftRadius,
    required this.driftAngle,
    required this.useControllerA,
  });
}
