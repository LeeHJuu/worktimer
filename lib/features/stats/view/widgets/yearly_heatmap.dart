import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:worktimer/features/stats/data/stats_provider.dart';
import 'package:worktimer/features/timer/data/timer_provider.dart';

// ── Provider ─────────────────────────────────────────────────

final yearlyHeatmapProvider =
    FutureProvider.autoDispose.family<Map<String, int>, int>((ref, year) async {
  final repo = ref.read(timerRepositoryProvider);
  final sessions = await repo.getSessionsInRange(
    from: DateTime(year, 1, 1),
    to: DateTime(year + 1, 1, 1),
  );
  final result = <String, int>{};
  for (final s in sessions) {
    final d = DateTime.fromMillisecondsSinceEpoch(s.startedAt * 1000);
    final key =
        '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    result[key] = (result[key] ?? 0) + (s.durationSec ?? 0);
  }
  return result;
});

// ── 위젯 ─────────────────────────────────────────────────────

class YearlyHeatmap extends ConsumerWidget {
  const YearlyHeatmap({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final anchor = ref.watch(statsAnchorDateProvider);
    final year = anchor.year;
    final heatmapAsync = ref.watch(yearlyHeatmapProvider(year));
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.grid_view_rounded,
                    size: 16, color: colorScheme.primary),
                const SizedBox(width: 6),
                Text('$year년 활동',
                    style: Theme.of(context).textTheme.titleSmall),
              ],
            ),
            const SizedBox(height: 14),
            heatmapAsync.when(
              data: (dayMap) => _HeatmapGrid(year: year, dayMap: dayMap),
              loading: () => const SizedBox(
                height: 80,
                child: Center(child: LinearProgressIndicator()),
              ),
              error: (e, _) =>
                  Text('오류: $e', style: const TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ),
    );
  }
}

// ── 그리드 ────────────────────────────────────────────────────

class _HeatmapGrid extends StatelessWidget {
  const _HeatmapGrid({required this.year, required this.dayMap});

  final int year;
  final Map<String, int> dayMap;

  static const _cellSize = 11.0;
  static const _gap = 2.0;
  static const _unit = _cellSize + _gap;
  // 8시간 = 최대 강도 기준
  static const _maxSec = 8 * 3600;

  Color _cellColor(int? secs, ColorScheme cs) {
    if (secs == null || secs == 0) {
      return cs.outline.withValues(alpha: 0.15);
    }
    final ratio = (secs / _maxSec).clamp(0.0, 1.0);
    return cs.primary.withValues(alpha: 0.25 + ratio * 0.75);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final now = DateTime.now();
    final jan1 = DateTime(year, 1, 1);
    // 월요일 시작 기준 오프셋 (월=0 ... 일=6)
    final startOffset = jan1.weekday - 1;

    // 총 일수 (윤년 대응)
    final totalDays =
        DateTime(year + 1, 1, 1).difference(jan1).inDays;

    // 월 레이블 위치 계산
    final monthLabels = <(int col, String label)>[];
    int prevMonth = -1;
    for (int idx = 0; idx < totalDays; idx++) {
      final date = jan1.add(Duration(days: idx));
      if (date.month != prevMonth) {
        prevMonth = date.month;
        final col = (idx + startOffset) ~/ 7;
        monthLabels.add((col, '${date.month}월'));
      }
    }

    final totalCols = (totalDays + startOffset + 6) ~/ 7;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 월 레이블 행
        SizedBox(
          height: 14,
          child: Stack(
            children: monthLabels.map((e) {
              return Positioned(
                left: e.$1 * _unit,
                child: Text(
                  e.$2,
                  style: TextStyle(
                      fontSize: 9,
                      color: colorScheme.onSurface.withValues(alpha: 0.45)),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 요일 레이블 (월/수/금만 표시)
            SizedBox(
              width: 18,
              child: Column(
                children: List.generate(7, (i) {
                  const labels = ['월', '', '수', '', '금', '', ''];
                  return SizedBox(
                    height: _unit,
                    child: labels[i].isNotEmpty
                        ? Text(
                            labels[i],
                            style: TextStyle(
                                fontSize: 8.5,
                                color: colorScheme.onSurface
                                    .withValues(alpha: 0.35)),
                          )
                        : null,
                  );
                }),
              ),
            ),
            // 셀 그리드
            SizedBox(
              width: totalCols * _unit,
              height: 7 * _unit,
              child: Stack(
                children: [
                  // 빈 오프셋 + 날짜 셀
                  for (int idx = 0; idx < totalDays; idx++)
                    _buildCell(
                        idx, jan1, startOffset, now, colorScheme),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // 범례
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text('적음',
                style: TextStyle(
                    fontSize: 9,
                    color: colorScheme.onSurface.withValues(alpha: 0.4))),
            const SizedBox(width: 4),
            for (final ratio in [0.0, 0.25, 0.5, 0.75, 1.0])
              Container(
                width: _cellSize,
                height: _cellSize,
                margin: const EdgeInsets.only(right: 2),
                decoration: BoxDecoration(
                  color: ratio == 0.0
                      ? colorScheme.outline.withValues(alpha: 0.15)
                      : colorScheme.primary
                          .withValues(alpha: 0.25 + ratio * 0.75),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            const SizedBox(width: 4),
            Text('많음',
                style: TextStyle(
                    fontSize: 9,
                    color: colorScheme.onSurface.withValues(alpha: 0.4))),
          ],
        ),
      ],
    );
  }

  Widget _buildCell(int idx, DateTime jan1, int startOffset, DateTime now,
      ColorScheme colorScheme) {
    final date = jan1.add(Duration(days: idx));
    final gridIdx = idx + startOffset;
    final col = gridIdx ~/ 7;
    final row = gridIdx % 7;

    final isFuture = date.isAfter(now);
    final key =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final secs = isFuture ? null : dayMap[key];

    final tooltipMsg = isFuture
        ? '${date.month}/${date.day}'
        : (secs != null && secs > 0)
            ? '${date.month}/${date.day}: ${_fmtSecs(secs)}'
            : '${date.month}/${date.day}: 기록 없음';

    return Positioned(
      left: col * _unit,
      top: row * _unit,
      child: Tooltip(
        message: tooltipMsg,
        child: Container(
          width: _cellSize,
          height: _cellSize,
          decoration: BoxDecoration(
            color: isFuture
                ? Colors.transparent
                : _cellColor(secs, colorScheme),
            borderRadius: BorderRadius.circular(2),
            border: isFuture
                ? Border.all(
                    color: colorScheme.outline.withValues(alpha: 0.08))
                : null,
          ),
        ),
      ),
    );
  }

  String _fmtSecs(int secs) {
    final h = secs ~/ 3600;
    final m = (secs % 3600) ~/ 60;
    if (h > 0 && m > 0) return '${h}h ${m}m';
    if (h > 0) return '${h}h';
    return '${m}m';
  }
}
