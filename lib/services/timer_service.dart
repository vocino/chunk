import 'dart:async';
import 'package:flutter/foundation.dart';

class TimerService extends ChangeNotifier {
  Timer? _timer;
  int _elapsedSeconds = 0;
  bool _isRunning = false;

  int get elapsedSeconds => _elapsedSeconds;
  bool get isRunning => _isRunning;

  void start() {
    if (_isRunning) return;

    _isRunning = true;
    _elapsedSeconds = 0;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _elapsedSeconds++;
      notifyListeners();
    });
    notifyListeners();
  }

  int stop() {
    _isRunning = false;
    _timer?.cancel();
    _timer = null;
    final elapsed = _elapsedSeconds;
    notifyListeners();
    return elapsed;
  }

  String formatElapsed(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
