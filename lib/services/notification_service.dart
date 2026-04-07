import 'package:local_notifier/local_notifier.dart';

class NotificationService {
  Future<void> init() async {
    await localNotifier.setup(
      appName: 'Prayer Time Sleep Assistant',
      shortcutPolicy: ShortcutPolicy.requireCreate,
    );
  }

  Future<void> showPrayerNotification(String title, String body) async {
    LocalNotification notification = LocalNotification(
      title: title,
      body: body,
    );
    await notification.show();
  }
}
