import 'package:flutter/material.dart';

class ModeSwitch extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final IconData? icon;

  const ModeSwitch({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }
}
