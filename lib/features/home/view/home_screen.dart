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
  late DateTime _selectedDay = _todayDate();
  late DateTime _selectedWeekStart = _thisWeekStart();

  static DateTime _todayDate() {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }

  static DateTime _thisWeekStart() {
    final n = DateTime.now();
    final monday = n.subtract(Duration(days: n.weekday - 1));
    return DateTime(monday.year, monday.month, monday.day);
  }

  bool get _canGoForwardDay => _selectedDay.isBefore(_todayDate());
  bool get _canGoForwardWeek => _selectedWeekStart.isBefore(_thisWeekStart());

  void _prevDay() =>
      setState(() => _selectedDay = _selectedDay.subtract(const Duration(days: 1)));
  void _nextDay() {
    if (!_canGoForwardDay) return;
    setState(() => _selectedDay = _selectedDay.add(const Duration(days: 1)));
  }

  void _prevWeek() => setState(
      () => _selectedWeekStart = _selectedWeekStart.subtract(const Duration(days: 7)));
  void _nextWeek() {
    if (!_canGoForwardWeek) return;
    setState(
        () => _selectedWeekStart = _selectedWeekStart.add(const Duration(days: 7)));
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < _kMobileBreakpoint;
        return isMobile
            ? _MobileLayout(
                isWeekly: _isWeekly,
                selectedDay: _selectedDay,
                selectedWeekStart: _selectedWeekStart,
                canGoForwardDay: _canGoForwardDay,
                canGoForwardWeek: _canGoForwardWeek,
                onToggle: (v) => setState(() => _isWeekly = v),
                onPrevDay: _prevDay,
                onNextDay: _nextDay,
                onPrevWeek: _prevWeek,
                onNextWeek: _nextWeek,
              )
            : _DesktopLayout(
                isWeekly: _isWeekly,
                selectedDay: _selectedDay,
                selectedWeekStart: _selectedWeekStart,
                canGoForwardDay: _canGoForwardDay,
                canGoForwardWeek: _canGoForwardWeek,
                onToggle: (v) => setState(() => _isWeekly = v),
                onPrevDay: _prevDay,
                onNextDay: _nextDay,
                onPrevWeek: _prevWeek,
                onNextWeek: _nextWeek,
              );
      },
    );
  }
}

// ── 데스크톱 레이아웃 ─────────────────────────────────────────

class _DesktopLayout extends ConsumerWidget {
  const _DesktopLayout({
    required this.isWeekly,
    required this.selectedDay,
    required this.selectedWeekStart,
    required this.canGoForwardDay,
    required this.canGoForwardWeek,
    required this.onToggle,
    required this.onPrevDay,
    required this.onNextDay,
    required this.onPrevWeek,
    required this.onNextWeek,
  });

  final bool isWeekly;
  final DateTime selectedDay;
  final DateTime selectedWeekStart;
  final bool canGoForwardDay;
  final bool canGoForwardWeek;
  final ValueChanged<bool> onToggle;
  final VoidCallback onPrevDay;
  final VoidCallback onNextDay;
  final VoidCallback onPrevWeek;
  final VoidCallback onNextWeek;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        // ── 헤더 ──
        _HomeHeader(
          isWeekly: isWeekly,
          onToggle: onToggle,
          selectedDay: selectedDay,
          selectedWeekStart: selectedWeekStart,
          canGoForward: isWeekly ? canGoForwardWeek : canGoForwardDay,
          onPrev: isWeekly ? onPrevWeek : onPrevDay,
          onNext: isWeekly ? onNextWeek : onNextDay,
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
                        ? WeeklyTimelinePanel(weekStart: selectedWeekStart)
                        : DailyTimelinePanel(date: selectedDay),
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
    required this.selectedDay,
    required this.selectedWeekStart,
    required this.canGoForwardDay,
    required this.canGoForwardWeek,
    required this.onToggle,
    required this.onPrevDay,
    required this.onNextDay,
    required this.onPrevWeek,
    required this.onNextWeek,
  });

  final bool isWeekly;
  final DateTime selectedDay;
  final DateTime selectedWeekStart;
  final bool canGoForwardDay;
  final bool canGoForwardWeek;
  final ValueChanged<bool> onToggle;
  final VoidCallback onPrevDay;
  final VoidCallback onNextDay;
  final VoidCallback onPrevWeek;
  final VoidCallback onNextWeek;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerState = ref.watch(timerServiceProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // 상단 헤더
          SliverToBoxAdapter(
            child: _HomeHeader(
              isWeekly: isWeekly,
              onToggle: onToggle,
              selectedDay: selectedDay,
              selectedWeekStart: selectedWeekStart,
              canGoForward: isWeekly ? canGoForwardWeek : canGoForwardDay,
              onPrev: isWeekly ? onPrevWeek : onPrevDay,
              onNext: isWeekly ? onNextWeek : onNextDay,
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
                    ? WeeklyTimelinePanel(weekStart: selectedWeekStart)
                    : DailyTimelinePanel(date: selectedDay),
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
    required this.selectedDay,
    required this.selectedWeekStart,
    required this.canGoForward,
    required this.onPrev,
    required this.onNext,
  });

  final bool isWeekly;
  final ValueChanged<bool> onToggle;
  final DateTime selectedDay;
  final DateTime selectedWeekStart;
  final bool canGoForward;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final thisWeekStart = () {
      final monday = now.subtract(Duration(days: now.weekday - 1));
      return DateTime(monday.year, monday.month, monday.day);
    }();

    final weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    final weekEnd = selectedWeekStart.add(const Duration(days: 6));

    final isCurrentDay = selectedDay == today;
    final isCurrentWeek = selectedWeekStart == thisWeekStart;

    final String title;
    final String subtitle;
    if (isWeekly) {
      title = isCurrentWeek
          ? '이번 주 흐름'
          : '${selectedWeekStart.month}/${selectedWeekStart.day} 주';
      subtitle =
          '${selectedWeekStart.month}/${selectedWeekStart.day} — ${weekEnd.month}/${weekEnd.day}';
    } else {
      final dayLabel = weekdays[selectedDay.weekday - 1];
      title = isCurrentDay ? '오늘의 흐름' : '${selectedDay.month}월 ${selectedDay.day}일';
      subtitle = '${selectedDay.month}월 ${selectedDay.day}일 $dayLabel요일';
    }

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
                      color: colorScheme.onSurface.withValues(alpha: 0.45))),
            ],
          ),
          const Spacer(),
          _NavArrowBtn(
            icon: Icons.chevron_left_rounded,
            onTap: onPrev,
            enabled: true,
          ),
          const SizedBox(width: 2),
          _NavArrowBtn(
            icon: Icons.chevron_right_rounded,
            onTap: canGoForward ? onNext : null,
            enabled: canGoForward,
          ),
          const SizedBox(width: 8),
          _SegmentToggle(isWeekly: isWeekly, onToggle: onToggle),
        ],
      ),
    );
  }
}

class _NavArrowBtn extends StatelessWidget {
  const _NavArrowBtn({
    required this.icon,
    required this.onTap,
    required this.enabled,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
              color: colorScheme.outline.withValues(alpha: 0.15)),
        ),
        child: Icon(
          icon,
          size: 16,
          color: enabled
              ? colorScheme.onSurface.withValues(alpha: 0.7)
              : colorScheme.onSurface.withValues(alpha: 0.2),
        ),
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
