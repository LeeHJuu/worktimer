import 'package:flutter/material.dart';
import '../../../../providers/stats_provider.dart';
import '../../category_bar_chart.dart';
import '../../weekday_bar_chart.dart';

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
