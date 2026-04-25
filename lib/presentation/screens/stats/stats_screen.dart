import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/stats_provider.dart';
import 'category_bar_chart.dart';
import 'commission_summary.dart';
import 'condition_avg_table/condition_avg_table.dart';
import 'monthly_line_chart.dart';
import 'monthly_week_chart.dart';
import 'today_session_list.dart';
import 'weekday_bar_chart.dart';

export 'home_stats_views/home_stats_views.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final period = ref.watch(statsPeriodProvider);

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
        ],
      ),
    );
  }
}
