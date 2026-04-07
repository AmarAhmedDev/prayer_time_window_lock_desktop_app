import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_lock_prayer/app.dart';
import 'package:window_lock_prayer/controllers/prayer_controller.dart';
import 'package:window_lock_prayer/services/storage_service.dart';
import 'package:window_lock_prayer/services/notification_service.dart';
import 'package:window_lock_prayer/services/windows_sleep_service.dart';

void main() {
  testWidgets('App basic load test', (WidgetTester tester) async {
    // Setup mock dependencies
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final storageService = StorageService(prefs);
    final notificationService = NotificationService();
    final sleepService = WindowsSleepService();

    final prayerController = PrayerController(
      storageService,
      notificationService,
      sleepService,
    );

    // Build our app and trigger a frame.
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: prayerController,
        child: const PrayerApp(),
      ),
    );

    // Verify app title exists
    expect(find.text('Prayer Time Sleep Assistant'), findsOneWidget);
  });
}
