<h1 align="center">
  <br>
  🌙 Salat Sync
</h1>

<h4 align="center">A beautifully designed automated sleep timer for your PC based on daily prayer times.</h4>

<p align="center">
  <a href="#key-features">Key Features</a> •
  <a href="#how-to-use">How To Use</a> •
  <a href="#installation">Installation</a> •
  <a href="#development">Development</a>
</p>

---

## 📖 Overview

**Salat Sync** is a modern Windows desktop application crafted with an elegant Islamic deep-ocean aesthetic. It runs quietly in your System Tray and automatically puts your computer to sleep precisely during your scheduled prayer times (Fajr, Dhuhr, Asr, Maghrib, and Isha), ensuring you easily detach from your screen and dedicate true focus to your prayers. 

## ✨ Key Features

* **🌙 Automated Sleep Induction**: Automatically puts your Windows PC to sleep when the local clock hits your specified prayer time.
* **🎨 Glassmorphic Islamic UI**: A stunning, borderless dark-mode aesthetic featuring deep navy colors, frosted glass styling, and a beautiful native 3D desktop icon.
* **🕰️ AM/PM Time Formatting**: Fully respects standard 12-hour time localization directly inside an ultra-smooth picker.
* **🖥️ System Tray Integration**: Minimizes to the Windows taskbar tray to run unobtrusively in the background.
* **🔔 Native Push Notifications**: Warns you 10 seconds before putting your PC to sleep via Windows local notifications.
* **🚀 Start on Boot**: Option to automatically inject seamlessly into the Windows Startup Registry.
* **🔊 Audio Alerts**: Toggle on/off the gentle reminder chimes.

## 🚀 How To Use

1. **Launch the Application**: Run `window_lock_prayer.exe` or double-click the 3D crescent moon icon.
2. **Configure Your Times**: Click the clock icon next to each prayer to match your local Azaan times.
3. **Toggle Active Prayers**: Use the beautifully animated switches to enable or disable automated sleep for specific prayers.
4. **Minimize**: Click the "X" button on the window or minimize it. The app will live in your system tray on the bottom right of your Windows taskbar.
5. **Context Menu**: Right-click the system tray icon anytime to pause monitoring, resume, bring the app back to focus, or fully exit.

## 📥 Installation (For Normal Users)

1. Navigate to the release files provided in the `ReleasedApp.zip` or the `build\windows\x64\runner\Release\` folder.
2. Unzip the package to a safe location on your computer.
3. Absolutely **no installation** is required (Portable Mode). 
4. Just double-click on `window_lock_prayer.exe` to run the application immediately!

## 💻 Development (For Developers)

The app is built utilizing the **Flutter framework** optimizing standard Windows C++ underlying APIs.

### Prerequisites
* Flutter SDK (`>=3.11.4`)
* Visual Studio with "Desktop development with C++" workload installed.

### Build Locally
To run the project in debug mode:

```bash
# Get dependencies
flutter pub get

# Generate desktop icons (if not generated)
flutter pub run flutter_launcher_icons

# Run the app locally
flutter run -d windows
```

### Build Production Release
To compile the raw standalone production executables:

```bash
flutter build windows --release
```

---
<p align="center">Built with 💙 using Flutter</p>
