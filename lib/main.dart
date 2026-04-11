import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';
import 'dart:io';

import 'app.dart';
import 'services/storage_service.dart';
import 'services/notification_service.dart';
import 'services/windows_sleep_service.dart';
import 'services/tray_service.dart';
import 'controllers/prayer_controller.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    // Initialize Window Manager
    await windowManager.ensureInitialized();

    // Initialize Services
    final prefs = await SharedPreferences.getInstance();
    final storageService = StorageService(prefs);

    final notificationService = NotificationService();
    await notificationService.init();

    final sleepService = WindowsSleepService();
    final trayService = TrayService();

    // Initialize Controller
    final prayerController = PrayerController(
      storageService,
      notificationService,
      sleepService,
    );

    // Ensure System startup matches the stored preference.
    // Critical for first install where default is ON but registry/autostart isn't set yet.
    if ((Platform.isWindows || Platform.isLinux || Platform.isMacOS) && prayerController.isStartupEnabled) {
      await sleepService.setStartup(true);
    }

    // Initialize Tray (Optional, don't let it block startup)
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      trayService.init(
        onOpen: () async {
          await windowManager.show();
          await windowManager.focus();
        },
        onPause: () => prayerController.setMonitoring(false),
        onResume: () => prayerController.setMonitoring(true),
        onExit: () async {
          await windowManager.destroy();
          exit(0);
        },
        isMonitoring: prayerController.isMonitoring,
      );

      // Handle Tray update when monitoring status changes
      prayerController.addListener(() {
        trayService.updateTrayMenu(
          onOpen: () async {
            await windowManager.show();
            await windowManager.focus();
          },
          onPause: () => prayerController.setMonitoring(false),
          onResume: () => prayerController.setMonitoring(true),
          onExit: () async {
            await windowManager.destroy();
            exit(0);
          },
          isMonitoring: prayerController.isMonitoring,
        );
      });
    }

    // Run the app
    runApp(
      ChangeNotifierProvider.value(
        value: prayerController,
        child: const PrayerApp(),
      ),
    );

    // Set up window properties after running app
    WindowOptions windowOptions = const WindowOptions(
      size: Size(1100, 750),
      center: true,
      backgroundColor: Colors.white,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.normal,
      title: 'Prayer Time Sleep Assistant',
    );

    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
      await windowManager.setResizable(false);
      await windowManager.setMaximizable(false);
    });

    // Prevent window closing, instead minimize to tray
    await windowManager.setPreventClose(true);
    windowManager.addListener(WindowEventHandler());
  } catch (e) {
    debugPrint("Startup error: $e");
    // Fallback if possible
  }
}

// Window Event Handler
class WindowEventHandler extends WindowListener {
  @override
  void onWindowClose() async {
    bool isPreventClose = await windowManager.isPreventClose();
    if (isPreventClose) {
      await windowManager.hide();
    }
  }
}
