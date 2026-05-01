import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:worktimer/core/constants.dart';
import 'package:worktimer/core/database/app_database.dart';
import 'package:worktimer/core/utils/time_utils.dart';
import 'package:worktimer/features/manage/data/category_provider.dart';
import 'package:worktimer/features/manage/data/shortcut_provider.dart';
import 'package:worktimer/features/timer/data/timer_provider.dart';

// 오늘 세션 합계: categoryId → 누적 초
final _todaySecsByCategory = StreamProvider<Map<int, int>>((ref) {
  return ref.watch(timerRepositoryProvider).watchTodaySessions().map(
        (sessions) => sessions.fold<Map<int, int>>({}, (map, s) {
          final dur = s.durationSec ?? 0;
          map[s.categoryId] = (map[s.categoryId] ?? 0) + dur;
          return map;
        }),
      );
});

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
          // ── 브랜드 ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
            child: Row(
              children: [
                Icon(Icons.timer_outlined, color: colorScheme.primary, size: 22),
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

          // ── 컴팩트 타이머 스트립 ──
          _CompactTimer(timerState: timerState),

          const Divider(height: 1),
          const SizedBox(height: 2),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 2),
            child: Row(
              children: [
                Text(
                  '카테고리',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface.withValues(alpha: 0.35),
                    letterSpacing: 1.2,
                  ),
                ),
              ],
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

// ── 컴팩트 타이머 스트립 ──────────────────────────────────────

class _CompactTimer extends ConsumerWidget {
  const _CompactTimer({required this.timerState});

  final TimerState timerState;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final isRunning = timerState.isRunning;
    final isPaused = timerState.isPaused;
    final isActive = isRunning || isPaused;

    final elapsed = TimeUtils.formatSeconds(timerState.elapsedSeconds);

    // 카테고리 이름 조회
    String categoryName = '카테고리 없음';
    if (isActive) {
      final catsAsync = ref.watch(visibleCategoriesProvider);
      catsAsync.whenData((cats) {
        final found = cats.where((c) => c.id == timerState.activeCategoryId);
        if (found.isNotEmpty) categoryName = found.first.name;
      });
    }

    final timerNotifier = ref.read(timerServiceProvider.notifier);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isRunning
            ? colorScheme.primary.withValues(alpha: 0.05)
            : colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isRunning
              ? colorScheme.primary.withValues(alpha: 0.4)
              : isPaused
                  ? colorScheme.primary.withValues(alpha: 0.2)
                  : colorScheme.outline.withValues(alpha: 0.2),
          width: isRunning ? 1.5 : 1.0,
        ),
        boxShadow: isRunning
            ? [
                BoxShadow(
                  color: colorScheme.primary.withValues(alpha: 0.12),
                  blurRadius: 8,
                  spreadRadius: 0,
                )
              ]
            : null,
      ),
      child: Row(
        children: [
          // 재생/일시정지 버튼
          GestureDetector(
            onTap: () {
              if (isRunning) {
                timerNotifier.pause();
              } else if (isPaused) {
                timerNotifier.resume();
              }
              // idle → 마지막 카테고리 선택은 CategoryItem에서 처리
            },
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: isActive
                    ? colorScheme.primary
                    : colorScheme.onSurface.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
                size: 14,
                color: isActive ? Colors.white : colorScheme.onSurface.withValues(alpha: 0.35),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isActive ? elapsed : '00:00:00',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isActive
                        ? colorScheme.onSurface
                        : colorScheme.onSurface.withValues(alpha: 0.3),
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  categoryName,
                  style: TextStyle(
                    fontSize: 11,
                    color: isActive
                        ? colorScheme.primary.withValues(alpha: 0.8)
                        : colorScheme.onSurface.withValues(alpha: 0.3),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── 섹션 레이블 ──────────────────────────────────────────────

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
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.35),
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

// ── 네비 아이템 ──────────────────────────────────────────────

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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
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
  List<Category>? _localOrder;

  List<Category> get _display => _localOrder ?? widget.categories;

  @override
  void didUpdateWidget(_CategoryList oldWidget) {
    super.didUpdateWidget(oldWidget);
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
    final todaySecs = ref.watch(_todaySecsByCategory).valueOrNull ?? {};

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
        final secs = todaySecs[cat.id] ?? 0;
        return RepaintBoundary(
          key: ValueKey(cat.id),
          child: _CategoryItem(
            category: cat,
            isActive: isActive,
            timerStatus: widget.timerStatus,
            index: index,
            isDragging: _isDragging,
            todaySeconds: secs,
          ),
        );
      },
      onReorderStart: (_) => setState(() => _isDragging = true),
      onReorder: (oldIndex, newIndex) async {
        if (newIndex > oldIndex) newIndex--;
        final reordered = [...cats];
        final item = reordered.removeAt(oldIndex);
        reordered.insert(newIndex, item);

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
    required this.todaySeconds,
  });

  final Category category;
  final bool isActive;
  final TimerStatus timerStatus;
  final int index;
  final bool isDragging;
  final int todaySeconds;

  @override
  Widget build(BuildContext context) {
    final color = _parseColor(category.color);
    final colorScheme = Theme.of(context).colorScheme;
    final miniTime = _formatMini(todaySeconds);

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
                if (miniTime.isNotEmpty)
                  Text(
                    miniTime,
                    style: TextStyle(
                      fontSize: 10.5,
                      fontFamily: 'monospace',
                      color: colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
                  ),
                const SizedBox(width: 4),
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
                          color: colorScheme.onSurface.withValues(alpha: 0.25)),
                    ),
                  ),
                ),
              ],
            ),
          ),
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

  String _formatMini(int secs) {
    if (secs < 60) return '';
    final h = secs ~/ 3600;
    final m = (secs % 3600) ~/ 60;
    if (h > 0) return '${h}h${m > 0 ? '${m}m' : ''}';
    return '${m}m';
  }

  Color _parseColor(String hex) {
    try {
      return Color(int.parse('FF${hex.replaceAll('#', '')}', radix: 16));
    } catch (_) {
      return Colors.blueAccent;
    }
  }
}

// ── 바로가기 섹션 ─────────────────────────────────────────────

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

// ── 시작/정지 버튼 ────────────────────────────────────────────

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

// ── 바로가기 하위 목록 ────────────────────────────────────────

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
                              color: colorScheme.onSurface.withValues(alpha: 0.6),
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
