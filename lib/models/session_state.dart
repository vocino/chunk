import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SessionState extends ChangeNotifier {
  static const _breakDurationKey = 'breakDuration';
  static const _defaultBreakDuration = 60;

  int _questionCount = 0;
  int _totalQuestions = 0;
  int _breakDuration = _defaultBreakDuration;
  final List<String> _recentActivityIds = [];
  final List<int> _questionTimes = [];
  DateTime? _sessionStart;

  int get questionCount => _questionCount;
  int get questionsUntilBreak => 5 - (_questionCount % 5);
  int get totalQuestions => _totalQuestions;
  int get breakDuration => _breakDuration;
  List<String> get recentActivityIds => List.unmodifiable(_recentActivityIds);
  List<int> get questionTimes => List.unmodifiable(_questionTimes);
  int get totalSessionSeconds =>
      _sessionStart == null ? 0 : DateTime.now().difference(_sessionStart!).inSeconds;

  /// Restores persisted settings. Called once at startup before runApp.
  Future<void> loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _breakDuration = prefs.getInt(_breakDurationKey) ?? _defaultBreakDuration;
    notifyListeners();
  }

  void setBreakDuration(int seconds) {
    _breakDuration = seconds;
    notifyListeners();
    unawaited(_persistBreakDuration(seconds));
  }

  Future<void> _persistBreakDuration(int seconds) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_breakDurationKey, seconds);
  }

  void incrementQuestion() {
    _questionCount++;
    _totalQuestions++;
    notifyListeners();
  }

  void recordQuestion(int elapsedSeconds) {
    _sessionStart ??= DateTime.now();
    _questionTimes.add(elapsedSeconds);
  }

  bool shouldTriggerBreak() {
    return _questionCount % 5 == 0 && _questionCount > 0;
  }

  void resetCycle() {
    _questionCount = 0;
    notifyListeners();
  }

  void addRecentActivity(String activityId) {
    _recentActivityIds.add(activityId);
    if (_recentActivityIds.length > 10) {
      _recentActivityIds.removeAt(0);
    }
    notifyListeners();
  }

  void reset() {
    _questionCount = 0;
    _totalQuestions = 0;
    _recentActivityIds.clear();
    _questionTimes.clear();
    _sessionStart = null;
    notifyListeners();
  }
}
