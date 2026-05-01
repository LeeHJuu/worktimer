import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:worktimer/features/stats/data/stats_provider.dart';
import 'package:worktimer/features/stats/view/widgets/home_stats_today_view.dart';
import 'package:worktimer/features/stats/view/widgets/home_stats_week_view.dart';
import 'package:worktimer/features/stats/view/widgets/home_stats_month_view.dart';

class CompactStatsPanel extends ConsumerWidget {
  const CompactStatsPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final period = ref.watch(statsPeriodProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
