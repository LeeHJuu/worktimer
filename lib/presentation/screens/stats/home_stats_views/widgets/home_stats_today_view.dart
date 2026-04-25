import 'package:flutter/material.dart';
import '../../../../providers/stats_provider.dart';
import '../../category_bar_chart.dart';
import '../../today_session_list.dart';

class HomeStatsTodayView extends StatelessWidget {
  const HomeStatsTodayView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CategoryBarChart(period: StatsPeriod.today),
        SizedBox(height: 12),
        TodaySessionList(),
      ],
    );
  }
}
