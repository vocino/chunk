import 'dart:async';
import 'package:flutter/foundation.dart';

class TimerService extends ChangeNotifier {
  Timer? _timer;
  DateTime? _startTime;
  int _stoppedElapsed = 0;
  bool _isRunning = false;
  final DateTime Function() _now;

  TimerService({DateTime Function()? now}) : _now = now ?? DateTime.now;

  int get elapsedSeconds =>
      _isRunning ? _now().difference(_startTime!).inSeconds : _stoppedElapsed;
  bool get isRunning => _isRunning;

  void start() {
    if (_isRunning) return;

    _isRunning = true;
    _startTime = _now();
    _stoppedElapsed = 0;
    // Ticks only refresh listeners; elapsed time comes from the wall clock so
    // background throttling can't corrupt timings.
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => notifyListeners(),
    );
    notifyListeners();
  }

  int stop() {
    if (_isRunning && _startTime != null) {
      _stoppedElapsed = _now().difference(_startTime!).inSeconds;
    }
    _isRunning = false;
    _timer?.cancel();
    _timer = null;
    notifyListeners();
    return _stoppedElapsed;
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
