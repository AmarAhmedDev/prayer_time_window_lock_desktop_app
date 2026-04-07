import 'package:flutter/material.dart';

class CountdownWidget extends StatelessWidget {
  final String title;
  final String countdown;
  final Color? color;

  const CountdownWidget({
    super.key,
    required this.title,
    required this.countdown,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color ?? Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              countdown,
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
