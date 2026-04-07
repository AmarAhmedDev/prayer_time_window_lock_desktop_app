class AppConstants {
  static const String appName = 'Prayer Time Sleep Assistant';
  static const String appSubtitle = 'Automatically sleep your PC when prayer time arrives';
  
  // Storage Keys
  static const String keyPrayerTimes = 'prayer_times';
  static const String keyMonitoringStatus = 'monitoring_status';
  static const String keyLastTriggeredPrayer = 'last_triggered_prayer';
  static const String keyLastTriggeredDate = 'last_triggered_date';
  static const String keyStartupEnabled = 'startup_enabled';
  static const String keyReminderSoundEnabled = 'reminder_sound_enabled';

  // Prayer Names
  static const List<String> prayerNames = [
    'Fajr',
    'Dhuhr',
    'Asr',
    'Maghrib',
    'Isha',
  ];

  // Default Prayer Times
  static const Map<String, String> defaultPrayerTimes = {
    'Fajr': '05:00',
    'Dhuhr': '12:30',
    'Asr': '15:45',
    'Maghrib': '18:30',
    'Isha': '20:00',
  };
}
