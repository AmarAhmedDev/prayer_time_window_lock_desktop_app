import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/prayer_time_model.dart';
import '../core/constants.dart';

class StorageService {
  final SharedPreferences _prefs;

  StorageService(this._prefs);

  Future<void> savePrayerTimes(List<PrayerTimeModel> prayers) async {
    final List<String> jsonList = prayers.map((p) => jsonEncode(p.toJson())).toList();
    await _prefs.setStringList(AppConstants.keyPrayerTimes, jsonList);
  }

  List<PrayerTimeModel> getPrayerTimes() {
    final List<String>? jsonList = _prefs.getStringList(AppConstants.keyPrayerTimes);
    if (jsonList == null) {
      // Return defaults if nothing saved
      return AppConstants.prayerNames.map((name) {
        return PrayerTimeModel(
          name: name,
          time: AppConstants.defaultPrayerTimes[name] ?? '12:00',
        );
      }).toList();
    }
    return jsonList.map((json) => PrayerTimeModel.fromJson(jsonDecode(json))).toList();
  }

  Future<void> setMonitoringStatus(bool isActive) async {
    await _prefs.setBool(AppConstants.keyMonitoringStatus, isActive);
  }

  bool getMonitoringStatus() {
    return _prefs.getBool(AppConstants.keyMonitoringStatus) ?? false;
  }

  Future<void> setLastTriggered(String prayerName, String date) async {
    await _prefs.setString(AppConstants.keyLastTriggeredPrayer, prayerName);
    await _prefs.setString(AppConstants.keyLastTriggeredDate, date);
  }

  String? getLastTriggeredPrayer() {
    return _prefs.getString(AppConstants.keyLastTriggeredPrayer);
  }

  String? getLastTriggeredDate() {
    return _prefs.getString(AppConstants.keyLastTriggeredDate);
  }

  Future<void> setStartupEnabled(bool enabled) async {
    await _prefs.setBool(AppConstants.keyStartupEnabled, enabled);
  }

  bool getStartupEnabled() {
    return _prefs.getBool(AppConstants.keyStartupEnabled) ?? false;
  }

  Future<void> setReminderSoundEnabled(bool enabled) async {
    await _prefs.setBool(AppConstants.keyReminderSoundEnabled, enabled);
  }

  bool getReminderSoundEnabled() {
    return _prefs.getBool(AppConstants.keyReminderSoundEnabled) ?? true;
  }
}
