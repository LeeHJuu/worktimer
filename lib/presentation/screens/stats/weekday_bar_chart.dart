import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/time_utils.dart';
import '../../providers/stats_provider.dart';
import 'stats_helpers.dart';

class WeekdayBarChart extends ConsumerWidget {
  const WeekdayBarChart({super.key, required this.period});
  final StatsPeriod period;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsAsync = ref.watch(statsSessionsProvider);
    final colorScheme = Theme.of(context).colorScheme;

    const dayLabels = ['월', '화', '수', '목', '금', '토', '일'];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.calendar_view_week,
                    size: 18, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text('요일별 집중시간',
                    style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 20),
            sessionsAsync.when(
              data: (sessions) {
                if (sessions.isEmpty) return statsEmptyText(context);

                final daySec = List<int>.filled(7, 0);
                for (final s in sessions) {
                  final d = DateTime.fromMillisecondsSinceEpoch(
                      s.startedAt * 1000);
                  daySec[d.weekday - 1] += s.durationSec ?? 0;
                }
                final maxVal = daySec.reduce((a, b) => a > b ? a : b);
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
                            '${dayLabels[gIdx]}\n${TimeUtils.formatSecondsToHuman(rod.toY.toInt())}',
                            const TextStyle(
                                fontSize: 12, color: Colors.white),
                          ),
                        ),
                      ),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (v, meta) => Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(
                                dayLabels[v.toInt()],
                                style: TextStyle(
                                  fontSize: 11,
                                  color: colorScheme.onSurface
                                      .withValues(alpha: 0.7),
                                ),
                              ),
                            ),
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
                      barGroups: daySec.asMap().entries.map((e) {
                        final isWeekend =
                            e.key == 5 || e.key == 6;
                        return BarChartGroupData(
                          x: e.key,
                          barRods: [
                            BarChartRodData(
                              toY: e.value.toDouble(),
                              color: isWeekend
                                  ? colorScheme.secondary
                                  : colorScheme.primary,
                              width: 20,
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(4)),
                            ),
                          ],
                        );
                      }).toList(),
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
