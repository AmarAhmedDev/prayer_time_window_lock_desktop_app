import 'package:process_run/shell.dart';
import 'dart:io';

class WindowsSleepService {
  final Shell _shell = Shell();

  Future<void> sleep() async {
    if (!Platform.isWindows) return;

    try {
      // Execute Windows sleep command:
      // rundll32.exe powrprof.dll,SetSuspendState 0,1,0
      // 0 = Standby (Sleep), 1 = Force, 0 = Wake events allowed
      await _shell.run('rundll32.exe powrprof.dll,SetSuspendState 0,1,0');
    } catch (e) {
      print('Error putting Windows to sleep: $e');
    }
  }

  Future<void> setStartup(bool enable) async {
    if (!Platform.isWindows) return;

    try {
      final String executablePath = Platform.resolvedExecutable;
      final String appName = 'PrayerTimeSleepAssistant';
      
      if (enable) {
        // Add to registry for current user
        await _shell.run('reg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Run" /v "$appName" /t REG_SZ /d "$executablePath" /f');
      } else {
        // Remove from registry
        await _shell.run('reg delete "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Run" /v "$appName" /f');
      }
    } catch (e) {
      print('Error setting startup: $e');
    }
  }
}
