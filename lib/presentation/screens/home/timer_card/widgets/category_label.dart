import 'package:flutter/material.dart';
import '../../../../../data/database/app_database.dart';
import '../../../../providers/timer_provider.dart';

class CategoryLabel extends StatelessWidget {
  const CategoryLabel({
    super.key,
    required this.category,
    required this.color,
    required this.timerState,
  });

  final Category? category;
  final Color? color;
  final TimerState timerState;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (category == null) {
      return Text(
        '카테고리를 선택하여 타이머를 시작하세요',
        style: TextStyle(
          color: colorScheme.onSurface.withValues(alpha: 0.38),
          fontSize: 14,
        ),
        textAlign: TextAlign.center,
      );
    }

    final effectiveColor = color ?? Colors.blueAccent;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: effectiveColor,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            category!.name,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: effectiveColor,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (timerState.isPaused) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              '일시정지',
              style: TextStyle(
                fontSize: 11,
                color: Colors.orange,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
