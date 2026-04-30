import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:worktimer/core/database/app_database.dart';
import 'package:worktimer/features/manage/data/manage_controller.dart';
import 'package:worktimer/features/manage/view/widgets/expanded_category_card.dart';

class CategoryListPanel extends ConsumerStatefulWidget {
  const CategoryListPanel({
    super.key,
    required this.categoriesAsync,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleVisible,
    required this.onResetSessions,
    required this.onResetAll,
  });

  final AsyncValue<List<Category>> categoriesAsync;
  final VoidCallback onAdd;
  final ValueChanged<Category> onEdit;
  final ValueChanged<Category> onDelete;
  final ValueChanged<Category> onToggleVisible;
  final ValueChanged<Category> onResetSessions;
  final VoidCallback onResetAll;

  @override
  ConsumerState<CategoryListPanel> createState() => _CategoryListPanelState();
}

class _CategoryListPanelState extends ConsumerState<CategoryListPanel> {
  List<Category>? _localOrder;
  bool _isDragging = false;

  bool _sameOrder(List<Category> a, List<Category> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i].id != b[i].id) return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 12, 12),
          child: Row(
            children: [
              Text('관리', style: Theme.of(context).textTheme.headlineMedium),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.delete_sweep_outlined,
                    size: 18, color: Colors.redAccent),
                tooltip: '전체 초기화',
                onPressed: widget.onResetAll,
              ),
              FilledButton.icon(
                onPressed: widget.onAdd,
                icon: const Icon(Icons.add, size: 16),
                label: const Text('카테고리 추가'),
                style: FilledButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
        ),
        Divider(height: 1, color: colorScheme.outline.withValues(alpha: 0.2)),
        widget.categoriesAsync.when(
          data: (categories) {
            if (_localOrder != null &&
                _sameOrder(categories, _localOrder!)) {
              _localOrder = null;
            }
            final cats = _localOrder ?? categories;

            if (cats.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(32),
                child: Center(
                  child: Text(
                    '카테고리를 추가하세요.',
                    style: TextStyle(
                        color: colorScheme.onSurface.withValues(alpha: 0.38)),
                  ),
                ),
              );
            }
            return ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
              buildDefaultDragHandles: false,
              proxyDecorator: (child, _, __) => Material(
                color: Colors.transparent,
                elevation: 6,
                shadowColor: Colors.black38,
                child: child,
              ),
              itemCount: cats.length,
              itemBuilder: (context, index) {
                final cat = cats[index];
                return RepaintBoundary(
                  key: ValueKey(cat.id),
                  child: ExpandedCategoryCard(
                    category: cat,
                    index: index,
                    isDragging: _isDragging,
                    onEdit: () => widget.onEdit(cat),
                    onDelete: () => widget.onDelete(cat),
                    onToggleVisible: () => widget.onToggleVisible(cat),
                    onResetSessions: () => widget.onResetSessions(cat),
                  ),
                );
              },
              onReorderStart: (_) => setState(() => _isDragging = true),
              onReorderEnd: (_) => setState(() => _isDragging = false),
              onReorder: (oldIndex, newIndex) async {
                if (newIndex > oldIndex) newIndex--;
                final reordered = [...cats];
                final item = reordered.removeAt(oldIndex);
                reordered.insert(newIndex, item);
                setState(() {
                  _isDragging = false;
                  _localOrder = reordered;
                });
                await ref
                    .read(manageControllerProvider)
                    .reorderCategories(reordered);
              },
            );
          },
          loading: () => const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: CircularProgressIndicator())),
          error: (e, _) => Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                  child: Text('오류: $e',
                      style: const TextStyle(color: Colors.red)))),
        ),
      ],
    );
  }
}
