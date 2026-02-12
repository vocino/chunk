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

  @override
  void initState() {
    super.initState();

    // Primary: 19-second breath cycle (4s expand, 7s hold, 8s contract)
    _breathController = AnimationController(
      duration: const Duration(seconds: 19),
      vsync: this,
    );

    _breathAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.0)
            .chain(CurveTween(curve: const Cubic(0.5, 0.0, 0.5, 1.0))),
        weight: 4,
      ),
      TweenSequenceItem(
        tween: ConstantTween<double>(1.0),
        weight: 7,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.0)
            .chain(CurveTween(curve: const Cubic(0.5, 0.0, 0.5, 1.0))),
        weight: 8,
      ),
    ]).animate(_breathController);

    // Secondary: 3-second gentle drift for hold phase vitality
    _driftController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    _driftAnimation = Tween<double>(begin: -1.0, end: 1.0)
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
          return CustomPaint(
            painter: FlowerBreathingPainter(
              progress: _breathAnimation.value,
              drift: _driftAnimation.value,
            ),
            child: const SizedBox.expand(),
          );
        },
      ),
    );
  }
}

class FlowerBreathingPainter extends CustomPainter {
  final double progress;
  final double drift;

  static const int petalCount = 6;
  static const List<Color> petalColors = [
    AppTheme.cyan,
    AppTheme.purple,
    AppTheme.pink,
    AppTheme.cyan,
    AppTheme.purple,
    AppTheme.pink,
  ];

  FlowerBreathingPainter({required this.progress, required this.drift});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = min(size.width, size.height) / 2;

    // Derived values
    final containerScale = 0.15 + progress * 0.85;
    final effectiveRadius = maxRadius * containerScale;
    final rotationAngle = progress * pi;
    // Drift scales smoothly — strongest at progress=1.0, fades toward 0
    // Using pow(progress, 8) creates a curve that's near-zero for most of the
    // expand/contract phases but ramps up smoothly near the hold phase
    final driftStrength = pow(progress, 8).toDouble();
    final effectiveDrift = drift * driftStrength;

    // 1. Ambient background glow
    _drawAmbientGlow(canvas, center, maxRadius, progress);

    // 2. Per-petal glow pass (behind main petals)
    for (int i = 0; i < petalCount; i++) {
      final petalCenter = _petalPosition(
          center, effectiveRadius, i, rotationAngle, effectiveDrift);
      _drawPetalGlow(
          canvas, petalCenter, effectiveRadius * 0.38, petalColors[i]);
    }

    // 3. Main petal pass
    for (int i = 0; i < petalCount; i++) {
      final petalCenter = _petalPosition(
          center, effectiveRadius, i, rotationAngle, effectiveDrift);
      _drawPetal(
          canvas, petalCenter, effectiveRadius * 0.38, petalColors[i]);
    }

    // 4. Center convergence glow
    _drawCenterGlow(canvas, center, effectiveRadius, effectiveDrift);
  }

  Offset _petalPosition(Offset center, double containerRadius, int index,
      double rotation, double drift) {
    final baseAngle = (2 * pi / petalCount) * index;
    final angle = baseAngle + rotation - drift * 0.1;
    final baseSpread = containerRadius * 0.35;
    final spreadDistance = progress * baseSpread + drift * containerRadius * 0.03;
    return Offset(
      center.dx + cos(angle) * spreadDistance,
      center.dy + sin(angle) * spreadDistance,
    );
  }

  void _drawAmbientGlow(
      Canvas canvas, Offset center, double maxRadius, double progress) {
    final ambientOpacity = 0.08 + progress * 0.12;
    final ambientRadius = maxRadius * 0.8;
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          AppTheme.purple.withValues(alpha: ambientOpacity),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: ambientRadius));
    canvas.drawCircle(center, ambientRadius, paint);
  }

  void _drawPetalGlow(
      Canvas canvas, Offset petalCenter, double petalRadius, Color color) {
    final opacity = (0.15 + progress * 0.15).clamp(0.0, 1.0);
    final glowPaint = Paint()
      ..color = color.withValues(alpha: opacity)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12.0)
      ..blendMode = BlendMode.plus;
    canvas.drawCircle(petalCenter, petalRadius * 0.8, glowPaint);
  }

  void _drawPetal(
      Canvas canvas, Offset petalCenter, double petalRadius, Color color) {
    final opacity = (0.4 + progress * 0.3).clamp(0.0, 1.0);

    final gradient = RadialGradient(
      colors: [
        color.withValues(alpha: opacity),
        color.withValues(alpha: opacity * 0.5),
        color.withValues(alpha: 0.0),
      ],
      stops: const [0.0, 0.6, 1.0],
    );

    final paint = Paint()
      ..shader = gradient.createShader(
          Rect.fromCircle(center: petalCenter, radius: petalRadius))
      ..blendMode = BlendMode.plus;

    canvas.drawCircle(petalCenter, petalRadius, paint);
  }

  void _drawCenterGlow(
      Canvas canvas, Offset center, double effectiveRadius, double drift) {
    final centerRadius = effectiveRadius * 0.2;
    final driftStrength = pow(progress, 8).toDouble();
    final holdPulse = sin(drift * pi) * 0.05 * driftStrength;
    final centerOpacity = (0.1 + progress * 0.15 + holdPulse).clamp(0.0, 1.0);

    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withValues(alpha: centerOpacity),
          Colors.white.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: centerRadius))
      ..blendMode = BlendMode.plus;

    canvas.drawCircle(center, centerRadius, paint);
  }

  @override
  bool shouldRepaint(FlowerBreathingPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.drift != drift;
  }
}
