import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:chunk/models/break_activity.dart';
import 'package:chunk/models/session_state.dart';
import 'package:chunk/services/sound_service.dart';
import 'package:chunk/widgets/break_card.dart';
import 'package:chunk/widgets/completion_card.dart';

// NOTE: These tests use explicit pump() durations instead of pumpAndSettle(),
// because the cards contain intentionally infinite animations (arrow bounce)
// and, for BreakCard, a repeating countdown timer.

void main() {
  group('CompletionCard', () {
    testWidgets('shows time and progress, tap advances', (
      WidgetTester tester,
    ) async {
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
      await tester.pump(const Duration(milliseconds: 200));
      expect(advanced, isTrue);
    });

    testWidgets('break variant shows break-time arrow and no counter', (
      WidgetTester tester,
    ) async {
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
      await tester.pump(const Duration(milliseconds: 200));
      expect(completed, isTrue);
    });
  });
}
