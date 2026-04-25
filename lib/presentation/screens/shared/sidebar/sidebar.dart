import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants.dart';
import '../../../../data/database/app_database.dart';
import '../../../../domain/services/timer_service.dart';
import '../../../providers/category_provider.dart';
import '../../../providers/shortcut_provider.dart';
import '../../../providers/timer_provider.dart';

class Sidebar extends ConsumerWidget {
  const Sidebar({
    super.key,
    required this.selectedIndex,
    required this.onTabSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onTabSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(visibleCategoriesProvider);
    final timerState = ref.watch(timerServiceProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: AppConstants.sidebarWidth,
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
            child: Row(
              children: [
                Icon(Icons.timer_outlined,
                    color: colorScheme.primary, size: 22),
                const SizedBox(width: 8),
                Text(
                  AppConstants.appName,
                  style: TextStyle(
                    color: colorScheme.primary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),
          const SizedBox(height: 4),
          _SectionLabel(label: '탐색'),

          _NavItem(
            icon: Icons.home_outlined,
            label: '홈',
            selected: selectedIndex == 0,
            onTap: () => onTabSelected(0),
          ),
          _NavItem(
            icon: Icons.folder_outlined,
            label: '관리',
            selected: selectedIndex == 1,
            onTap: () => onTabSelected(1),
          ),

          const SizedBox(height: 4),
          const Divider(height: 1),
          const SizedBox(height: 4),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text(
              '카테고리',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface.withValues(alpha: 0.4),
                letterSpacing: 0.8,
              ),
            ),
          ),

          Expanded(
            child: categoriesAsync.when(
              data: (categories) => _CategoryList(
                categories: categories,
                activeCategoryId: timerState.activeCategoryId,
                timerStatus: timerState.status,
              ),
              loading: () =>
                  const Center(child: CircularProgressIndicator(strokeWidth: 2)),
              error: (e, _) => Center(
                child: Text('오류: $e',
                    style: const TextStyle(color: Colors.red, fontSize: 12)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 2),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color:
              Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.35),
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: selected
                ? colorScheme.primary.withValues(alpha: 0.12)
                : Colors.transparent,
            border: Border(
              left: BorderSide(
                color: selected ? colorScheme.primary : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(icon,
                  size: 18,
                  color: selected
                      ? colorScheme.primary
                      : colorScheme.onSurface.withValues(alpha: 0.5)),
              const SizedBox(width: 10),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: selected
                      ? colorScheme.primary
                      : colorScheme.onSurface.withValues(alpha: 0.55),
                  fontWeight:
                      selected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── 카테고리 목록 (드래그) ────────────────────────────────────

class _CategoryList extends ConsumerStatefulWidget {
  const _CategoryList({
    required this.categories,
    required this.activeCategoryId,
    required this.timerStatus,
  });

  final List<Category> categories;
  final int? activeCategoryId;
  final TimerStatus timerStatus;

  @override
  ConsumerState<_CategoryList> createState() => _CategoryListState();
}

class _CategoryListState extends ConsumerState<_CategoryList> {
  bool _isDragging = false;

  // 낙관적 정렬 — DB 스트림 재발행 전까지 로컬 순서 유지
  List<Category>? _localOrder;

  List<Category> get _display => _localOrder ?? widget.categories;

  @override
  void didUpdateWidget(_CategoryList oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 스트림이 로컬 순서와 일치하면 로컬 상태 해제
    if (_localOrder != null && _sameOrder(widget.categories, _localOrder!)) {
      _localOrder = null;
    }
  }

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
    final cats = _display;

    if (cats.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          '카테고리를 추가하세요',
          style: TextStyle(
              fontSize: 12,
              color: colorScheme.onSurface.withValues(alpha: 0.3)),
        ),
      );
    }

    return ReorderableListView.builder(
      padding: const EdgeInsets.only(bottom: 8),
      buildDefaultDragHandles: false,
      proxyDecorator: (child, _, animation) => Material(
        color: Colors.transparent,
        elevation: 4,
        shadowColor: Colors.black26,
        child: child,
      ),
      itemCount: cats.length,
      itemBuilder: (context, index) {
        final cat = cats[index];
        final isActive = cat.id == widget.activeCategoryId;
        return RepaintBoundary(
          key: ValueKey(cat.id),
          child: _CategoryItem(
            category: cat,
            isActive: isActive,
            timerStatus: widget.timerStatus,
            index: index,
            isDragging: _isDragging,
          ),
        );
      },
      onReorderStart: (_) => setState(() => _isDragging = true),
      onReorder: (oldIndex, newIndex) async {
        if (newIndex > oldIndex) newIndex--;
        final reordered = [...cats];
        final item = reordered.removeAt(oldIndex);
        reordered.insert(newIndex, item);

        // 낙관적 업데이트 — 즉시 UI 반영, 깜박임 방지
        setState(() {
          _isDragging = false;
          _localOrder = reordered;
        });

        final orders = reordered
            .asMap()
            .entries
            .map((e) => (id: e.value.id, sortOrder: e.key))
            .toList();
        await ref.read(categoryRepositoryProvider).updateSortOrders(orders);
      },
    );
  }
}

// ── 카테고리 항목 ─────────────────────────────────────────────

class _CategoryItem extends StatelessWidget {
  const _CategoryItem({
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
    final color = _parseColor(category.color);
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
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle),
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
                _StartStopButton(
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
                      child: Icon(Icons.drag_indicator,
                          size: 16,
                          color:
                              colorScheme.onSurface.withValues(alpha: 0.25)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // 드래그 중에는 위젯 자체를 트리에서 제거 → provider watch 해제
          if (!isDragging)
            _SidebarShortcutSection(
              categoryId: category.id,
              categoryColor: color,
              timerStatus: timerStatus,
            ),
        ],
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

// 드래그 중 언마운트되어 provider watch가 자동 해제됨
class _SidebarShortcutSection extends ConsumerWidget {
  const _SidebarShortcutSection({
    required this.categoryId,
    required this.categoryColor,
    required this.timerStatus,
  });

  final int categoryId;
  final Color categoryColor;
  final TimerStatus timerStatus;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shortcutsAsync = ref.watch(shortcutsByCategoryProvider(categoryId));
    return shortcutsAsync.maybeWhen(
      data: (shortcuts) => shortcuts.isNotEmpty
          ? _ShortcutSubList(
              shortcuts: shortcuts,
              categoryId: categoryId,
              timerStatus: timerStatus,
              categoryColor: categoryColor,
            )
          : const SizedBox.shrink(),
      orElse: () => const SizedBox.shrink(),
    );
  }
}

// ── 시작/정지 버튼 ───────────────────────────────────────────

class _StartStopButton extends ConsumerWidget {
  const _StartStopButton({
    required this.category,
    required this.isActive,
    required this.timerStatus,
    required this.color,
  });

  final Category category;
  final bool isActive;
  final TimerStatus timerStatus;
  final Color color;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerNotifier = ref.read(timerServiceProvider.notifier);

    if (isActive && timerStatus == TimerStatus.running) {
      return _btn(
        color: Colors.redAccent,
        bg: Colors.red,
        icon: Icons.stop_rounded,
        label: '정지',
        onTap: () async => timerNotifier.stop(),
      );
    }
    if (isActive && timerStatus == TimerStatus.paused) {
      return _btn(
        color: Colors.orange,
        bg: Colors.orange,
        icon: Icons.play_arrow_rounded,
        label: '재개',
        onTap: () => timerNotifier.resume(),
      );
    }
    return _btn(
      color: color,
      bg: color,
      icon: Icons.play_arrow_rounded,
      label: '시작',
      onTap: () async {
        if (timerStatus != TimerStatus.idle && !isActive) {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('카테고리 전환'),
              content: Text('현재 타이머를 종료하고\n"${category.name}"으로 전환하시겠습니까?'),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('취소')),
                ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('전환')),
              ],
            ),
          );
          if (confirm == true) await timerNotifier.switchCategory(category.id);
        } else {
          await timerNotifier.start(category.id);
        }
      },
    );
  }

  Widget _btn({
    required Color color,
    required Color bg,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
          decoration: BoxDecoration(
            color: bg.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 13, color: color),
              const SizedBox(width: 3),
              Text(label, style: TextStyle(fontSize: 11, color: color)),
            ],
          ),
        ),
      ),
    );
  }
}

