import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:worktimer/features/stats/data/stats_provider.dart';
import 'package:worktimer/features/stats/view/widgets/category_bar_chart.dart';
import 'package:worktimer/features/stats/view/widgets/commission_summary.dart';
import 'package:worktimer/features/stats/view/widgets/condition_avg_table.dart';
import 'package:worktimer/features/stats/view/widgets/monthly_line_chart.dart';
import 'package:worktimer/features/stats/view/widgets/monthly_week_chart.dart';
import 'package:worktimer/features/stats/view/widgets/today_session_list.dart';
import 'package:worktimer/features/stats/view/widgets/weekday_bar_chart.dart';
import 'package:worktimer/features/stats/view/widgets/yearly_heatmap.dart';

export 'package:worktimer/features/stats/view/widgets/home_stats_today_view.dart';
export 'package:worktimer/features/stats/view/widgets/home_stats_week_view.dart';
export 'package:worktimer/features/stats/view/widgets/home_stats_month_view.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final period = ref.watch(statsPeriodProvider);
    final anchor = ref.watch(statsAnchorDateProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          Row(
            children: [
              Text('통계', style: Theme.of(context).textTheme.headlineMedium),
              const Spacer(),
              // ── 기간 이동 버튼 ──
              _NavBtn(
                icon: Icons.chevron_left_rounded,
                onTap: () {
                  ref.read(statsAnchorDateProvider.notifier).state =
                      statsShiftAnchor(period, anchor, -1);
                },
              ),
              const SizedBox(width: 4),
              Text(
                statsPeriodLabel(period, anchor),
                style: TextStyle(
                  fontSize: 13,
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(width: 4),
              _NavBtn(
                icon: Icons.chevron_right_rounded,
                onTap: statsIsAtOrBeyondNow(period, anchor)
                    ? null
                    : () {
                        ref.read(statsAnchorDateProvider.notifier).state =
                            statsShiftAnchor(period, anchor, 1);
                      },
              ),
              const SizedBox(width: 12),
              // ── 기간 탭 ──
              SegmentedButton<StatsPeriod>(
                segments: const [
                  ButtonSegment(value: StatsPeriod.today, label: Text('오늘')),
                  ButtonSegment(value: StatsPeriod.week, label: Text('주간')),
                  ButtonSegment(value: StatsPeriod.month, label: Text('월간')),
                ],
                selected: {period},
                onSelectionChanged: (s) {
                  // 탭 변경 시 anchor를 오늘로 리셋
                  final n = DateTime.now();
                  ref.read(statsAnchorDateProvider.notifier).state =
                      DateTime(n.year, n.month, n.day);
                  ref.read(statsPeriodProvider.notifier).state = s.first;
                },
                style: const ButtonStyle(
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 기간별 차별화 레이아웃
          if (period == StatsPeriod.today)
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: CategoryBarChart(period: period)),
                  const SizedBox(width: 12),
                  const Expanded(child: TodaySessionList()),
                ],
              ),
            )
          else if (period == StatsPeriod.week)
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: CategoryBarChart(period: period)),
                  const SizedBox(width: 12),
                  Expanded(child: WeekdayBarChart(period: period)),
                ],
              ),
            )
          else
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: CategoryBarChart(period: period)),
                  const SizedBox(width: 12),
                  const Expanded(child: MonthlyWeekChart()),
                ],
              ),
            ),

          const SizedBox(height: 16),
          const MonthlyLineChart(),
          const SizedBox(height: 16),

          const IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: CommissionSummary()),
                SizedBox(width: 12),
                Expanded(child: ConditionAvgTable()),
              ],
            ),
          ),

          const SizedBox(height: 16),
          const YearlyHeatmap(),
        ],
      ),
    );
  }
}

class _NavBtn extends StatelessWidget {
  const _NavBtn({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
              color: colorScheme.outline.withValues(alpha: 0.15)),
        ),
        child: Icon(
          icon,
          size: 15,
          color: enabled
              ? colorScheme.onSurface.withValues(alpha: 0.7)
              : colorScheme.onSurface.withValues(alpha: 0.2),
        ),
      ),
    );
  }
}
