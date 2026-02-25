import 'break_activity.dart';

enum StepType { start, timer, completion, break_, summary }

class SessionStep {
  final StepType type;
  final int? elapsedSeconds;
  final int? questionsUntilBreak;
  final BreakActivity? activity;

  SessionStep(
    this.type, {
    this.elapsedSeconds,
    this.questionsUntilBreak,
    this.activity,
  });
}
