import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants.dart';
import '../../../data/database/app_database.dart';
import '../../../domain/services/shortcut_launcher_service.dart';
import '../../providers/category_provider.dart';
import '../../providers/shortcut_provider.dart';
import '../../providers/timer_provider.dart';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final sidebarBg = isDark ? const Color(0xFF0F0F23) : const Color(0xFFF0EEFF);

    return Container(
      width: AppConstants.sidebarWidth,
      color: sidebarBg,
      child: Column(
        children: [
          // 앱 타이틀
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

          // 네비게이션 항목
          _NavItem(
            icon: Icons.home_outlined,
            label: '홈',
            selected: selectedIndex == 0,
            onTap: () => onTabSelected(0),
          ),
          _NavItem(
            icon: Icons.bar_chart_outlined,
            label: '통계',
            selected: selectedIndex == 1,
            onTap: () => onTabSelected(1),
          ),
          _NavItem(
            icon: Icons.folder_outlined,
            label: '관리',
            selected: selectedIndex == 2,
            onTap: () => onTabSelected(2),
          ),
          _NavItem(
            icon: Icons.settings_outlined,
            label: '설정',
            selected: selectedIndex == 3,
            onTap: () => onTabSelected(3),
          ),

          const Divider(height: 1),
          const SizedBox(height: 8),

          // 카테고리 섹션 헤더
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                Text(
                  '카테고리',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface.withValues(alpha: 0.4),
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),

          // 카테고리 목록
          Expanded(
            child: categoriesAsync.when(
              data: (categories) => _CategoryList(
                categories: categories,
                activeCategoryId: timerState.activeCategoryId,
                timerStatus: timerState.status,
              ),
              loading: () => const Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
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

// ── 네비게이션 항목 ──────────────────────────────────────────

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
    final onSurface = colorScheme.onSurface;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: selected
                ? colorScheme.primary.withValues(alpha: 0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(icon,
                  size: 18,
                  color: selected
                      ? colorScheme.primary
                      : onSurface.withValues(alpha: 0.5)),
              const SizedBox(width: 10),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: selected
                      ? colorScheme.primary
                      : onSurface.withValues(alpha: 0.5),
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

// ── 카테고리 목록 (드래그 앤 드롭) ──────────────────────────

class _CategoryList extends ConsumerWidget {
  const _CategoryList({
    required this.categories,
    required this.activeCategoryId,
    required this.timerStatus,
  });

  final List<Category> categories;
  final int? activeCategoryId;
  final TimerStatus timerStatus;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    if (categories.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          '카테고리를 추가하세요',
          style: TextStyle(
            fontSize: 12,
            color: colorScheme.onSurface.withValues(alpha: 0.3),
          ),
        ),
      );
    }

    return ReorderableListView.builder(
      padding: const EdgeInsets.only(bottom: 8),
      buildDefaultDragHandles: false,
      proxyDecorator: (child, index, animation) => Material(
        color: Colors.transparent,
        child: child,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final cat = categories[index];
        final isActive = cat.id == activeCategoryId;
        return _CategoryItem(
          key: ValueKey(cat.id),
          category: cat,
          isActive: isActive,
          timerStatus: timerStatus,
          index: index,
        );
      },
      onReorder: (oldIndex, newIndex) async {
        if (newIndex > oldIndex) newIndex--;
        final reordered = [...categories];
        final item = reordered.removeAt(oldIndex);
        reordered.insert(newIndex, item);

        final orders = reordered
            .asMap()
            .entries
            .map((e) => (id: e.value.id, sortOrder: e.key))
            .toList();

        await ref
            .read(categoryRepositoryProvider)
            .updateSortOrders(orders);
      },
    );
  }
}

// ── 카테고리 항목 ─────────────────────────────────────────────
//
// 레이아웃:
//   Column(
//     Row(● 카테고리명, [▶시작/■정지], ⠿드래그핸들)
//     Divider
//     Row(아이콘, 이름, ↗)  ← 반복
//   )

class _CategoryItem extends ConsumerWidget {
  const _CategoryItem({
    super.key,
    required this.category,
    required this.isActive,
    required this.timerStatus,
    required this.index,
  });

  final Category category;
  final bool isActive;
  final TimerStatus timerStatus;
  final int index;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = _parseColor(category.color);
    final colorScheme = Theme.of(context).colorScheme;
    final onSurface = colorScheme.onSurface;
    final shortcutsAsync =
        ref.watch(shortcutsByCategoryProvider(category.id));

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
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 카테고리 헤더: ● 이름 | [▶시작/■정지] | ⠿ 드래그 핸들
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 6, 8),
            child: Row(
              children: [
                // 색상 인디케이터
                Container(
                  width: 10,
                  height: 10,
                  decoration:
                      BoxDecoration(color: color, shape: BoxShape.circle),
                ),
                const SizedBox(width: 8),
                // 카테고리 이름
                Expanded(
                  child: Text(
                    category.name,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight:
                          isActive ? FontWeight.w600 : FontWeight.w500,
                      color: isActive
                          ? color
                          : onSurface.withValues(alpha: 0.85),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                // ▶ 시작 / ■ 정지 버튼
                _StartStopButton(
                  category: category,
                  isActive: isActive,
                  timerStatus: timerStatus,
                  color: color,
                ),
                const SizedBox(width: 4),
                // 드래그 핸들
                ReorderableDragStartListener(
                  index: index,
                  child: MouseRegion(
                    cursor: SystemMouseCursors.grab,
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        Icons.drag_indicator,
                        size: 16,
                        color: onSurface.withValues(alpha: 0.25),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 바로가기 목록 (있을 때만 구분선 + 항목 표시)
          shortcutsAsync.maybeWhen(
            data: (shortcuts) => shortcuts.isNotEmpty
                ? _ShortcutSubList(
                    shortcuts: shortcuts,
                    categoryId: category.id,
                    timerStatus: timerStatus,
                    categoryColor: color,
                  )
                : const SizedBox.shrink(),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Color _parseColor(String hex) {
    try {
      final h = hex.replaceAll('#', '');
      return Color(int.parse('FF$h', radix: 16));
    } catch (_) {
      return Colors.blueAccent;
    }
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
      // 실행 중인 활성 카테고리 — 정지 버튼
      return MouseRegion(
        cursor: SystemMouseCursors.click,
        child: InkWell(
          onTap: () async {
            await timerNotifier.stop();
          },
          borderRadius: BorderRadius.circular(6),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.stop_rounded, size: 13, color: Colors.redAccent),
                SizedBox(width: 3),
                Text('정지',
                    style: TextStyle(fontSize: 11, color: Colors.redAccent)),
              ],
            ),
          ),
        ),
      );
    }

    if (isActive && timerStatus == TimerStatus.paused) {
      // 일시정지 중인 활성 카테고리 — 재개 버튼
      return MouseRegion(
        cursor: SystemMouseCursors.click,
        child: InkWell(
          onTap: () => timerNotifier.resume(),
          borderRadius: BorderRadius.circular(6),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.play_arrow_rounded,
                    size: 13, color: Colors.orange),
                SizedBox(width: 3),
                Text('재개',
                    style: TextStyle(fontSize: 11, color: Colors.orange)),
              ],
            ),
          ),
        ),
      );
    }

    // 비활성 카테고리 — 시작 버튼
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: InkWell(
        onTap: () async {
          if (timerStatus != TimerStatus.idle && !isActive) {
            // 다른 카테고리 타이머 진행 중/일시정지 → 전환 확인
            final confirm = await showDialog<bool>(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('카테고리 전환'),
                content: Text(
                    '현재 타이머를 종료하고\n"${category.name}"으로 전환하시겠습니까?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('취소'),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('전환'),
                  ),
                ],
              ),
            );
            if (confirm == true) {
              await timerNotifier.switchCategory(category.id);
            }
          } else {
            await timerNotifier.start(category.id);
          }
        },
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.play_arrow_rounded, size: 13, color: color),
              const SizedBox(width: 3),
              Text('시작', style: TextStyle(fontSize: 11, color: color)),
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
    final launcher = const ShortcutLauncherService();
    final colorScheme = Theme.of(context).colorScheme;
    final onSurface = colorScheme.onSurface;

    return Column(
      children: [
        Divider(
          height: 1,
          color: categoryColor.withValues(alpha: 0.2),
          indent: 10,
          endIndent: 10,
        ),
        ...shortcuts.map((s) {
          final isWeb = s.type == 'web';
          return MouseRegion(
            cursor: SystemMouseCursors.click,
            child: InkWell(
              onTap: () async {
                final timerNotifier = ref.read(timerServiceProvider.notifier);
                final currentState = ref.read(timerServiceProvider);

                if (currentState.isIdle) {
                  // idle: 새 세션 시작
                  await timerNotifier.start(categoryId);
                } else if (currentState.isPaused &&
                    currentState.activeCategoryId == categoryId) {
                  // 같은 카테고리 일시정지 → 재개
                  timerNotifier.resume();
                } else if (currentState.activeCategoryId != categoryId) {
                  // 다른 카테고리 → 전환 확인
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('카테고리 전환'),
                      content: const Text('현재 타이머를 종료하고 이 카테고리로 전환할까요?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('취소'),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('전환'),
                        ),
                      ],
                    ),
                  );
                  if (confirm != true) return;
                  await timerNotifier.switchCategory(categoryId);
                }
                // else: 같은 카테고리 실행 중 → 타이머 유지하고 바로가기만 실행

                final result = await launcher.launch(s);
                if (!result.success && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(result.errorMessage ?? '실행 실패'),
                      backgroundColor: Colors.red.shade700,
                    ),
                  );
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
                      isWeb
                          ? Icons.language_outlined
                          : Icons.apps_outlined,
                      size: 13,
                      color: onSurface.withValues(alpha: 0.4),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        s.name,
                        style: TextStyle(
                          fontSize: 12,
                          color: onSurface.withValues(alpha: 0.6),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.open_in_new_rounded,
                      size: 11,
                      color: categoryColor.withValues(alpha: 0.6),
                    ),
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
