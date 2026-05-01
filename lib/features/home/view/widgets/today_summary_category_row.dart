import 'package:flutter/material.dart';
import 'package:worktimer/core/utils/color_utils.dart';
import 'package:worktimer/core/utils/time_utils.dart';
import 'package:worktimer/core/database/app_database.dart';

class CategoryRow extends StatelessWidget {
  const CategoryRow({
    super.key,
    required this.category,
    required this.seconds,
  });

  final Category category;
  final int seconds;

  @override
  Widget build(BuildContext context) {
    final color = parseHexColor(category.color);
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              category.name,
              style: TextStyle(
                fontSize: 13,
                color: colorScheme.onSurface.withValues(alpha: 0.75),
              ),
            ),
          ),
          Text(
            TimeUtils.formatSecondsToHuman(seconds),
            style: TextStyle(
              fontSize: 13,
              color: colorScheme.onSurface.withValues(alpha: 0.55),
            ),
          ),
        ],
      ),
    );
  }
}
