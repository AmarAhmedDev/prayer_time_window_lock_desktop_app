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
  String? _lastTriggeredPrayer;
  String? _lastTriggeredDate;
  bool _isStartupEnabled = false;
  bool _isReminderSoundEnabled = true;
  bool _isTriggerInProgress = false;

  // Track which prayers have already received a 30-second warning today
  // Key format: "prayerName_yyyy-MM-dd"
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
    _lastTriggeredPrayer = _storageService.getLastTriggeredPrayer();
    _lastTriggeredDate = _storageService.getLastTriggeredDate();
    _isStartupEnabled = _storageService.getStartupEnabled();
    _isReminderSoundEnabled = _storageService.getReminderSoundEnabled();
    notifyListeners();
  }

  Future<void> updatePrayerTime(String name, String newTime) async {
    final index = _prayers.indexWhere((p) => p.name == name);
    if (index != -1) {
      _prayers[index].time = newTime;
      await _storageService.savePrayerTimes(_prayers);
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

  /// Called every second by TimerController to check for 30-second warning.
  /// Sends a notification when a prayer time is ~30 seconds away.
  void checkPrayerWarning(DateTime now) {
    if (!_isMonitoring) return;

    final todayDate = DateFormat('yyyy-MM-dd').format(now);

    // Clean up old warned prayers from previous days
    _warnedPrayers.removeWhere((key) => !key.endsWith(todayDate));

    for (var prayer in _prayers) {
      if (!prayer.isEnabled) continue;

      final warningKey = '${prayer.name}_$todayDate';

      // Skip if already warned today for this prayer
      if (_warnedPrayers.contains(warningKey)) continue;

      // Skip if already triggered today
      if (_lastTriggeredPrayer == prayer.name && _lastTriggeredDate == todayDate) {
        continue;
      }

      // Calculate exact seconds until this prayer
      final parts = prayer.time.split(':');
      final prayerHour = int.parse(parts[0]);
      final prayerMinute = int.parse(parts[1]);

      final prayerDateTime = DateTime(
        now.year, now.month, now.day,
        prayerHour, prayerMinute, 0,
      );

      final secondsUntil = prayerDateTime.difference(now).inSeconds;

      // Trigger warning when 25-35 seconds remain (window to catch it reliably)
      if (secondsUntil >= 25 && secondsUntil <= 35) {
        _warnedPrayers.add(warningKey);
        debugPrint('[PrayerController] 30-second warning for ${prayer.name} (${secondsUntil}s remaining)');

        _notificationService.showPrayerNotification(
          '⏰ ${prayer.name} in 30 seconds!',
          'Your PC will sleep when prayer time arrives. Prepare now!',
        );
        break; // Only one warning at a time
      }
    }
  }

  /// Called on every minute change by TimerController.
  /// Triggers sleep when prayer time matches.
  Future<void> checkPrayers() async {
    if (!_isMonitoring) return;

    // Prevent concurrent triggers
    if (_isTriggerInProgress) return;

    final now = DateTime.now();
    final todayDate = DateFormat('yyyy-MM-dd').format(now);
    final currentMinutes = now.hour * 60 + now.minute;

    debugPrint('[PrayerController] Checking prayers at ${DateFormat('HH:mm:ss').format(now)}');

    for (var prayer in _prayers) {
      if (!prayer.isEnabled) continue;

      // Smart Sleep Logic: Skip if already triggered today
      if (_lastTriggeredPrayer == prayer.name && _lastTriggeredDate == todayDate) {
        continue;
      }

      final prayerMinutes = _timeToMinutes(prayer.time);

      // Match if current time is within a 2-minute window
      final diff = currentMinutes - prayerMinutes;
      if (diff >= 0 && diff <= 1) {
        debugPrint('[PrayerController] Prayer time matched: ${prayer.name} at ${prayer.time} (diff: ${diff}min)');
        await _triggerSleep(prayer.name, todayDate);
        break;
      }
    }
  }

  Future<void> _triggerSleep(String prayerName, String date) async {
    _isTriggerInProgress = true;

    _lastTriggeredPrayer = prayerName;
    _lastTriggeredDate = date;
    await _storageService.setLastTriggered(prayerName, date);
    
    // Show notification
    debugPrint('[PrayerController] Sending sleep notification for $prayerName...');
    await _notificationService.showPrayerNotification(
      '🕌 Prayer Time: $prayerName',
      'Sleeping PC in 10 seconds...',
    );

    // Wait 10 seconds
    await Future.delayed(const Duration(seconds: 10));

    // Put Windows to sleep
    await _sleepService.sleep();
    
    _isTriggerInProgress = false;
    notifyListeners();
  }

  PrayerTimeModel? getNextPrayer() {
    final now = DateTime.now();
    final currentTimeMinutes = now.hour * 60 + now.minute;

    List<PrayerTimeModel> enabledPrayers = _prayers.where((p) => p.isEnabled).toList();
    if (enabledPrayers.isEmpty) return null;

    // Sort by time
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

    // If all prayers today are passed, the next one is the first prayer of tomorrow
    return enabledPrayers.first;
  }

  int _timeToMinutes(String time) {
    final parts = time.split(':');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }
}
