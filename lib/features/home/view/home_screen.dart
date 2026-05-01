import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:worktimer/features/home/view/timeline_panel.dart';
import 'package:worktimer/features/home/view/todo_panel.dart';
import 'package:worktimer/features/timer/data/timer_provider.dart';
import 'package:worktimer/features/timer/data/timer_service.dart';
import 'package:worktimer/features/manage/data/category_provider.dart';
import 'package:worktimer/core/utils/color_utils.dart';

const _kMobileBreakpoint = 700.0;

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _isWeekly = false;

  DateTime get _weekStart {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    return DateTime(monday.year, monday.month, monday.day);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < _kMobileBreakpoint;
        return isMobile
            ? _MobileLayout(
                isWeekly: _isWeekly,
                weekStart: _weekStart,
                onToggle: (v) => setState(() => _isWeekly = v),
              )
            : _DesktopLayout(
                isWeekly: _isWeekly,
                weekStart: _weekStart,
                onToggle: (v) => setState(() => _isWeekly = v),
              );
      },
    );
  }
}

// ── 데스크톱 레이아웃 ─────────────────────────────────────────

class _DesktopLayout extends ConsumerWidget {
  const _DesktopLayout({
    required this.isWeekly,
    required this.weekStart,
    required this.onToggle,
  });

  final bool isWeekly;
  final DateTime weekStart;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final now = DateTime.now();

    return Column(
      children: [
        // ── 헤더 ──
        _HomeHeader(
          isWeekly: isWeekly,
          onToggle: onToggle,
          weekStart: weekStart,
          now: now,
        ),
        Divider(height: 1, color: colorScheme.outline.withValues(alpha: 0.12)),

        // ── 본문 ──
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 타임라인 (1.6 비율)
                Expanded(
                  flex: 16,
                  child: _PanelCard(
                    child: isWeekly
                        ? WeeklyTimelinePanel(weekStart: weekStart)
                        : const DailyTimelinePanel(),
                  ),
                ),
                const SizedBox(width: 14),
                // TODO 패널 (1 비율)
                Expanded(
                  flex: 10,
                  child: _PanelCard(
                    child: TodoPanel(isWeekly: isWeekly),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── 모바일 레이아웃 ───────────────────────────────────────────

class _MobileLayout extends ConsumerWidget {
  const _MobileLayout({
    required this.isWeekly,
    required this.weekStart,
    required this.onToggle,
  });

  final bool isWeekly;
  final DateTime weekStart;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerState = ref.watch(timerServiceProvider);
    final now = DateTime.now();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // 상단 헤더
          SliverToBoxAdapter(
            child: _HomeHeader(
              isWeekly: isWeekly,
              onToggle: onToggle,
              weekStart: weekStart,
              now: now,
            ),
          ),
          // 진행 중 세션 카드 (모바일 상단 고정)
          if (timerState.isRunning || timerState.isPaused)
            SliverToBoxAdapter(
              child: _MobileRunningCard(timerState: timerState),
            ),
          // 세그먼트 토글
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: _SegmentToggle(
                  isWeekly: isWeekly, onToggle: onToggle),
            ),
          ),
          // 타임라인
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _PanelCard(
                child: isWeekly
                    ? WeeklyTimelinePanel(weekStart: weekStart)
                    : const DailyTimelinePanel(),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 12)),
          // TODO 패널
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _PanelCard(child: TodoPanel(isWeekly: isWeekly)),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
      // FAB: 빠른 카테고리 시작
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showQuickStart(context, ref),
        child: const Icon(Icons.play_arrow_rounded),
      ),
    );
  }

  void _showQuickStart(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.read(visibleCategoriesProvider);
    categoriesAsync.whenData((categories) {
      showModalBottomSheet(
        context: context,
        builder: (ctx) => _QuickStartSheet(categories: categories),
      );
    });
  }
}

// ── 모바일 진행 중 카드 ────────────────────────────────────────

