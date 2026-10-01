import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:chunk/models/break_activity.dart';
import 'package:chunk/models/session_state.dart';
import 'package:chunk/services/activity_service.dart';
import 'package:chunk/services/sound_service.dart';
import 'package:chunk/widgets/break_card.dart';
import 'package:chunk/widgets/completion_card.dart';

// NOTE: These tests use explicit pump() durations instead of pumpAndSettle(),
// because the cards contain intentionally infinite animations (arrow bounce)
// and, for BreakCard, a repeating countdown timer.

/// The default 800x600 test surface is shorter than a phone in portrait and
/// scales type up (shortest side 600), which overflows the cards. Run them at
/// a phone-like 390x844 instead.
void _setPhoneViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(1170, 2532);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.reset);
}

/// Pumps until [done] or a 1s fake-time budget runs out. The advance arrow
/// fires onTap only after its 150ms tap animation, and gesture-arena
/// resolution can consume the first pump, so a single pump is not enough.
Future<void> _pumpUntilAdvance(
  WidgetTester tester,
  bool Function() done,
) async {
  for (var i = 0; i < 10 && !done(); i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  group('CompletionCard', () {
    testWidgets('shows time and progress, tap advances', (
      WidgetTester tester,
    ) async {
      _setPhoneViewport(tester);
      var advanced = false;
      await tester.pumpWidget(
        MaterialApp(
          home: CompletionCard(
            formattedTime: '03:24',
            shouldBreak: false,
            questionsUntilBreak: 2,
            onAdvance: () => advanced = true,
            onDone: () {},
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 800));

      expect(find.text('That took'), findsOneWidget);
      expect(find.text('03:24'), findsOneWidget);
      expect(find.text('2 more until break'), findsOneWidget);

      await tester.tap(find.text('ready'));
      await _pumpUntilAdvance(tester, () => advanced);
      expect(advanced, isTrue);
    });

    testWidgets('break variant shows break-time arrow and no counter', (
      WidgetTester tester,
    ) async {
      _setPhoneViewport(tester);
      await tester.pumpWidget(
        MaterialApp(
          home: CompletionCard(
            formattedTime: '00:45',
            shouldBreak: true,
            questionsUntilBreak: 5,
            onAdvance: () {},
            onDone: () {},
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 800));

      expect(find.text('break time'), findsOneWidget);
      expect(find.textContaining('more until break'), findsNothing);
    });

    testWidgets('all-done button ends the session', (
      WidgetTester tester,
    ) async {
      _setPhoneViewport(tester);
      var done = false;
      await tester.pumpWidget(
        MaterialApp(
          home: CompletionCard(
            formattedTime: '01:00',
            shouldBreak: false,
            questionsUntilBreak: 3,
            onAdvance: () {},
            onDone: () => done = true,
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 800));

      await tester.tap(find.text('all done'));
      await tester.pump();
      expect(done, isTrue);
    });
  });

  group('BreakCard', () {
    final activity = BreakActivity(
      id: 'jump-jacks',
      text: 'Do 10 jumping jacks',
      emoji: '🤸',
      category: 'physical',
    );

    Widget wrapBreakCard({
      required DateTime Function() now,
      required VoidCallback onComplete,
      required VoidCallback onDone,
    }) {
      return MaterialApp(
        home: MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => SessionState()),
            Provider(create: (_) => SoundService()),
          ],
          child: BreakCard(
            activity: activity,
            onComplete: onComplete,
            onDone: onDone,
            now: now,
          ),
        ),
      );
    }

    testWidgets('counts down from its end timestamp', (
      WidgetTester tester,
    ) async {
      _setPhoneViewport(tester);
      var now = DateTime(2026, 1, 1, 12);
      await tester.pumpWidget(
        wrapBreakCard(
          now: () => now,
          onComplete: () {},
          onDone: () {},
        ),
      );
      await tester.pump();

      expect(find.text('60'), findsOneWidget);
      expect(find.textContaining('Do 10 jumping jacks'), findsOneWidget);

      // 5 wall-clock seconds pass; ticks recompute from the end timestamp.
      now = now.add(const Duration(seconds: 5));
      await tester.pump(const Duration(seconds: 5));
      expect(find.text('55'), findsOneWidget);
    });

    testWidgets('early exit completes without waiting out the countdown', (
      WidgetTester tester,
    ) async {
      _setPhoneViewport(tester);
      var completed = false;
      final now = DateTime(2026, 1, 1, 12);
      await tester.pumpWidget(
        wrapBreakCard(
          now: () => now,
          onComplete: () => completed = true,
          onDone: () {},
        ),
      );
      await tester.pump();

      await tester.tap(find.text('back to work'));
      await _pumpUntilAdvance(tester, () => completed);
      expect(completed, isTrue);
    });

    testWidgets('refresh swaps in a different activity', (
      WidgetTester tester,
    ) async {
      _setPhoneViewport(tester);
      final first = BreakActivity(
        id: 'a1',
        text: 'Do 10 jumping jacks',
        emoji: '🤸',
        category: 'physical',
      );
      final second = BreakActivity(
        id: 'a2',
        text: 'Touch your toes',
        emoji: '🦶',
        category: 'physical',
      );
      final now = DateTime(2026, 1, 1, 12);
      await tester.pumpWidget(
        MaterialApp(
          home: MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (_) => SessionState()),
              Provider(create: (_) => SoundService()),
              Provider(
                create: (_) => ActivityService(activities: [first, second]),
              ),
            ],
            child: BreakCard(
              activity: first,
              onComplete: () {},
              onDone: () {},
              now: () => now,
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.textContaining('Do 10 jumping jacks'), findsOneWidget);

      // Two-item pool with the current one excluded: the swap is deterministic.
      // Pump until the outgoing child is gone — the tap, the 300ms fade, and
      // the switcher's removal each need frames.
      await tester.tap(find.text('something else'));
      for (var i = 0;
          i < 10 &&
              find.textContaining('Do 10 jumping jacks').evaluate().isNotEmpty;
          i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      expect(find.textContaining('Touch your toes'), findsOneWidget);
      expect(find.textContaining('Do 10 jumping jacks'), findsNothing);
    });
  });
}
