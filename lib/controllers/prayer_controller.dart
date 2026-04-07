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

  Future<void> checkPrayers() async {
    if (!_isMonitoring) return;

    final now = DateTime.now();
    final todayDate = DateFormat('yyyy-MM-dd').format(now);
    final currentTime = DateFormat('HH:mm').format(now);

    for (var prayer in _prayers) {
      if (!prayer.isEnabled) continue;

      // Smart Sleep Logic: Skip if already triggered today
      if (_lastTriggeredPrayer == prayer.name && _lastTriggeredDate == todayDate) {
        continue;
      }

      // Check if current time matches prayer time
      if (prayer.time == currentTime) {
        await _triggerSleep(prayer.name, todayDate);
        break;
      }
    }
  }

  Future<void> _triggerSleep(String prayerName, String date) async {
    _lastTriggeredPrayer = prayerName;
    _lastTriggeredDate = date;
    await _storageService.setLastTriggered(prayerName, date);
    
    // Show notification
    await _notificationService.showPrayerNotification(
      'Prayer Time Reached: $prayerName',
      'Sleeping PC in 10 seconds...',
    );

    // Wait 10 seconds
    await Future.delayed(const Duration(seconds: 10));

    // Put Windows to sleep
    await _sleepService.sleep();
    
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
