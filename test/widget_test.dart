// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:chunk/main.dart';
import 'package:chunk/services/activity_service.dart';

void main() {
  testWidgets('App launches with Start screen', (WidgetTester tester) async {
    // Create activity service
    final activityService = ActivityService();
    await activityService.loadActivities();

    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp(activityService: activityService));

    // Verify that the Start screen is displayed.
    expect(find.text('Start'), findsOneWidget);
  });
}
