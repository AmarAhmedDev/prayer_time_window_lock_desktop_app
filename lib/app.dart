import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme.dart';
import 'core/constants.dart';
import 'controllers/prayer_controller.dart';
import 'controllers/timer_controller.dart';
import 'screens/home_screen.dart';

class PrayerApp extends StatelessWidget {
  const PrayerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProxyProvider<PrayerController, TimerController>(
          create: (context) => TimerController(
            Provider.of<PrayerController>(context, listen: false),
          ),
          update: (context, prayerController, timerController) =>
              timerController ?? TimerController(prayerController),
        ),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        theme: AppTheme.darkTheme,
        themeMode: ThemeMode.dark,
        home: const HomeScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