// ── 바로가기 하위 목록 ───────────────────────────────────────

class _ShortcutSubList extends ConsumerWidget {
  const _ShortcutSubList({
    required this.shortcuts,
    required this.categoryId,
    required this.timerStatus,
    required this.categoryColor,
  });

  final List<Shortcut> shortcuts;
  final int categoryId;
  final TimerStatus timerStatus;
  final Color categoryColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Divider(
            height: 1,
            color: categoryColor.withValues(alpha: 0.2),
            indent: 10,
            endIndent: 10),
        ...shortcuts.map((s) {
          final isWeb = s.type == 'web';
          return MouseRegion(
            cursor: SystemMouseCursors.click,
            child: InkWell(
              onTap: () async {
                final result = await ref
                    .read(timerServiceProvider.notifier)
                    .launchAndStart(s);
                if (!result.success && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(result.errorMessage ?? '실행 실패'),
                    backgroundColor: Colors.red.shade700,
                  ));
                }
              },
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(9),
                bottomRight: Radius.circular(9),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 6, 12, 6),
                child: Row(
                  children: [
                    Icon(
                      isWeb ? Icons.language_outlined : Icons.apps_outlined,
                      size: 13,
                      color: colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(s.name,
                          style: TextStyle(
                              fontSize: 12,
                              color: colorScheme.onSurface
                                  .withValues(alpha: 0.6),
                              overflow: TextOverflow.ellipsis)),
                    ),
                    Icon(Icons.open_in_new_rounded,
                        size: 11,
                        color: categoryColor.withValues(alpha: 0.6)),
                  ],
                ),
              ),
            ),
          );
        }),
        const SizedBox(height: 4),
      ],
    );
  }
}
