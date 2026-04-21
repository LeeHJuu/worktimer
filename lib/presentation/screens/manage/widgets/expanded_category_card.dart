import 'package:flutter/material.dart';
import '../../../../data/database/app_database.dart';
import 'inline_shortcut_section.dart';

class ExpandedCategoryCard extends StatefulWidget {
  const ExpandedCategoryCard({
    super.key,
    required this.category,
    required this.index,
    required this.isDragging,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleVisible,
    required this.onResetSessions,
  });

  final Category category;
  final int index;
  final bool isDragging;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggleVisible;
  final VoidCallback onResetSessions;

  @override
  State<ExpandedCategoryCard> createState() => _ExpandedCategoryCardState();
}

class _ExpandedCategoryCardState extends State<ExpandedCategoryCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final cat = widget.category;
    final color = _parseColor(cat.color);
    final colorScheme = Theme.of(context).colorScheme;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: _isHovered
                ? color.withValues(alpha: 0.5)
                : colorScheme.outline.withValues(alpha: 0.18),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onDoubleTap: widget.onEdit,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                        border: Border.all(color: color, width: 1.5),
                      ),
                      child: Center(
                        child: Text(
                          cat.name.isNotEmpty
                              ? cat.name[0].toUpperCase()
                              : '?',
                          style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  cat.name,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: cat.isVisible
                                        ? colorScheme.onSurface
                                        : colorScheme.onSurface
                                            .withValues(alpha: 0.45),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (!cat.isVisible) ...[
                                const SizedBox(width: 6),
                                Icon(Icons.visibility_off_outlined,
                                    size: 13,
                                    color: colorScheme.onSurface
                                        .withValues(alpha: 0.3)),
                              ],
                            ],
                          ),
                          if (cat.goalIsActive && cat.goalTitle != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Row(
                                children: [
                                  const Icon(Icons.flag_outlined,
                                      size: 11, color: Colors.amber),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      cat.goalTitle!,
                                      style: const TextStyle(
                                          fontSize: 11, color: Colors.amber),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 120),
                      opacity: _isHovered ? 1.0 : 0.0,
                      child: IgnorePointer(
                        ignoring: !_isHovered,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CategoryIconBtn(
                              icon: cat.isVisible
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              tooltip:
                                  cat.isVisible ? '사이드바 숨기기' : '사이드바 표시',
                              onPressed: widget.onToggleVisible,
                            ),
                            CategoryIconBtn(
                              icon: Icons.history_toggle_off_outlined,
                              tooltip: '기록 초기화',
                              color: Colors.orangeAccent,
                              onPressed: widget.onResetSessions,
                            ),
                            CategoryIconBtn(
                              icon: Icons.edit_outlined,
                              tooltip: '편집',
                              color: colorScheme.primary,
                              onPressed: widget.onEdit,
                            ),
                            CategoryIconBtn(
                              icon: Icons.delete_outline,
                              tooltip: '삭제',
                              color: Colors.redAccent,
                              onPressed: widget.onDelete,
                            ),
                          ],
                        ),
                      ),
                    ),
                    ReorderableDragStartListener(
                      index: widget.index,
                      child: MouseRegion(
                        cursor: SystemMouseCursors.grab,
                        child: Padding(
                          padding: const EdgeInsets.all(6),
                          child: Icon(Icons.drag_indicator,
                              size: 16,
                              color: colorScheme.onSurface
                                  .withValues(alpha: 0.25)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (!widget.isDragging)
              InlineShortcutSection(categoryId: cat.id),
          ],
        ),
      ),
    );
  }

  Color _parseColor(String hex) {
    try {
      return Color(int.parse('FF${hex.replaceAll('#', '')}', radix: 16));
    } catch (_) {
      return Colors.blueAccent;
    }
  }
}

class CategoryIconBtn extends StatelessWidget {
  const CategoryIconBtn({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.color,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(icon,
              size: 15,
              color: color ?? colorScheme.onSurface.withValues(alpha: 0.65)),
        ),
      ),
    );
  }
}
