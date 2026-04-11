import 'package:process_run/shell.dart';
import 'dart:io';

class WindowsSleepService {
  final Shell _shell = Shell();

  Future<void> sleep() async {
    try {
      if (Platform.isWindows) {
        // Execute Windows sleep command:
        // rundll32.exe powrprof.dll,SetSuspendState 0,1,0
        // 0 = Standby (Sleep), 1 = Force, 0 = Wake events allowed
        await _shell.run('rundll32.exe powrprof.dll,SetSuspendState 0,1,0');
      } else if (Platform.isLinux) {
        // Execute Linux sleep command:
        await _shell.run('systemctl suspend');
      } else if (Platform.isMacOS) {
        // Execute macOS sleep command:
        await _shell.run('pmset sleepnow');
      }
    } catch (e) {
      print('Error putting system to sleep: $e');
    }
  }

  Future<void> setStartup(bool enable) async {
    try {
      final String executablePath = Platform.resolvedExecutable;
      final String appName = 'PrayerTimeSleepAssistant';
      
      if (Platform.isWindows) {
        if (enable) {
          // Add to registry for current user
          await _shell.run('reg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Run" /v "$appName" /t REG_SZ /d "$executablePath" /f');
        } else {
          // Remove from registry
          await _shell.run('reg delete "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Run" /v "$appName" /f');
        }
      } else if (Platform.isLinux) {
        final autostartDir = Directory('${Platform.environment['HOME']}/.config/autostart');
        if (!autostartDir.existsSync()) {
          autostartDir.createSync(recursive: true);
        }
        final desktopFile = File('${autostartDir.path}/$appName.desktop');
        
        if (enable) {
          final content = '''[Desktop Entry]
Type=Application
Name=Prayer Time Sleep Assistant
Exec="$executablePath"
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true''';
          await desktopFile.writeAsString(content);
        } else {
          if (desktopFile.existsSync()) {
            await desktopFile.delete();
          }
        }
      } else if (Platform.isMacOS) {
        final launchAgentsDir = Directory('${Platform.environment['HOME']}/Library/LaunchAgents');
        if (!launchAgentsDir.existsSync()) {
          launchAgentsDir.createSync(recursive: true);
        }
        final plistFile = File('${launchAgentsDir.path}/com.$appName.plist');
        
        if (enable) {
          final content = '''<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.$appName</string>
    <key>ProgramArguments</key>
    <array>
        <string>$executablePath</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
</dict>
</plist>''';
          await plistFile.writeAsString(content);
        } else {
          if (plistFile.existsSync()) {
            await plistFile.delete();
          }
        }
      }
    } catch (e) {
      print('Error setting startup: $e');
    }
  }
}
