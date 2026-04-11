import 'dart:math';
import 'package:flutter/material.dart';

class CircularCountdown extends StatefulWidget {
  final String prayerName;
  final String countdownText; // "HH:MM:SS"
  final String currentTime;
  final bool isMonitoring;
  final VoidCallback onToggle;

  const CircularCountdown({
    super.key,
    required this.prayerName,
    required this.countdownText,
    required this.currentTime,
    required this.isMonitoring,
    required this.onToggle,
  });

  @override
  State<CircularCountdown> createState() => _CircularCountdownState();
}

class _CircularCountdownState extends State<CircularCountdown>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    if (widget.isMonitoring) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(CircularCountdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isMonitoring && !_pulseController.isAnimating) {
      _pulseController.repeat(reverse: true);
    } else if (!widget.isMonitoring && _pulseController.isAnimating) {
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  /// Parse the countdown text like "Fajr in 02:15:30" into progress
  double _getProgress() {
    // Extract time portion
    final regex = RegExp(r'(\d{2}):(\d{2}):(\d{2})');
    final match = regex.firstMatch(widget.countdownText);
    if (match == null) return 0.0;

    final hours = int.parse(match.group(1)!);
    final minutes = int.parse(match.group(2)!);
    final seconds = int.parse(match.group(3)!);

    final totalSeconds = hours * 3600 + minutes * 60 + seconds;

    // Max time between prayers is ~24 hours
    // We normalize against ~12 hours (43200s) for visual arc effect
    // Clamp to 0.0–1.0 range
    final maxSeconds = 12 * 3600;
    final progress = 1.0 - (totalSeconds / maxSeconds).clamp(0.0, 1.0);
    return progress;
  }

  String _extractPrayerName() {
    // Extract prayer name from "Fajr in 02:15:30"
    if (widget.countdownText.contains(' in ')) {
      return widget.countdownText.split(' in ')[0];
    }
    return widget.prayerName;
  }

  String _extractTime() {
    final regex = RegExp(r'(\d{2}:\d{2}:\d{2})');
    final match = regex.firstMatch(widget.countdownText);
    return match?.group(0) ?? '--:--:--';
  }

  @override
  Widget build(BuildContext context) {
    final isActive = widget.isMonitoring;
    final progress = _getProgress();
    final prayerName = _extractPrayerName();
    final timeStr = _extractTime();

    // Colors
    final activeColor = const Color(0xFF10B981); // Emerald green
    final activeGlow = const Color(0xFF34D399);
    final inactiveColor = const Color(0xFF4B5563); // Gray
    final inactiveDark = const Color(0xFF374151);
    final ringColor = isActive ? activeColor : inactiveColor;
    final glowColor = isActive ? activeGlow : inactiveDark;

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        final scale = isActive ? _pulseAnimation.value : 1.0;

        return Transform.scale(
          scale: scale,
          child: SizedBox(
            width: 240,
            height: 240,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Outer glow effect
                if (isActive)
                  Container(
                    width: 240,
                    height: 240,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: glowColor.withOpacity(0.3),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                  ),

                // Background ring
                CustomPaint(
                  size: const Size(220, 220),
                  painter: _CircleRingPainter(
                    progress: 1.0,
                    color: Colors.white.withOpacity(0.08),
                    strokeWidth: 8,
                  ),
                ),

                // Tick marks
                CustomPaint(
                  size: const Size(220, 220),
                  painter: _TickMarksPainter(
                    activeColor: ringColor.withOpacity(0.6),
                    inactiveColor: Colors.white.withOpacity(0.1),
                    progress: isActive ? progress : 0.0,
                  ),
                ),

                // Progress ring
                CustomPaint(
                  size: const Size(200, 200),
                  painter: _CircleRingPainter(
                    progress: isActive ? progress : 0.0,
                    color: ringColor,
                    strokeWidth: 6,
                    hasGlow: isActive,
                    glowColor: glowColor,
                  ),
                ),

                // Inner glassmorphic circle
                Container(
                  width: 170,
                  height: 170,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        (isActive
                                ? const Color(0xFF064E3B)
                                : const Color(0xFF1F2937))
                            .withOpacity(0.5),
                        (isActive
                                ? const Color(0xFF065F46)
                                : const Color(0xFF111827))
                            .withOpacity(0.8),
                      ],
                    ),
                    border: Border.all(
                      color: ringColor.withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                ),

                // Center content
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Prayer name label
                    Text(
                      isActive ? 'NEXT PRAYER' : 'PAUSED',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 2,
                        color: ringColor.withOpacity(0.8),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isActive ? prayerName : '—',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white.withOpacity(isActive ? 0.9 : 0.4),
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Large countdown time
                    Text(
                      isActive ? timeStr : '--:--:--',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'monospace',
                        color: isActive ? Colors.white : Colors.white38,
                        letterSpacing: 2,
                        shadows: isActive
                            ? [
                                Shadow(
                                  color: glowColor.withOpacity(0.5),
                                  blurRadius: 10,
                                ),
                              ]
                            : null,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Start/Stop button
                    GestureDetector(
                      onTap: widget.onToggle,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: isActive
                                ? [
                                    const Color(0xFF10B981),
                                    const Color(0xFF059669),
                                  ]
                                : [
                                    const Color(0xFF6B7280),
                                    const Color(0xFF4B5563),
                                  ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: (isActive ? activeColor : inactiveColor)
                                  .withOpacity(0.4),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          isActive ? Icons.pause_rounded : Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Paints a circular arc for the progress ring
class _CircleRingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;
  final bool hasGlow;
  final Color? glowColor;

  _CircleRingPainter({
    required this.progress,
    required this.color,
    this.strokeWidth = 6,
    this.hasGlow = false,
    this.glowColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Glow layer
    if (hasGlow && progress > 0) {
      final glowPaint = Paint()
        ..color = (glowColor ?? color).withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth + 6
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -pi / 2,
        2 * pi * progress,
        false,
        glowPaint,
      );
    }

    // Main arc
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * progress,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _CircleRingPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}

/// Paints small tick marks around the circle
class _TickMarksPainter extends CustomPainter {
  final Color activeColor;
  final Color inactiveColor;
  final double progress;

  _TickMarksPainter({
    required this.activeColor,
    required this.inactiveColor,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const tickCount = 60;

    for (int i = 0; i < tickCount; i++) {
      final angle = (2 * pi * i / tickCount) - pi / 2;
      final tickProgress = i / tickCount;
      final isActive = tickProgress <= progress;

      final innerRadius = i % 5 == 0 ? radius - 14 : radius - 10;
      final outerRadius = radius - 4;

      final start = Offset(
        center.dx + innerRadius * cos(angle),
        center.dy + innerRadius * sin(angle),
      );
      final end = Offset(
        center.dx + outerRadius * cos(angle),
        center.dy + outerRadius * sin(angle),
      );

      final paint = Paint()
        ..color = isActive ? activeColor : inactiveColor
        ..strokeWidth = i % 5 == 0 ? 2.5 : 1.2
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(start, end, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _TickMarksPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
