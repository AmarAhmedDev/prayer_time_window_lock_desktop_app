<h1 align="center">
  <br>
  🌙 Prayer Time Sleep Assistant
</h1>

<h4 align="center">A beautifully polished, cross-platform desktop application that automatically triggers system sleep based on your scheduled daily prayer times.</h4>

<p align="center">
  <a href="#-key-features">Key Features</a> •
  <a href="#%EF%B8%8F-how-it-works">How It Works</a> •
  <a href="#-installation--setup">Installation</a> •
  <a href="#-development--building-from-source">Development</a> •
  <a href="#-architecture--tech-stack">Tech Stack</a>
</p>

---

## 📖 Overview

**Prayer Time Sleep Assistant** is a modern, beautifully designed desktop application tailored and crafted with an elegant Islamic deep-ocean aesthetic to ensure you step away from your computer when prayer time arrives. 

It runs quietly in your System Tray and automatically puts your computer to sleep precisely during your scheduled prayer times (Fajr, Dhuhr, Asr, Maghrib, and Isha). By detaching you from your screen reliably, it helps you dedicate true focus to your prayers without distractions.

## ✨ Key Features

* **🌙 Automated PC Sleep**: Automatically suspends your Windows, Linux, or macOS device when the local clock hits your specified prayer time.
* **🍏 Cross-Platform Support**: Works seamlessly on Windows, Linux, and macOS out-of-the-box.
* **🎨 Glassmorphic Islamic UI**: A stunning, borderless dark-mode aesthetic featuring deep navy colors, frosted glass styling, smooth animations, and a rich dynamic glowing circular countdown.
* **🕰️ Custom Prayer Times**: Easily schedule times manually using a beautifully integrated native ultra-smooth time picker.
* **⚙️ Start on Boot**: Automatically injects into the Windows Startup Registry, Linux Autostart directory, or macOS LaunchAgents (defaults to ON for new installs) to ensure you never miss a trigger after rebooting.
* **🔔 Native Push Notifications**: Fires a system notification 10 seconds before putting your PC to sleep to give you a brief heads-up.
* **🖥️ System Tray Integration**: Minimizes completely to the Windows taskbar, Linux system tray, or macOS menu bar, working un-intrusively in the background. Right-click the tray icon to play/pause monitoring instantly.
* **🔊 Audio Alerts**: Toggle gentle reminder chimes on/off within the app settings.

---

## ⚙️ How It Works

1. **Launch the Application**: Once launched, the app reveals an elegant dashboard.
2. **Configure Your Times**: Tap the clock icon next to each prayer to map your local Azaan times.
3. **Toggle Active Prayers**: Use animated switches to enable or disable automated sleep for individual prayers.
4. **Dashboard View**: Admire the animated pulsing circular countdown tracking the seconds until your next active prayer.
5. **Minimize to Tray**: Click the System "Minimize" or "Close" button. The app won't quit entirely but will run securely in your system tray area on the bottom right of your taskbar/panel.
6. **Context Menu**: Right-click the tray icon anytime to pause monitoring, resume, bring the app back to focus, or fully exit the program securely.

---

## 📥 Installation & Setup

### For Windows Users
1. Download the latest `Release` build (e.g., from `ReleasedApp.zip`).
2. Extract the files to a safe directory on your computer (Portable Mode, no heavy installation process needed).
3. Open `window_lock_prayer.exe` to launch the application immediately!

### For Linux Users
1. Download your compiled Linux build directory.
2. Ensure the binary has execution permissions allocated: `chmod +x window_lock_prayer`.
3. Launch the compiled executable.
4. (*Note*: Ensure you have necessary tray-indicator extensions/tools on your Linux desktop environment appropriately configured to see the system tray icon).

### For macOS Users
1. Download the latest macOS `.app` build or extract the release archive.
2. Drag the `window_lock_prayer.app` to your Applications folder.
3. Open it from Launchpad or Spotlight. (You may need to allow it via System Settings > Privacy & Security if it's unsigned).

---

## 💻 Development & Building from Source

This application is built natively utilizing the **Flutter framework**, optimizing underlying native System APIs on Windows, executing bash subshells utilizing Systemd for Linux constraints, and `pmset` commands on macOS.

### Prerequisites
* Flutter SDK (`>=3.11.4`)
* **Windows**: Visual Studio with the "Desktop development with C++" workload installed.
* **Linux**: Core development tools (`clang`, `cmake`, `ninja-build`, `pkg-config`, `libgtk-3-dev`).
* **macOS**: Xcode installed and appropriately configured.

### Local Environment Setup

1. **Clone the project & Fetch Dependencies**
   ```bash
   flutter pub get
   ```

2. **Generate Desktop Icons (if building manually)**
   ```bash
   flutter pub run flutter_launcher_icons
   ```

3. **Run the App Locally**
   ```bash
   # For Windows
   flutter run -d windows
   
   # For Linux
   flutter run -d linux

   # For macOS
   flutter run -d macos
   ```

### Compile Production Release

**To compile raw standalone production executables:**

* **Windows Target**:
  ```bash
  flutter build windows --release
  ```
  *(Output Location: `build\windows\x64\runner\Release\`)*

* **Linux Target**:
  ```bash
  flutter build linux --release
  ```
  *(Output Location: `build\linux\x64\release\bundle\`)*

* **macOS Target**:
  ```bash
  flutter build macos --release
  ```
  *(Output Location: `build\macos\Build\Products\Release\window_lock_prayer.app`)*

---

## 🏗️ Architecture / Tech Stack

* **Frontend UI**: Flutter (Dart) / Material 3 Guidelines
* **State Management**: `Provider`
* **Local Storage / Caching**: `shared_preferences`
* **System Native Interaction**:
  * `window_manager`: UI Window Framing Controls (Hiding, Resizing, Centering).
  * `system_tray`: Background Tray Icon Event Listeners.
  * `local_notifier`: OS Native Push Notifications Engine.
  * `process_run`: Direct shell execution for `rundll32.exe`, `systemctl`, Desktop Entries & Registry edits.

---
<p align="center">Made with 💙 to help maintain perfect Salah consistency.</p>
