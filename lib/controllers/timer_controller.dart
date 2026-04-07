import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'prayer_controller.dart';

class TimerController extends ChangeNotifier {
  final PrayerController _prayerController;
  Timer? _timer;
  String _currentTime = '';
  String _countdownText = '';

  TimerController(this._prayerController) {
    _startTimer();
  }

  String get currentTime => _currentTime;
  String get countdownText => _countdownText;

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final now = DateTime.now();
      _currentTime = DateFormat('hh:mm:ss a').format(now);
      
      _updateCountdown(now);
      
      // Check every 30 seconds for prayer time match
      if (now.second % 30 == 0) {
        _prayerController.checkPrayers();
      }
      
      notifyListeners();
    });
  }

  void _updateCountdown(DateTime now) {
    final nextPrayer = _prayerController.getNextPrayer();
    if (nextPrayer == null) {
      _countdownText = 'No prayers enabled';
      return;
    }

    final parts = nextPrayer.time.split(':');
    final prayerHour = int.parse(parts[0]);
    final prayerMinute = int.parse(parts[1]);

    DateTime prayerTime = DateTime(
      now.year,
      now.month,
      now.day,
      prayerHour,
      prayerMinute,
    );

    if (prayerTime.isBefore(now)) {
      prayerTime = prayerTime.add(const Duration(days: 1));
    }

    final difference = prayerTime.difference(now);
    final hours = difference.inHours.toString().padLeft(2, '0');
    final minutes = (difference.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (difference.inSeconds % 60).toString().padLeft(2, '0');

    _countdownText = '${nextPrayer.name} in $hours:$minutes:$seconds';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
