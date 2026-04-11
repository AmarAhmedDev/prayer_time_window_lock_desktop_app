import 'package:flutter/foundation.dart';
import 'package:local_notifier/local_notifier.dart';

class NotificationService {
  bool _initialized = false;

  Future<void> init() async {
    try {
      await localNotifier.setup(
        appName: 'Prayer Time Sleep Assistant',
        // Use requireCreate to ensure a Start Menu shortcut exists.
        // This is required for Windows toast notifications to work.
        shortcutPolicy: ShortcutPolicy.requireCreate,
      );
      _initialized = true;
      debugPrint('[NotificationService] Initialized successfully.');
    } catch (e) {
      debugPrint('[NotificationService] Init failed: $e');
      _initialized = false;
    }
  }

  Future<void> showPrayerNotification(String title, String body) async {
    // Re-initialize if a previous init failed
    if (!_initialized) {
      debugPrint('[NotificationService] Not initialized, attempting re-init...');
      await init();
    }

    // Attempt to show the notification with retry logic
    for (int attempt = 1; attempt <= 3; attempt++) {
      try {
        final notification = LocalNotification(
          identifier: 'prayer_notification_${DateTime.now().millisecondsSinceEpoch}',
          title: title,
          body: body,
        );

        await notification.show();
        debugPrint('[NotificationService] Notification shown on attempt $attempt: "$title"');
        return; // Success — exit immediately
      } catch (e) {
        debugPrint('[NotificationService] Attempt $attempt failed: $e');
        if (attempt < 3) {
          // Wait briefly before retrying
          await Future.delayed(Duration(milliseconds: 500 * attempt));
        }
      }
    }

    // All retries exhausted
    debugPrint('[NotificationService] FAILED to show notification after 3 attempts: "$title"');
  }
}
