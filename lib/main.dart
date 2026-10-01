import 'dart:ui' show PointerDeviceKind;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/session_state.dart';
import 'services/timer_service.dart';
import 'services/activity_service.dart';
import 'services/sound_service.dart';
import 'theme/app_theme.dart';
import 'screens/session_screen.dart';

/// Scroll behavior that also accepts click-drag scrolling from a mouse, so
/// desktop users can swipe through cards by dragging (touch behavior is
/// unchanged). The scroll wheel works independently of this setting.
class MouseFriendlyScrollBehavior extends ScrollBehavior {
  const MouseFriendlyScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => const {
        PointerDeviceKind.touch,
        PointerDeviceKind.stylus,
        PointerDeviceKind.invertedStylus,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.mouse,
      };
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load activities on startup
  final activityService = ActivityService();
  await activityService.loadActivities();

  // Restore persisted settings on startup
  final sessionState = SessionState();
  await sessionState.loadPreferences();

  runApp(
    MyApp(activityService: activityService, sessionState: sessionState),
  );
}

class MyApp extends StatelessWidget {
  final ActivityService activityService;
  final SessionState sessionState;

  const MyApp({
    super.key,
    required this.activityService,
    required this.sessionState,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: sessionState),
        ChangeNotifierProvider(create: (_) => TimerService()),
        Provider.value(value: activityService),
        Provider(create: (_) => SoundService()),
      ],
      child: MaterialApp(
        title: 'Chunk',
        theme: AppTheme.darkTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.dark,
        scrollBehavior: const MouseFriendlyScrollBehavior(),
        home: const SessionScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
