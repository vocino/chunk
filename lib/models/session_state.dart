import 'package:flutter/foundation.dart';

class SessionState extends ChangeNotifier {
  int _questionCount = 0;
  int _totalQuestions = 0;
  int _breakDuration = 60;
  final List<String> _recentActivityIds = [];

  int get questionCount => _questionCount;
  int get questionsUntilBreak => 5 - (_questionCount % 5);
  int get totalQuestions => _totalQuestions;
  int get breakDuration => _breakDuration;
  List<String> get recentActivityIds => List.unmodifiable(_recentActivityIds);

  void setBreakDuration(int seconds) {
    _breakDuration = seconds;
    notifyListeners();
  }

  void incrementQuestion() {
    _questionCount++;
    _totalQuestions++;
    notifyListeners();
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
    notifyListeners();
  }
}
