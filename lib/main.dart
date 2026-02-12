import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/session_state.dart';
import 'services/timer_service.dart';
import 'services/activity_service.dart';
import 'theme/app_theme.dart';
import 'screens/session_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load activities on startup
  final activityService = ActivityService();
  await activityService.loadActivities();

  runApp(MyApp(activityService: activityService));
}

class MyApp extends StatelessWidget {
  final ActivityService activityService;

  const MyApp({super.key, required this.activityService});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SessionState()),
        ChangeNotifierProvider(create: (_) => TimerService()),
        Provider.value(value: activityService),
      ],
      child: MaterialApp(
        title: 'Chunk',
        theme: AppTheme.darkTheme,
        home: const SessionScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
