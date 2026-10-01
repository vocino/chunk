import 'package:flutter_test/flutter_test.dart';
import 'package:chunk/services/timer_service.dart';

void main() {
  group('TimerService — start / stop', () {
    test('start sets isRunning to true and resets elapsed to zero', () {
      final timer = TimerService();
      timer.start();
      expect(timer.isRunning, isTrue);
      expect(timer.elapsedSeconds, 0);
      timer.stop();
    });

    test('stop sets isRunning to false', () {
      final timer = TimerService();
      timer.start();
      timer.stop();
      expect(timer.isRunning, isFalse);
    });

    test('stop returns the elapsed seconds at the moment it is called', () {
      final timer = TimerService();
      timer.start();
      final elapsed = timer.stop();
      // Called immediately — no ticks have fired, so elapsed is 0.
      expect(elapsed, 0);
    });

    test('calling start a second time while already running is a no-op', () {
      final timer = TimerService();
      timer.start();
      final firstIsRunning = timer.isRunning;
      timer.start(); // should be ignored
      expect(timer.isRunning, firstIsRunning);
      timer.stop();
    });

    test('start after stop resets elapsed to zero', () {
      final timer = TimerService();
      timer.start();
      timer.stop();
      timer.start();
      expect(timer.elapsedSeconds, 0);
      timer.stop();
    });
  });

  group('TimerService — formatElapsed', () {
    late TimerService timer;

    setUp(() => timer = TimerService());

    test('formats zero seconds as 00:00', () {
      expect(timer.formatElapsed(0), '00:00');
    });

    test('formats seconds below one minute', () {
      expect(timer.formatElapsed(5), '00:05');
      expect(timer.formatElapsed(59), '00:59');
    });

    test('formats one minute exactly', () {
      expect(timer.formatElapsed(60), '01:00');
    });

    test('formats minutes and seconds together', () {
      expect(timer.formatElapsed(65), '01:05');
      expect(timer.formatElapsed(3661), '61:01');
    });

    test('pads single-digit seconds with a leading zero', () {
      expect(timer.formatElapsed(61), '01:01');
    });
  });
}
