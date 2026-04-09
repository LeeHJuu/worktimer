import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/time_utils.dart';
import '../../../data/database/app_database.dart';
import '../../providers/category_provider.dart';
import '../../providers/condition_provider.dart';
import '../../providers/stats_provider.dart';
import '../../providers/timer_provider.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final period = ref.watch(statsPeriodProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          Row(
            children: [
              Text('통계', style: Theme.of(context).textTheme.headlineMedium),
              const Spacer(),
              // 기간 탭
              _PeriodTabBar(current: period),
            ],
          ),
          const SizedBox(height: 20),

          // 카테고리별 막대 그래프
          _CategoryBarChart(period: period),
          const SizedBox(height: 16),

          // 주간 요일별 그래프 (주간/월간일 때)
          if (period == StatsPeriod.week || period == StatsPeriod.month) ...[
            _WeekdayBarChart(period: period),
            const SizedBox(height: 16),
          ],

          // 월별 추이 그래프 (항상 표시)
          const _MonthlyLineChart(),
          const SizedBox(height: 16),

          // 컨디션별 평균 작업시간
          const _ConditionAvgTable(),
          const SizedBox(height: 16),

          // 커미션 총 시간 + 메모
          const _CommissionSummary(),
        ],
      ),
    );
  }
}

// ── 기간 탭 버튼 ─────────────────────────────────────────────

