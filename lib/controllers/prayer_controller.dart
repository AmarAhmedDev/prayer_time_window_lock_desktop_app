import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/prayer_time_model.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';
import '../services/windows_sleep_service.dart';

class PrayerController extends ChangeNotifier {
  final StorageService _storageService;
  final NotificationService _notificationService;
  final WindowsSleepService _sleepService;

  List<PrayerTimeModel> _prayers = [];
  bool _isMonitoring = false;
  bool _isStartupEnabled = false;
  bool _isReminderSoundEnabled = true;
  bool _isTriggerInProgress = false;

  // Per-prayer tracking: maps "prayerName" -> "time_date" that was triggered
  final Map<String, String> _triggeredPrayers = {};

  // Track which prayers have already received a 30-second warning
  final Set<String> _warnedPrayers = {};

  PrayerController(
    this._storageService,
    this._notificationService,
    this._sleepService,
  ) {
    _loadData();
  }

  List<PrayerTimeModel> get prayers => _prayers;
  bool get isMonitoring => _isMonitoring;
  bool get isStartupEnabled => _isStartupEnabled;
  bool get isReminderSoundEnabled => _isReminderSoundEnabled;

  void _loadData() {
    _prayers = _storageService.getPrayerTimes();
    _isMonitoring = _storageService.getMonitoringStatus();
    _isStartupEnabled = _storageService.getStartupEnabled();
    _isReminderSoundEnabled = _storageService.getReminderSoundEnabled();

    final lastPrayer = _storageService.getLastTriggeredPrayer();
    final lastDate = _storageService.getLastTriggeredDate();
    if (lastPrayer != null && lastDate != null) {
      final prayer = _prayers.where((p) => p.name == lastPrayer).firstOrNull;
      if (prayer != null) {
        _triggeredPrayers[lastPrayer] = '${prayer.time}_$lastDate';
      }
    }

    notifyListeners();
  }

  Future<void> updatePrayerTime(String name, String newTime) async {
    final index = _prayers.indexWhere((p) => p.name == name);
    if (index != -1) {
      _prayers[index].time = newTime;
      await _storageService.savePrayerTimes(_prayers);

      // Clear triggered & warned state so updated time can trigger again
      _triggeredPrayers.remove(name);
      _warnedPrayers.removeWhere((key) => key.startsWith('${name}_'));

      debugPrint('[PrayerController] Time updated for $name to $newTime — trigger state reset');
      notifyListeners();
    }
  }

  Future<void> togglePrayer(String name, bool isEnabled) async {
    final index = _prayers.indexWhere((p) => p.name == name);
    if (index != -1) {
      _prayers[index].isEnabled = isEnabled;
      await _storageService.savePrayerTimes(_prayers);
      notifyListeners();
    }
  }

  Future<void> setMonitoring(bool active) async {
    _isMonitoring = active;
    await _storageService.setMonitoringStatus(active);
    notifyListeners();
  }

  Future<void> toggleStartup(bool enabled) async {
    _isStartupEnabled = enabled;
    await _storageService.setStartupEnabled(enabled);
    await _sleepService.setStartup(enabled);
    notifyListeners();
  }

  Future<void> toggleReminderSound(bool enabled) async {
    _isReminderSoundEnabled = enabled;
    await _storageService.setReminderSoundEnabled(enabled);
    notifyListeners();
  }

  bool _isPrayerTriggeredToday(String name, String time, String todayDate) {
    final key = '${time}_$todayDate';
    return _triggeredPrayers[name] == key;
  }

  void _markPrayerTriggered(String name, String time, String todayDate) {
    _triggeredPrayers[name] = '${time}_$todayDate';
  }

  /// Calculate exact seconds until a prayer time from now
  int _secondsUntilPrayer(PrayerTimeModel prayer, DateTime now) {
    final parts = prayer.time.split(':');
    final prayerHour = int.parse(parts[0]);
    final prayerMinute = int.parse(parts[1]);

    final prayerDateTime = DateTime(
      now.year, now.month, now.day,
      prayerHour, prayerMinute, 0,
    );

    return prayerDateTime.difference(now).inSeconds;
  }

  /// Called every second by TimerController.
  /// Handles BOTH the 10-second warning and the sleep trigger.
  Future<void> checkPrayers(DateTime now) async {
    if (!_isMonitoring) return;
    if (_isTriggerInProgress) return;

    final todayDate = DateFormat('yyyy-MM-dd').format(now);

    for (var prayer in _prayers) {
      if (!prayer.isEnabled) continue;

      // Skip if already triggered for this specific time today
      if (_isPrayerTriggeredToday(prayer.name, prayer.time, todayDate)) continue;

      final secondsUntil = _secondsUntilPrayer(prayer, now);

      // --- 10-second warning notification ---
      // Fires exactly when countdown shows 30s or less (flag prevents duplicates)
      final warningKey = '${prayer.name}_${prayer.time}_$todayDate';
      if (secondsUntil <= 10 && secondsUntil > 0 && !_warnedPrayers.contains(warningKey)) {
        _warnedPrayers.add(warningKey);
        debugPrint('[PrayerController] ⏰ 10-second warning for ${prayer.name} (${secondsUntil}s remaining)');

        // Fire-and-forget: don't await so it doesn't delay the timer tick
        _notificationService.showPrayerNotification(
          '🕌 ${prayer.name} in 10 seconds!',
          'Your PC will sleep and Prepare for ${prayer.name} prayer'
        );
      }

      // --- Sleep trigger: countdown reached 0 ---
      if (secondsUntil <= 0 && secondsUntil >= -60) {
        debugPrint('[PrayerController] ✅ Countdown reached 0 for ${prayer.name} — sleeping PC now!');
        await _triggerSleep(prayer.name, prayer.time, todayDate);
        break;
      }
    }
  }

  Future<void> _triggerSleep(String prayerName, String prayerTime, String date) async {
    _isTriggerInProgress = true;

    // Mark as triggered
    _markPrayerTriggered(prayerName, prayerTime, date);
    await _storageService.setLastTriggered(prayerName, date);

    // Check one last time if still monitoring
    if (!_isMonitoring) {
      debugPrint('[PrayerController] ⏸️ Monitoring paused — sleep cancelled for $prayerName');
      _isTriggerInProgress = false;
      return;
    }

    // Sleep immediately — no extra notification, no delay
    debugPrint('[PrayerController] 💤 Putting PC to sleep for $prayerName');
    await _sleepService.sleep();

    _isTriggerInProgress = false;
    notifyListeners();
  }

  PrayerTimeModel? getNextPrayer() {
    final now = DateTime.now();
    final currentTimeMinutes = now.hour * 60 + now.minute;

    List<PrayerTimeModel> enabledPrayers = _prayers.where((p) => p.isEnabled).toList();
    if (enabledPrayers.isEmpty) return null;

    enabledPrayers.sort((a, b) {
      final aTime = _timeToMinutes(a.time);
      final bTime = _timeToMinutes(b.time);
      return aTime.compareTo(bTime);
    });

    for (var prayer in enabledPrayers) {
      if (_timeToMinutes(prayer.time) > currentTimeMinutes) {
        return prayer;
      }
    }

    return enabledPrayers.first;
  }

  int _timeToMinutes(String time) {
    final parts = time.split(':');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }
}
