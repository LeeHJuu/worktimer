import 'package:flutter/material.dart';
import 'package:worktimer/features/stats/data/stats_provider.dart';
import 'package:worktimer/features/stats/view/widgets/category_bar_chart.dart';
import 'package:worktimer/features/stats/view/widgets/weekday_bar_chart.dart';

class HomeStatsWeekView extends StatelessWidget {
  const HomeStatsWeekView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CategoryBarChart(period: StatsPeriod.week),
        SizedBox(height: 12),
        WeekdayBarChart(period: StatsPeriod.week),
      ],
    );
  }
}
