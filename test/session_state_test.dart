import 'package:flutter_test/flutter_test.dart';
import 'package:chunk/models/session_state.dart';

void main() {
  group('SessionState — break cadence', () {
    test('break does not trigger before 5 questions', () {
      final state = SessionState();
      for (var i = 0; i < 4; i++) {
        state.incrementQuestion();
        expect(state.shouldTriggerBreak(), isFalse,
            reason: 'break should not fire at question ${i + 1}');
      }
    });

    test('break triggers after exactly 5 questions', () {
      final state = SessionState();
      for (var i = 0; i < 5; i++) {
        state.incrementQuestion();
      }
      expect(state.shouldTriggerBreak(), isTrue);
    });

    test('break does not trigger again at question 6 (cycle resets mid-way)', () {
      final state = SessionState();
      for (var i = 0; i < 5; i++) {
        state.incrementQuestion();
      }
      state.incrementQuestion(); // 6th question — past the break point
      expect(state.shouldTriggerBreak(), isFalse);
    });

    test('questionsUntilBreak counts down from 5 to 1 then resets', () {
      final state = SessionState();
      expect(state.questionsUntilBreak, 5);

      state.incrementQuestion();
      expect(state.questionsUntilBreak, 4);

      state.incrementQuestion();
      expect(state.questionsUntilBreak, 3);

      state.incrementQuestion();
      expect(state.questionsUntilBreak, 2);

      state.incrementQuestion();
      expect(state.questionsUntilBreak, 1);

      // After the 5th question the break fires; resetting the cycle brings it back to 5
      state.incrementQuestion();
      state.resetCycle();
      expect(state.questionsUntilBreak, 5);
    });
  });

  group('SessionState — resetCycle', () {
    test('resetCycle resets per-break count to zero', () {
      final state = SessionState();
      for (var i = 0; i < 5; i++) {
        state.incrementQuestion();
      }
      state.resetCycle();
      expect(state.questionCount, 0);
    });

    test('resetCycle preserves the total question count across breaks', () {
      final state = SessionState();
      for (var i = 0; i < 5; i++) {
        state.incrementQuestion();
      }
      state.resetCycle();
      expect(state.totalQuestions, 5);

      state.incrementQuestion();
      expect(state.totalQuestions, 6);
    });
  });

  group('SessionState — recent activity history', () {
    test('addRecentActivity keeps at most 10 ids', () {
      final state = SessionState();
      for (var i = 0; i < 12; i++) {
        state.addRecentActivity('activity-$i');
      }
      expect(state.recentActivityIds.length, 10);
    });

    test('addRecentActivity evicts the oldest id when the cap is exceeded', () {
      final state = SessionState();
      for (var i = 0; i < 11; i++) {
        state.addRecentActivity('activity-$i');
      }
      expect(state.recentActivityIds.contains('activity-0'), isFalse,
          reason: 'the first added id should have been evicted');
      expect(state.recentActivityIds.contains('activity-10'), isTrue);
    });

    test('recentActivityIds is immutable from the outside', () {
      final state = SessionState();
      state.addRecentActivity('a1');
      expect(() => (state.recentActivityIds as dynamic).add('a2'),
          throwsUnsupportedError);
    });
  });
}
