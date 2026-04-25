import 'package:flutter/material.dart';
import '../../../../providers/stats_provider.dart';
import '../../category_bar_chart.dart';
import '../../monthly_week_chart.dart';

class HomeStatsMonthView extends StatelessWidget {
  const HomeStatsMonthView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CategoryBarChart(period: StatsPeriod.month),
        SizedBox(height: 12),
        MonthlyWeekChart(),
      ],
    );
  }
}
