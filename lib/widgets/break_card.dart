import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/break_activity.dart';
import '../models/session_state.dart';
import '../services/sound_service.dart';
import '../theme/app_theme.dart';
import 'advance_arrow.dart';
import 'glass_container.dart';

class BreakCard extends StatefulWidget {
  final BreakActivity activity;
  final VoidCallback onComplete;
  final VoidCallback onDone;
  final DateTime Function()? now;

  const BreakCard({
    super.key,
    required this.activity,
    required this.onComplete,
    required this.onDone,
    this.now,
  });

  @override
  State<BreakCard> createState() => _BreakCardState();
}

class _BreakCardState extends State<BreakCard> {
  late int _duration;
  late int _remainingSeconds;
  late DateTime _endTime;
  Timer? _countdownTimer;

  DateTime _now() => widget.now != null ? widget.now!() : DateTime.now();

  @override
  void initState() {
    super.initState();
    _duration = context.read<SessionState>().breakDuration;
    _remainingSeconds = _duration;
    _endTime = _now().add(Duration(seconds: _duration));
    _countdownTimer =
        Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    // Remaining time comes from the end timestamp (not tick counting) so
    // background throttling can't stretch the break. Ceil keeps the full
    // duration visible at the start (60 → … → 1 → done).
    final remaining =
        (_endTime.difference(_now()).inMilliseconds / 1000).ceil();
    if (remaining <= 0) {
      _countdownTimer?.cancel();
      context.read<SoundService>().playDing();
      widget.onComplete();
    } else {
      setState(() {
        // clamp() returns num; toInt() restores the static int type.
        _remainingSeconds = remaining.clamp(0, _duration).toInt();
      });
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            const Spacer(),
            GlassContainer(
              glowColor: AppTheme.pink,
              borderGradient: AppTheme.borderGradient(
                from: AppTheme.pink,
                to: AppTheme.mauve,
              ),
              fillOpacity: 0.12,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Break time!',
                    style:
                        AppTheme.headingMedium(context).copyWith(color: AppTheme.pink),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),
                  Semantics(
                    liveRegion: true,
                    excludeSemantics: true,
                    label:
                        'Break time remaining: $_remainingSeconds seconds',
                    child: Text(
                      '$_remainingSeconds',
                      style: AppTheme.headingLarge(context).copyWith(
                        fontSize: 72 * AppTheme.scaleFactor(context),
                        color: AppTheme.sky,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 48),
                  Text(
                    'How about:',
                    style: AppTheme.bodyLarge(context).copyWith(
                      fontSize: 20 * AppTheme.scaleFactor(context),
                      color: AppTheme.overlay1,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${widget.activity.emoji} ${widget.activity.text}',
                    style: AppTheme.headingMedium(context).copyWith(
                      fontSize: 28 * AppTheme.scaleFactor(context),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const Spacer(),
            AdvanceArrow(
              label: 'back to work',
              onTap: widget.onComplete,
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                _countdownTimer?.cancel();
                widget.onDone();
              },
              child: Text(
                'all done',
                style: AppTheme.bodyLarge(context).copyWith(
                  color: AppTheme.overlay1,
                  fontSize: 16 * AppTheme.scaleFactor(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