class _MobileRunningCard extends ConsumerWidget {
  const _MobileRunningCard({required this.timerState});
  final TimerState timerState;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final categoriesAsync = ref.watch(visibleCategoriesProvider);
    String catName = '';
    Color catColor = colorScheme.primary;
    categoriesAsync.whenData((cats) {
      final found =
          cats.where((c) => c.id == timerState.activeCategoryId);
      if (found.isNotEmpty) {
        catName = found.first.name;
        catColor = parseHexColor(found.first.color);
      }
    });

    final elapsed = timerState.elapsedSeconds;
    final h = elapsed ~/ 3600;
    final m = (elapsed % 3600) ~/ 60;
    final s = elapsed % 60;
    final timeStr =
        '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [catColor, catColor.withValues(alpha: 0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              if (timerState.isRunning) {
                ref.read(timerServiceProvider.notifier).pause();
              } else {
                ref.read(timerServiceProvider.notifier).resume();
              }
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                timerState.isRunning
                    ? Icons.pause_rounded
                    : Icons.play_arrow_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '진행 중',
                  style: TextStyle(
                      fontSize: 10.5,
                      color: Colors.white.withValues(alpha: 0.8),
                      letterSpacing: 0.5),
                ),
                Text(
                  catName,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white),
                ),
              ],
            ),
          ),
          Text(
            timeStr,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ── 빠른 시작 바텀시트 ────────────────────────────────────────

class _QuickStartSheet extends ConsumerWidget {
  const _QuickStartSheet({required this.categories});
  final List categories;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('빠른 시작',
                style:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final cat in categories)
                  ActionChip(
                    avatar: CircleAvatar(
                      backgroundColor: parseHexColor(cat.color),
                      radius: 6,
                    ),
                    label: Text(cat.name),
                    onPressed: () {
                      ref
                          .read(timerServiceProvider.notifier)
                          .start(cat.id);
                      Navigator.pop(context);
                    },
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── 홈 헤더 ──────────────────────────────────────────────────

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({
    required this.isWeekly,
    required this.onToggle,
    required this.weekStart,
    required this.now,
  });

  final bool isWeekly;
  final ValueChanged<bool> onToggle;
  final DateTime weekStart;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    final dayLabel = weekdays[now.weekday - 1];
    final weekEnd = weekStart.add(const Duration(days: 6));

    final title = isWeekly ? '이번 주 흐름' : '오늘의 흐름';
    final subtitle = isWeekly
        ? '${weekStart.month}/${weekStart.day} — ${weekEnd.month}/${weekEnd.day}'
        : '${now.month}월 ${now.day}일 $dayLabel요일';

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(subtitle,
                  style: TextStyle(
                      fontSize: 12,
                      color:
                          colorScheme.onSurface.withValues(alpha: 0.45))),
            ],
          ),
          const Spacer(),
          _SegmentToggle(isWeekly: isWeekly, onToggle: onToggle),
        ],
      ),
    );
  }
}

// ── 세그먼트 토글 ─────────────────────────────────────────────

class _SegmentToggle extends StatelessWidget {
  const _SegmentToggle({required this.isWeekly, required this.onToggle});
  final bool isWeekly;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SegBtn(label: '일간', active: !isWeekly, onTap: () => onToggle(false)),
          _SegBtn(label: '주간', active: isWeekly, onTap: () => onToggle(true)),
        ],
      ),
    );
  }
}

class _SegBtn extends StatelessWidget {
  const _SegBtn({
    required this.label,
    required this.active,
    required this.onTap,
  });
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  )
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: active ? FontWeight.w500 : FontWeight.normal,
            color: active
                ? colorScheme.onSurface
                : colorScheme.onSurface.withValues(alpha: 0.55),
          ),
        ),
      ),
    );
  }
}

// ── 패널 카드 컨테이너 ────────────────────────────────────────

class _PanelCard extends StatelessWidget {
  const _PanelCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: child,
    );
  }
}
