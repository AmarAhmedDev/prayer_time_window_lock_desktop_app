import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/prayer_controller.dart';
import '../controllers/timer_controller.dart';
import '../widgets/prayer_card.dart';
import '../widgets/circular_countdown.dart';
import '../widgets/mode_switch.dart';
import '../core/constants.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prayerController = Provider.of<PrayerController>(context);
    final timerController = Provider.of<TimerController>(context);

    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/bg.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Row(
          children: [
            // Sidebar / Left Section
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.25),
                  border: Border(
                    right: BorderSide(
                      color: Colors.white.withOpacity(0.1),
                    ),
                  ),
                ),
                child: Column(
                  children: [
                    // App Title
                    Text(
                      AppConstants.appName,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      AppConstants.appSubtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),

                    // Current Time
                    Text(
                      timerController.currentTime,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withOpacity(0.6),
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Circular Countdown — centered and prominent
                    Expanded(
                      child: Center(
                        child: CircularCountdown(
                          prayerName: prayerController.getNextPrayer()?.name ?? '',
                          countdownText: timerController.countdownText,
                          currentTime: timerController.currentTime,
                          isMonitoring: prayerController.isMonitoring,
                          onToggle: () {
                            prayerController.setMonitoring(!prayerController.isMonitoring);
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Status text
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 300),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                        color: prayerController.isMonitoring
                            ? const Color(0xFF10B981)
                            : Colors.white38,
                      ),
                      child: Text(
                        prayerController.isMonitoring
                            ? '● MONITORING ACTIVE'
                            : '○ MONITORING PAUSED',
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Settings Section
                    ModeSwitch(
                      label: 'Start with Windows',
                      value: prayerController.isStartupEnabled,
                      onChanged: (value) => prayerController.toggleStartup(value),
                      icon: Icons.launch,
                    ),
                    ModeSwitch(
                      label: 'Reminder Sound',
                      value: prayerController.isReminderSoundEnabled,
                      onChanged: (value) => prayerController.toggleReminderSound(value),
                      icon: Icons.notifications_active,
                    ),
                  ],
                ),
              ),
            ),
            
            // Right Section - Prayer List
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Daily Prayer Times',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Set your local prayer times manually',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                    const SizedBox(height: 24),
                    Expanded(
                      child: ListView.builder(
                        itemCount: prayerController.prayers.length,
                        itemBuilder: (context, index) {
                          final prayer = prayerController.prayers[index];
                          return PrayerCard(
                            prayer: prayer,
                            onToggle: (name, value) =>
                                prayerController.togglePrayer(name, value),
                            onTimeChanged: (name, time) =>
                                prayerController.updatePrayerTime(name, time),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
