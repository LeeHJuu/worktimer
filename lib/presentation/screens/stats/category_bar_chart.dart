import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/time_utils.dart';
import '../../providers/category_provider.dart';
import '../../providers/stats_provider.dart';
import 'stats_helpers.dart';

class CategoryBarChart extends ConsumerWidget {
  const CategoryBarChart({super.key, required this.period});
  final StatsPeriod period;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsAsync = ref.watch(statsSessionsProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.bar_chart, size: 18, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text('카테고리별 집중시간',
                    style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 20),
            sessionsAsync.when(
              data: (sessions) {
                final cats = categoriesAsync.valueOrNull ?? [];
                if (sessions.isEmpty) {
                  return statsEmptyText(context);
                }

                final catSec = <int, int>{};
                for (final s in sessions) {
                  catSec[s.categoryId] =
                      (catSec[s.categoryId] ?? 0) + (s.durationSec ?? 0);
                }

                final entries = catSec.entries.toList()
                  ..sort((a, b) => b.value.compareTo(a.value));
                final maxVal = entries.first.value.toDouble();

                return SizedBox(
                  height: 200,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: maxVal * 1.2,
                      barTouchData: BarTouchData(
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipItem: (group, gIdx, rod, rIdx) {
                            final catId = entries[gIdx].key;
                            final cat = cats
                                .where((c) => c.id == catId)
                                .firstOrNull;
                            return BarTooltipItem(
                              '${cat?.name ?? '?'}\n${TimeUtils.formatSecondsToHuman(rod.toY.toInt())}',
                              const TextStyle(
                                  fontSize: 12, color: Colors.white),
                            );
                          },
                        ),
                      ),
                      titlesData: FlTitlesData(
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
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (v, meta) {
                              final idx = v.toInt();
                              if (idx >= entries.length) {
                                return const SizedBox.shrink();
                              }
                              final catId = entries[idx].key;
                              final cat = cats
                                  .where((c) => c.id == catId)
                                  .firstOrNull;
                              return Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(
                                  cat?.name ?? '?',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: colorScheme.onSurface
                                        .withValues(alpha: 0.7),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            },
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
                          color: colorScheme.outline.withValues(alpha: 0.2),
                          strokeWidth: 1,
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups:
                          entries.asMap().entries.map((e) {
                        final cat = cats
                            .where((c) => c.id == e.value.key)
                            .firstOrNull;
                        final color = cat != null
                            ? statsParseColor(cat.color)
                            : colorScheme.primary;
                        return BarChartGroupData(
                          x: e.key,
                          barRods: [
                            BarChartRodData(
                              toY: e.value.value.toDouble(),
                              color: color,
                              width: 22,
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
