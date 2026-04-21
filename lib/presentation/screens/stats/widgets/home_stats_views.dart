import 'package:flutter/material.dart';
import '../../../providers/stats_provider.dart';
import 'category_bar_chart.dart';
import 'monthly_week_chart.dart';
import 'today_session_list.dart';
import 'weekday_bar_chart.dart';

/// 오늘 뷰: 카테고리 바 차트 + 세션 목록
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

/// 주간 뷰: 카테고리 바 차트 + 요일별 바 차트
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

/// 월간 뷰: 카테고리 바 차트 + 주차별 바 차트
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
