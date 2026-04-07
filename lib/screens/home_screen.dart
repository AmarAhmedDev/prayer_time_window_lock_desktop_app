import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/prayer_controller.dart';
import '../controllers/timer_controller.dart';
import '../widgets/prayer_card.dart';
import '../widgets/countdown_widget.dart';
import '../widgets/primary_button.dart';
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppConstants.appName,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                  Text(
                    AppConstants.appSubtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                  ),
                  const SizedBox(height: 40),
                  
                  // Status Section
                  CountdownWidget(
                    title: 'Current Time',
                    countdown: timerController.currentTime,
                  ),
                  const SizedBox(height: 16),
                  CountdownWidget(
                    title: 'Next Prayer',
                    countdown: timerController.countdownText,
                  ),
                  const SizedBox(height: 40),
                  
                  // Settings Section
                  Text(
                    'Settings',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
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
                  const Spacer(),
                  
                  // Action Button
                  SizedBox(
                    width: double.infinity,
                    child: PrimaryButton(
                      text: prayerController.isMonitoring
                          ? 'Monitoring Active'
                          : 'Start Monitoring',
                      icon: prayerController.isMonitoring
                          ? Icons.check_circle
                          : Icons.play_arrow,
                      onPressed: () {
                        prayerController.setMonitoring(!prayerController.isMonitoring);
                      },
                      color: prayerController.isMonitoring
                          ? Colors.green[700]
                          : Theme.of(context).colorScheme.primary,
                    ),
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
