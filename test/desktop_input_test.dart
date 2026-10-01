import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:chunk/main.dart';
import 'package:chunk/models/session_state.dart';
import 'package:chunk/services/activity_service.dart';

// Desktop input coverage: the swipe flow must advance with a mouse —
// click-drag (swipe), click (arrow tap), and scroll wheel. These tests pump
// the full app so the real MaterialApp scroll behavior applies.
//
// NOTE: Explicit pumps instead of pumpAndSettle(): the session screen hosts
// intentionally infinite ambient animations.

/// Phone-like portrait viewport (see card_widget_test.dart).
void _setPhoneViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(1170, 2532);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.reset);
}

Future<void> _pumpSession(WidgetTester tester) async {
  await tester.pumpWidget(
    MyApp(activityService: ActivityService(), sessionState: SessionState()),
  );
  await tester.pump();
}

/// Pumps until [finder] matches or a 3s fake-time budget runs out.
Future<void> _pumpUntilFound(WidgetTester tester, Finder finder) async {
  for (var i = 0; i < 30 && finder.evaluate().isEmpty; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  group('Desktop mouse input', () {
    testWidgets('click-drag upward advances start to timer', (
      WidgetTester tester,
    ) async {
      _setPhoneViewport(tester);
      await _pumpSession(tester);
      expect(find.text('Ready?'), findsOneWidget);

      // Press and drag upward past half a page, then release.
      final center = tester.getCenter(find.byType(PageView));
      final gesture = await tester.startGesture(
        center,
        kind: PointerDeviceKind.mouse,
      );
      await gesture.moveBy(const Offset(0, -600));
      await gesture.up();

      await _pumpUntilFound(tester, find.text('finished'));
      expect(find.text('finished'), findsOneWidget);
    });

    testWidgets('mouse click on the arrow advances start to timer', (
      WidgetTester tester,
    ) async {
      _setPhoneViewport(tester);
      await _pumpSession(tester);
      expect(find.text('Ready?'), findsOneWidget);

      // A real mouse click: down + up with the mouse pointer kind
      // (tester.tap uses touch).
      final arrow = tester.getCenter(find.text('swipe to start'));
      final gesture = await tester.startGesture(
        arrow,
        kind: PointerDeviceKind.mouse,
      );
      await gesture.up();

      await _pumpUntilFound(tester, find.text('finished'));
      expect(find.text('finished'), findsOneWidget);
    });

    testWidgets('scroll wheel down advances start to timer', (
      WidgetTester tester,
    ) async {
      _setPhoneViewport(tester);
      await _pumpSession(tester);
      expect(find.text('Ready?'), findsOneWidget);

      final center = tester.getCenter(find.byType(PageView));
      tester.binding.handlePointerEvent(
        PointerScrollEvent(
          position: center,
          scrollDelta: const Offset(0, 400),
        ),
      );
      await tester.pump();

      await _pumpUntilFound(tester, find.text('finished'));
      expect(find.text('finished'), findsOneWidget);
    });
  });
}
