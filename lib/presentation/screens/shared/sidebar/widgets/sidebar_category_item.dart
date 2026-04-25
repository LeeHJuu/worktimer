import 'package:flutter/material.dart';
import '../../../../../core/utils/color_utils.dart';
import '../../../../../data/database/app_database.dart';
import '../../../../providers/timer_provider.dart';
import 'sidebar_shortcut_section.dart';
import 'start_stop_button.dart';

class SidebarCategoryItem extends StatelessWidget {
  const SidebarCategoryItem({
    super.key,
    required this.category,
    required this.isActive,
    required this.timerStatus,
    required this.index,
    required this.isDragging,
  });

  final Category category;
  final bool isActive;
  final TimerStatus timerStatus;
  final int index;
  final bool isDragging;

  @override
  Widget build(BuildContext context) {
    final color = parseHexColor(category.color);
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isActive
            ? color.withValues(alpha: 0.1)
            : colorScheme.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isActive
              ? color.withValues(alpha: 0.4)
              : colorScheme.outline.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration:
                      BoxDecoration(color: color, shape: BoxShape.circle),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    category.name,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                      color: isActive
                          ? color
                          : colorScheme.onSurface.withValues(alpha: 0.85),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                StartStopButton(
                  category: category,
                  isActive: isActive,
                  timerStatus: timerStatus,
                  color: color,
                ),
                const SizedBox(width: 4),
                ReorderableDragStartListener(
                  index: index,
                  child: MouseRegion(
                    cursor: SystemMouseCursors.grab,
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        Icons.drag_indicator,
                        size: 16,
                        color: colorScheme.onSurface.withValues(alpha: 0.25),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (!isDragging)
            SidebarShortcutSection(
              categoryId: category.id,
              categoryColor: color,
              timerStatus: timerStatus,
            ),
        ],
      ),
    );
  }
}
