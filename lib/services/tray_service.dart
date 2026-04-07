import 'dart:io';
import 'package:system_tray/system_tray.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class TrayService {
  final SystemTray _systemTray = SystemTray();
  final Menu _menu = Menu();

  Future<void> init({
    required VoidCallback onOpen,
    required VoidCallback onPause,
    required VoidCallback onResume,
    required VoidCallback onExit,
    required bool isMonitoring,
  }) async {
    if (!Platform.isWindows) return;

    try {
      final iconPath = Platform.isWindows
          ? 'windows/runner/resources/app_icon.ico'
          : 'assets/app_icon.png';

      await _systemTray.initSystemTray(
        title: "Prayer Time Sleep Assistant",
        iconPath: iconPath,
      );

      await _menu.buildFrom([
        MenuItemLabel(label: 'Open App', onClicked: (menuItem) => onOpen()),
        MenuItemLabel(
          label: isMonitoring ? 'Pause Monitoring' : 'Resume Monitoring',
          onClicked: (menuItem) {
            if (isMonitoring) {
              onPause();
            } else {
              onResume();
            }
          },
        ),
        MenuSeparator(),
        MenuItemLabel(label: 'Exit', onClicked: (menuItem) => onExit()),
      ]);

      await _systemTray.setContextMenu(_menu);

      _systemTray.registerSystemTrayEventHandler((eventName) {
        if (eventName == 'leftMouseDown' || eventName == 'click') {
          onOpen();
        } else if (eventName == 'rightMouseDown' || eventName == 'rightClick') {
          _systemTray.popUpContextMenu();
        }
      });
    } catch (e) {
      debugPrint("System tray initialization failed: $e");
    }
  }

  Future<void> updateTrayMenu({
    required VoidCallback onOpen,
    required VoidCallback onPause,
    required VoidCallback onResume,
    required VoidCallback onExit,
    required bool isMonitoring,
  }) async {
    if (!Platform.isWindows) return;

    try {
      await _menu.buildFrom([
        MenuItemLabel(label: 'Open App', onClicked: (menuItem) => onOpen()),
        MenuItemLabel(
          label: isMonitoring ? 'Pause Monitoring' : 'Resume Monitoring',
          onClicked: (menuItem) {
            if (isMonitoring) {
              onPause();
            } else {
              onResume();
            }
          },
        ),
        MenuSeparator(),
        MenuItemLabel(label: 'Exit', onClicked: (menuItem) => onExit()),
      ]);

      await _systemTray.setContextMenu(_menu);
    } catch (e) {
      debugPrint("Tray update failed: $e");
    }
  }
}
