import 'package:flutter/material.dart';
import '../../../../../core/utils/color_utils.dart';
import '../../../../../data/database/app_database.dart';

class CategoryListTile extends StatelessWidget {
  const CategoryListTile({
    super.key,
    required this.category,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleVisible,
    this.onResetSessions,
  });

  final Category category;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggleVisible;
  final VoidCallback? onResetSessions;

  @override
  Widget build(BuildContext context) {
    final color = parseHexColor(category.color);

    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          shape: BoxShape.circle,
          border: Border.all(color: color, width: 2),
        ),
        child: Center(
          child: Text(
            category.name.isNotEmpty
                ? category.name[0].toUpperCase()
                : '?',
            style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.bold),
          ),
        ),
      ),
      title: Text(
        category.name,
        style: TextStyle(
          color: category.isVisible
              ? Theme.of(context).colorScheme.onSurface
              : Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.35),
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: category.goalIsActive && category.goalTitle != null
          ? Row(
              children: [
                const Icon(Icons.flag_outlined,
                    size: 11, color: Colors.amber),
                const SizedBox(width: 4),
                Text(
                  category.goalTitle!,
                  style: const TextStyle(
                      fontSize: 11, color: Colors.amber),
                ),
              ],
            )
          : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 표시/숨김 토글
          IconButton(
            icon: Icon(
              category.isVisible
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              size: 18,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: category.isVisible ? 0.55 : 0.25),
            ),
            tooltip: category.isVisible ? '숨기기' : '표시',
            onPressed: onToggleVisible,
          ),
          // 편집
          IconButton(
            icon: Icon(Icons.edit_outlined,
                size: 18,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.55)),
            tooltip: '편집',
            onPressed: onEdit,
          ),
          // 기록 초기화
          if (onResetSessions != null)
            IconButton(
              icon: const Icon(Icons.history_toggle_off_outlined,
                  size: 18, color: Colors.orangeAccent),
              tooltip: '기록 초기화',
              onPressed: onResetSessions,
            ),
          // 삭제
          IconButton(
            icon: Icon(Icons.delete_outline,
                size: 18, color: Colors.red.shade300),
            tooltip: '삭제',
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }

}
