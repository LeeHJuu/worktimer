import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/time_utils.dart';
import '../../../data/database/app_database.dart';
import '../../providers/category_provider.dart';
import '../../providers/stats_provider.dart';
import '../../providers/timer_provider.dart';
import '../stats/widgets/home_stats_views.dart';
import 'widgets/condition_card.dart';
import 'widgets/goal_progress_card.dart';
import 'widgets/overload_banner.dart';
import 'widgets/session_memo_card.dart';
import 'widgets/timer_card.dart';

// 오늘 집중 세션 스트림 Provider
final _todaySessionsProvider = StreamProvider<List<TimerSession>>((ref) {
  return ref.watch(timerRepositoryProvider).watchTodaySessions();
});

/// Wrap 자식 패널의 공통 너비 (자연 줄바꿈 기준)
const double _kPanelWidth = 380;

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todaySessionsAsync = ref.watch(_todaySessionsProvider);

    final timerPanel = _HomePanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [TimerCard()],
      ),
    );

    final summaryPanel = _HomePanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TodaySummaryCard(sessionsAsync: todaySessionsAsync),
          SessionMemoCard(),
        ],
      ),
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('홈', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 14),
          // 타이머 / 오늘 요약 / 오늘 세션 기록 — 너비에 따라 자동 줄바꿈
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [timerPanel, summaryPanel],
          ),
          const SizedBox(height: 20),
          Divider(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          ),
          const SizedBox(height: 14),
          // 통계 / 과부하 / 목표 / 컨디션 — 세로 스택
          const _CompactStatsPanel(),
          const SizedBox(height: 14),
          const OverloadBanner(),
          const GoalProgressCard(),
          const SizedBox(height: 14),
          const ConditionCard(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _HomePanel extends StatelessWidget {
  const _HomePanel({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: _kPanelWidth, child: child);
  }
}

// ── 인라인 통계 패널 ──────────────────────────────────────────

class _CompactStatsPanel extends ConsumerWidget {
  const _CompactStatsPanel();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final period = ref.watch(statsPeriodProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 기간 선택 헤더
        Row(
          children: [
            Text('통계', style: Theme.of(context).textTheme.titleLarge),
            const Spacer(),
            SegmentedButton<StatsPeriod>(
              segments: const [
                ButtonSegment(value: StatsPeriod.today, label: Text('오늘')),
                ButtonSegment(value: StatsPeriod.week, label: Text('주간')),
                ButtonSegment(value: StatsPeriod.month, label: Text('월간')),
              ],
              selected: {period},
              onSelectionChanged: (s) =>
                  ref.read(statsPeriodProvider.notifier).state = s.first,
              style: const ButtonStyle(
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        // 기간별 차트 위젯들
        if (period == StatsPeriod.today)
          const HomeStatsTodayView()
        else if (period == StatsPeriod.week)
          const HomeStatsWeekView()
        else
          const HomeStatsMonthView(),
      ],
    );
  }
}

// ── 오늘 요약 카드 ────────────────────────────

class _TodaySummaryCard extends ConsumerWidget {
  const _TodaySummaryCard({required this.sessionsAsync});

  final AsyncValue<List<TimerSession>> sessionsAsync;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.today_outlined,
                  size: 18,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text('오늘 요약', style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 14),
            sessionsAsync.when(
              data: (sessions) {
                if (sessions.isEmpty) {
                  return Text(
                    '오늘 기록된 세션이 없습니다.',
                    style: Theme.of(context).textTheme.bodySmall,
                  );
                }

                final categorySeconds = <int, int>{};
                for (final s in sessions) {
                  categorySeconds[s.categoryId] =
                      (categorySeconds[s.categoryId] ?? 0) +
                      (s.durationSec ?? 0);
                }
                final totalSec = categorySeconds.values.fold<int>(
                  0,
                  (a, b) => a + b,
                );

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '총 집중',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const Spacer(),
                        Text(
                          TimeUtils.formatSecondsToHuman(totalSec),
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Divider(height: 1, color: colorScheme.outlineVariant),
                    const SizedBox(height: 10),
                    ...categoriesAsync.valueOrNull
                            ?.where((c) => categorySeconds.containsKey(c.id))
                            .map(
                              (c) => _CategoryRow(
                                category: c,
                                seconds: categorySeconds[c.id] ?? 0,
                              ),
                            ) ??
                        [],
                  ],
                );
              },
              loading: () => const LinearProgressIndicator(),
              error: (e, _) =>
                  Text('오류: $e', style: const TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({required this.category, required this.seconds});

  final Category category;
  final int seconds;

  @override
  Widget build(BuildContext context) {
    final color = _parseColor(category.color);
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

  Color _parseColor(String hex) {
    try {
      final h = hex.replaceAll('#', '');
      return Color(int.parse('FF$h', radix: 16));
    } catch (_) {
      return Colors.blueAccent;
    }
  }
}
