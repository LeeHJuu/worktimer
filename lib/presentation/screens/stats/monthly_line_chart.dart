import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/time_utils.dart';
import '../../providers/stats_provider.dart';
import 'stats_helpers.dart';

class MonthlyLineChart extends ConsumerWidget {
  const MonthlyLineChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final monthlyAsync = ref.watch(monthlyStatsProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.show_chart, size: 18, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text('월별 집중시간 추이',
                    style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 20),
            monthlyAsync.when(
              data: (stats) {
                if (stats.every((s) => s.totalSeconds == 0)) {
                  return statsEmptyText(context);
                }
                final maxVal = stats
                    .map((s) => s.totalSeconds)
                    .reduce((a, b) => a > b ? a : b)
                    .toDouble();

                return SizedBox(
                  height: 200,
                  child: LineChart(
                    LineChartData(
                      minX: 0,
                      maxX: 11,
                      minY: 0,
                      maxY: maxVal * 1.2,
                      lineTouchData: LineTouchData(
                        touchTooltipData: LineTouchTooltipData(
                          getTooltipItems: (spots) => spots
                              .map((s) => LineTooltipItem(
                                    '${stats[s.x.toInt()].month}월\n${TimeUtils.formatSecondsToHuman(s.y.toInt())}',
                                    const TextStyle(
                                        fontSize: 12,
                                        color: Colors.white),
                                  ))
                              .toList(),
                        ),
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
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 1,
                            getTitlesWidget: (v, meta) {
                              final idx = v.toInt();
                              if (idx < 0 || idx >= stats.length) {
                                return const SizedBox.shrink();
                              }
                              return Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(
                                  '${stats[idx].month}월',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: colorScheme.onSurface
                                        .withValues(alpha: 0.6),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
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
                      lineBarsData: [
                        LineChartBarData(
                          spots: stats.asMap().entries.map((e) {
                            return FlSpot(
                              e.key.toDouble(),
                              e.value.totalSeconds.toDouble(),
                            );
                          }).toList(),
                          isCurved: true,
                          color: colorScheme.primary,
                          barWidth: 2.5,
                          dotData: FlDotData(
                            getDotPainter: (spot, pct, bar, idx) =>
                                FlDotCirclePainter(
                              radius: 3,
                              color: colorScheme.primary,
                              strokeWidth: 1.5,
                              strokeColor: colorScheme.surface,
                            ),
                          ),
                          belowBarData: BarAreaData(
                            show: true,
                            color:
                                colorScheme.primary.withValues(alpha: 0.08),
                          ),
                        ),
                      ],
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
