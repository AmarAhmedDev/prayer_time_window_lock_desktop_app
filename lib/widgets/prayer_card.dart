import 'package:flutter/material.dart';
import '../models/prayer_time_model.dart';

class PrayerCard extends StatelessWidget {
  final PrayerTimeModel prayer;
  final Function(String, bool) onToggle;
  final Function(String, String) onTimeChanged;

  const PrayerCard({
    super.key,
    required this.prayer,
    required this.onToggle,
    required this.onTimeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    prayer.name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Scheduled for ${prayer.time}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.access_time),
                  onPressed: () async {
                    final parts = prayer.time.split(':');
                    final hour = int.parse(parts[0]);
                    final minute = int.parse(parts[1]);

                    final TimeOfDay? newTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay(hour: hour, minute: minute),
                    );

                    if (newTime != null) {
                      final formattedTime = 
                        '${newTime.hour.toString().padLeft(2, '0')}:${newTime.minute.toString().padLeft(2, '0')}';
                      onTimeChanged(prayer.name, formattedTime);
                    }
                  },
                  tooltip: 'Edit Time',
                ),
                Switch(
                  value: prayer.isEnabled,
                  onChanged: (value) => onToggle(prayer.name, value),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
