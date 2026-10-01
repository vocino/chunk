import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/break_activity.dart';
import '../models/session_state.dart';
import '../services/activity_service.dart';
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
  late BreakActivity _currentActivity;
  Timer? _countdownTimer;

  DateTime _now() => widget.now != null ? widget.now!() : DateTime.now();

  @override
  void initState() {
    super.initState();
    _duration = context.read<SessionState>().breakDuration;
    _currentActivity = widget.activity;
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

  void _refreshActivity() {
    final sessionState = context.read<SessionState>();
    final activityService = context.read<ActivityService>();
    final next = activityService.getRandomActivity(
      [...sessionState.recentActivityIds, _currentActivity.id],
    );
    sessionState.addRecentActivity(next.id);
    setState(() {
      _currentActivity = next;
    });
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
                    style: AppTheme.title(context)
                        .copyWith(color: AppTheme.pink),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppTheme.spaceXXL),
                  Semantics(
                    liveRegion: true,
                    excludeSemantics: true,
                    label:
                        'Break time remaining: $_remainingSeconds seconds',
                    child: Text(
                      '$_remainingSeconds',
                      style: AppTheme.numerals(context).copyWith(
                        color: AppTheme.sky,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spaceXXL),
                  Text(
                    'How about:',
                    style: AppTheme.caption(context),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppTheme.spaceMD),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Text(
                      '${_currentActivity.emoji} ${_currentActivity.text}',
                      key: ValueKey(_currentActivity.id),
                      style: AppTheme.activity(context),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spaceSM),
                  TextButton(
                    onPressed: _refreshActivity,
                    child: Text(
                      'something else',
                      style: AppTheme.label(context).copyWith(
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            AdvanceArrow(
              label: 'back to work',
              onTap: widget.onComplete,
            ),
            const SizedBox(height: AppTheme.spaceXS),
            TextButton(
              onPressed: () {
                _countdownTimer?.cancel();
                widget.onDone();
              },
              child: Text(
                'all done',
                style: AppTheme.label(context).copyWith(
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
