import 'package:flutter/material.dart';
import '../../../../../core/utils/time_utils.dart';
import '../../../../providers/timer_provider.dart';

class ElapsedTimeDisplay extends StatelessWidget {
  const ElapsedTimeDisplay({
    super.key,
    required this.seconds,
    required this.color,
    required this.status,
  });

  final int seconds;
  final Color? color;
  final TimerStatus status;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final displayColor = status == TimerStatus.idle
        ? colorScheme.onSurface.withValues(alpha: 0.12)
        : status == TimerStatus.paused
            ? Colors.orange.withValues(alpha: 0.7)
            : (color ?? Colors.blueAccent);

    return Text(
      TimeUtils.formatSeconds(seconds),
      style: TextStyle(
        fontSize: 56,
        fontWeight: FontWeight.w200,
        color: displayColor,
        fontFeatures: const [FontFeature.tabularFigures()],
        letterSpacing: 2,
      ),
    );
  }
}
