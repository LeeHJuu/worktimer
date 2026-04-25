import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/time_utils.dart';
import '../../providers/stats_provider.dart';
import 'stats_helpers.dart';

class MonthlyWeekChart extends ConsumerWidget {
  const MonthlyWeekChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsAsync = ref.watch(statsSessionsProvider);
    final colorScheme = Theme.of(context).colorScheme;

    const weekLabels = ['1주', '2주', '3주', '4주', '5주'];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.calendar_view_month_outlined,
                    size: 18, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text('주차별 집중시간',
                    style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 20),
            sessionsAsync.when(
              data: (sessions) {
                if (sessions.isEmpty) return statsEmptyText(context);

                final weekSec = List<int>.filled(5, 0);
                for (final s in sessions) {
                  final d = DateTime.fromMillisecondsSinceEpoch(
                      s.startedAt * 1000);
                  final weekIdx = ((d.day - 1) ~/ 7).clamp(0, 4);
                  weekSec[weekIdx] += s.durationSec ?? 0;
                }

                int displayWeeks = 5;
                while (displayWeeks > 1 && weekSec[displayWeeks - 1] == 0) {
                  displayWeeks--;
                }

                final maxVal =
                    weekSec.take(displayWeeks).reduce((a, b) => a > b ? a : b);
                if (maxVal == 0) return statsEmptyText(context);

                return SizedBox(
                  height: 180,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: maxVal.toDouble() * 1.2,
                      barTouchData: BarTouchData(
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipItem: (group, gIdx, rod, rIdx) =>
                              BarTooltipItem(
                            '${weekLabels[gIdx]}\n${TimeUtils.formatSecondsToHuman(rod.toY.toInt())}',
                            const TextStyle(
                                fontSize: 12, color: Colors.white),
                          ),
                        ),
                      ),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (v, meta) {
                              final idx = v.toInt();
                              if (idx >= displayWeeks) {
                                return const SizedBox.shrink();
                              }
                              return Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(
                                  weekLabels[idx],
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: colorScheme.onSurface
                                        .withValues(alpha: 0.7),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 38,
                            getTitlesWidget: (v, meta) => Text(
                              statsFormatHours(v.toInt()),
                              style: TextStyle(
                                fontSize: 10,
                                color: colorScheme.onSurface
                                    .withValues(alpha: 0.5),
                              ),
                            ),
                          ),
                        ),
                        topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                      ),
                      gridData: FlGridData(
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (v) => FlLine(
                          color:
                              colorScheme.outline.withValues(alpha: 0.2),
                          strokeWidth: 1,
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups: List.generate(
                        displayWeeks,
                        (i) => BarChartGroupData(
                          x: i,
                          barRods: [
                            BarChartRodData(
                              toY: weekSec[i].toDouble(),
                              color: colorScheme.primary,
                              width: 28,
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(4)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
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