class _PeriodTabBar extends ConsumerWidget {
  const _PeriodTabBar({required this.current});
  final StatsPeriod current;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: StatsPeriod.values.map((p) {
        final isSelected = p == current;
        final label = switch (p) {
          StatsPeriod.today => '오늘',
          StatsPeriod.week => '주간',
          StatsPeriod.month => '월간',
        };
        return Padding(
          padding: const EdgeInsets.only(left: 6),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            child: FilledButton.tonal(
              style: FilledButton.styleFrom(
                backgroundColor: isSelected
                    ? colorScheme.primary
                    : colorScheme.surfaceContainerHighest,
                foregroundColor: isSelected
                    ? colorScheme.onPrimary
                    : colorScheme.onSurface,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: () =>
                  ref.read(statsPeriodProvider.notifier).state = p,
              child: Text(label, style: const TextStyle(fontSize: 13)),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ── 카테고리별 막대 그래프 ───────────────────────────────────

class _CategoryBarChart extends ConsumerWidget {
  const _CategoryBarChart({required this.period});
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
                  return _emptyText(context);
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
                              _formatHours(v.toInt()),
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
                            ? _parseColor(cat.color)
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

// ── 요일별 막대 그래프 ───────────────────────────────────────

class _WeekdayBarChart extends ConsumerWidget {
  const _WeekdayBarChart({required this.period});
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
                if (sessions.isEmpty) return _emptyText(context);

                final daySec = List<int>.filled(7, 0);
                for (final s in sessions) {
                  final d = DateTime.fromMillisecondsSinceEpoch(
                      s.startedAt * 1000);
                  daySec[d.weekday - 1] += s.durationSec ?? 0;
                }
                final maxVal = daySec.reduce((a, b) => a > b ? a : b);
                if (maxVal == 0) return _emptyText(context);

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
                              _formatHours(v.toInt()),
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
                                  ? colorScheme.tertiary
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

// ── 월별 추이 선 그래프 ──────────────────────────────────────

class _MonthlyLineChart extends ConsumerWidget {
  const _MonthlyLineChart();

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
                  return _emptyText(context);
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
                              _formatHours(v.toInt()),
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

// ── 컨디션별 평균 작업시간 ───────────────────────────────────

class _ConditionAvgTable extends ConsumerWidget {
  const _ConditionAvgTable();

  static const _emojis = ['😩', '😕', '😐', '🙂', '😄'];
  static const _labels = ['매우 나쁨', '나쁨', '보통', '좋음', '매우 좋음'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.mood_outlined,
                    size: 18, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text('컨디션별 평균 집중시간',
                    style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 16),
            _ConditionAvgData(),
          ],
        ),
      ),
    );
  }
}

class _ConditionAvgData extends ConsumerWidget {
  const _ConditionAvgData();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conditionsAsync = ref.watch(_last30DaysConditionsProvider);
    final sessionsAsync = ref.watch(_last30DaysSessionsProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return conditionsAsync.when(
      data: (conditions) => sessionsAsync.when(
        data: (sessions) {
          if (conditions.isEmpty) {
            return _emptyText(context);
          }
          // 날짜 → 컨디션 레벨 맵
          final condMap = {
            for (final c in conditions) c.date: c.level,
          };
          // 날짜별 세션 초 합산
          final daySec = <String, int>{};
          for (final s in sessions) {
            final d = DateTime.fromMillisecondsSinceEpoch(s.startedAt * 1000);
            final key =
                '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
            daySec[key] = (daySec[key] ?? 0) + (s.durationSec ?? 0);
          }
          // 컨디션 레벨별 평균 계산
          final levelSums = List<int>.filled(5, 0);
          final levelCounts = List<int>.filled(5, 0);
          for (final entry in condMap.entries) {
            final sec = daySec[entry.key] ?? 0;
            final lvl = entry.value - 1;
            if (lvl >= 0 && lvl < 5) {
              levelSums[lvl] += sec;
              levelCounts[lvl]++;
            }
          }

          return Column(
            children: List.generate(5, (i) {
              final avg = levelCounts[i] > 0
                  ? levelSums[i] ~/ levelCounts[i]
                  : 0;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  children: [
                    Text(_ConditionAvgTable._emojis[i],
                        style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 52,
                      child: Text(
                        _ConditionAvgTable._labels[i],
                        style: TextStyle(
                          fontSize: 11,
                          color: colorScheme.onSurface
                              .withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: LinearProgressIndicator(
                        value: avg > 0 ? (avg / 28800).clamp(0.0, 1.0) : 0,
                        backgroundColor:
                            colorScheme.outline.withValues(alpha: 0.15),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          colorScheme.primary.withValues(alpha: 0.7),
                        ),
                        minHeight: 6,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 55,
                      child: Text(
                        levelCounts[i] > 0
                            ? TimeUtils.formatSecondsToHuman(avg)
                            : '-',
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurface
                              .withValues(alpha: 0.7),
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              );
            }),
          );
        },
        loading: () => const LinearProgressIndicator(),
        error: (e, _) =>
            Text('오류: $e', style: const TextStyle(color: Colors.red)),
      ),
      loading: () => const LinearProgressIndicator(),
      error: (e, _) =>
          Text('오류: $e', style: const TextStyle(color: Colors.red)),
    );
  }
}

// 최근 30일 데이터 Provider
final _last30DaysConditionsProvider =
    FutureProvider<List<ConditionLog>>((ref) async {
  final repo = ref.read(conditionRepositoryProvider);
  final now = DateTime.now();
  final from = now.subtract(const Duration(days: 30));
  final fromStr =
      '${from.year}-${from.month.toString().padLeft(2, '0')}-${from.day.toString().padLeft(2, '0')}';
  final toStr =
      '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  return repo.getConditionsInRange(fromDate: fromStr, toDate: toStr);
});

final _last30DaysSessionsProvider =
    FutureProvider<List<TimerSession>>((ref) async {
  final repo = ref.read(timerRepositoryProvider);
  final now = DateTime.now();
  final from = now.subtract(const Duration(days: 30));
  return repo.getSessionsInRange(from: from, to: now);
});

// ── 커미션 총 시간 + 메모 ────────────────────────────────────

class _CommissionSummary extends ConsumerWidget {
  const _CommissionSummary();

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
                Icon(Icons.work_outline, size: 18, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text('카테고리 총 시간 & 메모',
                    style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 16),
            sessionsAsync.when(
              data: (sessions) {
                final cats = categoriesAsync.valueOrNull ?? [];
                if (sessions.isEmpty) return _emptyText(context);

                final catSec = <int, int>{};
                for (final s in sessions) {
                  catSec[s.categoryId] =
                      (catSec[s.categoryId] ?? 0) + (s.durationSec ?? 0);
                }

                return Column(
                  children: cats
                      .where((c) => catSec.containsKey(c.id))
                      .map((c) {
                    final color = _parseColor(c.color);
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            margin: const EdgeInsets.only(top: 3),
                            decoration: BoxDecoration(
                                color: color, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        c.name,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: colorScheme.onSurface,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      TimeUtils.formatSecondsToHuman(
                                          catSec[c.id] ?? 0),
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: color,
                                      ),
                                    ),
                                  ],
                                ),
                                if (c.memo != null && c.memo!.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      c.memo!,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: colorScheme.onSurface
                                            .withValues(alpha: 0.55),
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
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

// ── 헬퍼 ─────────────────────────────────────────────────────

Widget _emptyText(BuildContext context) => Text(
      '데이터가 없습니다.',
      style: Theme.of(context).textTheme.bodySmall,
    );

String _formatHours(int seconds) {
  if (seconds <= 0) return '0';
  final h = seconds ~/ 3600;
  final m = (seconds % 3600) ~/ 60;
  if (h > 0) return '${h}h';
  if (m > 0) return '${m}m';
  return '${seconds}s';
}

Color _parseColor(String hex) {
  try {
    final h = hex.replaceAll('#', '');
    return Color(int.parse('FF$h', radix: 16));
  } catch (_) {
    return Colors.blueAccent;
  }
}
