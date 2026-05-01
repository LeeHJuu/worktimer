import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:worktimer/core/database/app_database.dart';
import 'package:worktimer/core/utils/color_utils.dart';
import 'package:worktimer/features/manage/data/category_provider.dart';
import 'package:worktimer/features/timer/data/timer_provider.dart';

// 타임라인 시작/종료 시간 (분)
const _kStartMin = 6 * 60; // 06:00
const _kEndMin = 24 * 60; // 24:00
const _kTotalMin = _kEndMin - _kStartMin; // 1080분

// 주간 타임라인 1시간당 픽셀
const _kHourPx = 24.0;
const _kTimelineHeight = 18 * _kHourPx; // 06:00~24:00 = 432px

class DailyTimelinePanel extends ConsumerWidget {
  const DailyTimelinePanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsAsync = ref.watch(_todaySessionsStreamProvider);
    final timerState = ref.watch(timerServiceProvider);
    final categoriesAsync = ref.watch(visibleCategoriesProvider);

    return sessionsAsync.when(
      data: (sessions) => categoriesAsync.when(
        data: (categories) {
          final catMap = {for (final c in categories) c.id: c};
          return _DailyTimeline(
            sessions: sessions,
            catMap: catMap,
            timerState: timerState,
          );
        },
        loading: () => const _LoadingBox(),
        error: (e, _) => _ErrorBox(message: '$e'),
      ),
      loading: () => const _LoadingBox(),
      error: (e, _) => _ErrorBox(message: '$e'),
    );
  }
}

final _todaySessionsStreamProvider = StreamProvider<List<TimerSession>>((ref) {
  return ref.watch(timerRepositoryProvider).watchTodaySessions();
});

// ── 일간 타임라인 ─────────────────────────────────────────────

class _DailyTimeline extends StatelessWidget {
  const _DailyTimeline({
    required this.sessions,
    required this.catMap,
    required this.timerState,
  });

  final List<TimerSession> sessions;
  final Map<int, Category> catMap;
  final TimerState timerState;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final now = DateTime.now();
    final nowMin = now.hour * 60 + now.minute;
    final nowPct = ((nowMin - _kStartMin) / _kTotalMin).clamp(0.0, 1.0);

    final totalSecs = sessions.fold<int>(0, (s, e) => s + (e.durationSec ?? 0));

    // 카테고리별 누적
    final catSecs = <int, int>{};
    for (final s in sessions) {
      catSecs[s.categoryId] = (catSecs[s.categoryId] ?? 0) + (s.durationSec ?? 0);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── 축 레이블 ──
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              _AxisLabel('06'),
              _AxisLabel('09'),
              _AxisLabel('12'),
              _AxisLabel('15'),
              _AxisLabel('18'),
              _AxisLabel('21'),
              _AxisLabel('24'),
            ],
          ),
        ),
        const SizedBox(height: 4),

        // ── 트랙 ──
        SizedBox(
          height: 48,
          child: LayoutBuilder(builder: (context, constraints) {
            final trackWidth = constraints.maxWidth;

            // 진행 중 세션 현재 너비 계산
            TimerSession? activeSession;
            if (timerState.isRunning || timerState.isPaused) {
              activeSession = sessions.where((s) => s.endedAt == null).firstOrNull;
            }

            return Stack(
              clipBehavior: Clip.none,
              children: [
                // 배경 트랙
                Container(
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                        color: colorScheme.outline.withValues(alpha: 0.15)),
                  ),
                ),
                // 시간 눈금
                ..._buildTicks(trackWidth, colorScheme),
                // 완료된 세션 블록
                ...sessions.where((s) => s.endedAt != null).map(
                      (s) => _buildBlock(s, trackWidth, catMap, context),
                    ),
                // 진행 중 세션 블록
                if (activeSession != null)
                  _buildLiveBlock(
                      activeSession, timerState, trackWidth, catMap, context),
                // Now 마커
                if (nowMin > _kStartMin && nowMin < _kEndMin)
                  _NowMarker(left: nowPct * trackWidth, now: now),
                // Gap 마커들
                ..._buildGapMarkers(sessions, trackWidth, timerState, catMap, context),
              ],
            );
          }),
        ),

        const SizedBox(height: 8),
        // ── 푸터 ──
        _TimelineFoot(sessions: sessions, totalSecs: totalSecs),

        // ── 카테고리 분포 바 ──
        if (totalSecs > 0) ...[
          const SizedBox(height: 14),
          Divider(height: 1, color: colorScheme.outline.withValues(alpha: 0.12)),
          const SizedBox(height: 10),
          _CategoryDistribution(catSecs: catSecs, catMap: catMap, totalSecs: totalSecs),
        ],
      ],
    );
  }

  Widget _buildBlock(TimerSession s, double trackWidth,
      Map<int, Category> catMap, BuildContext context) {
    final start = DateTime.fromMillisecondsSinceEpoch(s.startedAt * 1000);
    final startMin = start.hour * 60 + start.minute;
    final durMin = (s.durationSec ?? 0) / 60;
    if (durMin < 1) return const SizedBox.shrink();

    final left = ((startMin - _kStartMin) / _kTotalMin * trackWidth).clamp(0.0, trackWidth);
    final width = (durMin / _kTotalMin * trackWidth).clamp(2.0, trackWidth - left);

    final cat = catMap[s.categoryId];
    final color = cat != null ? parseHexColor(cat.color) : Colors.blueAccent;

    return Positioned(
      left: left,
      top: 4,
      bottom: 4,
      width: width,
      child: Tooltip(
        message: '${cat?.name ?? ''} · ${_fmtDur(s.durationSec ?? 0)}',
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: width > 30
              ? Text(
                  cat?.name ?? '',
                  style: const TextStyle(
                      color: Colors.white, fontSize: 10, fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildLiveBlock(TimerSession s, TimerState timerState, double trackWidth,
      Map<int, Category> catMap, BuildContext context) {
    final start = DateTime.fromMillisecondsSinceEpoch(s.startedAt * 1000);
    final startMin = start.hour * 60 + start.minute;
    final durMin = timerState.elapsedSeconds / 60;

    final left = ((startMin - _kStartMin) / _kTotalMin * trackWidth).clamp(0.0, trackWidth);
    final width = (durMin / _kTotalMin * trackWidth).clamp(2.0, trackWidth - left);

    final cat = catMap[s.categoryId];
    final color = cat != null ? parseHexColor(cat.color) : Colors.blueAccent;

    return Positioned(
      left: left,
      top: 4,
      bottom: 4,
      width: width,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(4),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.4),
              blurRadius: 6,
              spreadRadius: 0,
            )
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: width > 30
            ? Text(
                cat?.name ?? '',
                style: const TextStyle(
                    color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
              )
            : null,
      ),
    );
  }

  List<Widget> _buildTicks(double trackWidth, ColorScheme cs) {
    return [3, 6, 9, 12, 15].map((hoursFromStart) {
      final pct = hoursFromStart / 18;
      return Positioned(
        left: pct * trackWidth,
        top: 0,
        bottom: 0,
        width: 1,
        child: ColoredBox(color: cs.outline.withValues(alpha: 0.08)),
      );
    }).toList();
  }

  List<Widget> _buildGapMarkers(List<TimerSession> sessions, double trackWidth,
      TimerState timerState, Map<int, Category> catMap, BuildContext context) {
    if (sessions.length < 2) return [];
    final sorted = [...sessions]
      ..sort((a, b) => a.startedAt.compareTo(b.startedAt));

    final markers = <Widget>[];
    for (var i = 0; i < sorted.length - 1; i++) {
      final curr = sorted[i];
      final next = sorted[i + 1];
      final currEnd = curr.endedAt != null
          ? DateTime.fromMillisecondsSinceEpoch(curr.endedAt! * 1000)
          : DateTime.fromMillisecondsSinceEpoch(curr.startedAt * 1000)
              .add(Duration(seconds: curr.durationSec ?? 0));
      final nextStart =
          DateTime.fromMillisecondsSinceEpoch(next.startedAt * 1000);

      final gapMin = nextStart.difference(currEnd).inMinutes;
      if (gapMin < 30) continue;

      final midMin = currEnd.hour * 60 +
          currEnd.minute +
          gapMin ~/ 2;
      final pct = ((midMin - _kStartMin) / _kTotalMin).clamp(0.0, 1.0);
      final label = gapMin >= 60
          ? '빈 시간 ${gapMin ~/ 60}h ${gapMin % 60 > 0 ? '${gapMin % 60}m' : ''}'
          : '빈 시간 ${gapMin}m';

      markers.add(Positioned(
        left: pct * trackWidth - 36,
        top: 0,
        bottom: 0,
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                  style: BorderStyle.solid),
            ),
            child: Text(
              label,
              style: TextStyle(
                  fontSize: 9.5,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.5)),
            ),
          ),
        ),
      ));
    }
    return markers;
  }

  String _fmtDur(int secs) {
    final h = secs ~/ 3600;
    final m = (secs % 3600) ~/ 60;
    if (h > 0) return '${h}h ${m}m';
    return '${m}m';
  }
}

// ── 주간 타임라인 ─────────────────────────────────────────────

class WeeklyTimelinePanel extends ConsumerWidget {
  const WeeklyTimelinePanel({super.key, required this.weekStart});

  final DateTime weekStart;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weekSessionsAsync =
        ref.watch(_weekSessionsProvider(weekStart));
    final categoriesAsync = ref.watch(visibleCategoriesProvider);

    return weekSessionsAsync.when(
      data: (sessions) => categoriesAsync.when(
        data: (categories) {
          final catMap = {for (final c in categories) c.id: c};
          return _WeekGrid(
            weekStart: weekStart,
            sessions: sessions,
            catMap: catMap,
          );
        },
        loading: () => const _LoadingBox(),
        error: (e, _) => _ErrorBox(message: '$e'),
      ),
      loading: () => const _LoadingBox(),
      error: (e, _) => _ErrorBox(message: '$e'),
    );
  }
}

final _weekSessionsProvider =
    StreamProvider.family<List<TimerSession>, DateTime>((ref, weekStart) {
  return ref.watch(timerRepositoryProvider).watchWeekSessions(weekStart);
});

class _WeekGrid extends StatelessWidget {
  const _WeekGrid({
    required this.weekStart,
    required this.sessions,
    required this.catMap,
  });

  final DateTime weekStart;
  final List<TimerSession> sessions;
  final Map<int, Category> catMap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dayLabels = ['월', '화', '수', '목', '금', '토', '일'];

    // 요일별 세션 분리
    final byDay = List.generate(7, (_) => <TimerSession>[]);
    for (final s in sessions) {
      final dt = DateTime.fromMillisecondsSinceEpoch(s.startedAt * 1000);
      final day = DateTime(dt.year, dt.month, dt.day);
      final diff = day.difference(weekStart).inDays;
      if (diff >= 0 && diff < 7) byDay[diff].add(s);
    }

    // 요일별 총 시간
    final dayTotals = byDay.map((ss) =>
        ss.fold<int>(0, (sum, s) => sum + (s.durationSec ?? 0))).toList();
    dayTotals.reduce((a, b) => a > b ? a : b); // max for future use

    final totalSecs =
        sessions.fold<int>(0, (sum, s) => sum + (s.durationSec ?? 0));
    final catSecs = <int, int>{};
    for (final s in sessions) {
      catSecs[s.categoryId] = (catSecs[s.categoryId] ?? 0) + (s.durationSec ?? 0);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── 헤더 행 ──
        Row(
          children: [
            const SizedBox(width: 32),
            ...List.generate(7, (i) {
              final day = weekStart.add(Duration(days: i));
              final isToday = DateTime(day.year, day.month, day.day) == today;
              return Expanded(
                child: Column(
                  children: [
                    Text(
                      dayLabels[i],
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: isToday ? FontWeight.w700 : FontWeight.normal,
                        color: isToday
                            ? colorScheme.primary
                            : colorScheme.onSurface.withValues(alpha: 0.45),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      '${day.month}/${day.day}',
                      style: TextStyle(
                        fontSize: 9.5,
                        color: isToday
                            ? colorScheme.primary
                            : colorScheme.onSurface.withValues(alpha: 0.3),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
        const SizedBox(height: 6),
        Divider(height: 1, color: colorScheme.outline.withValues(alpha: 0.15)),

        // ── 타임라인 그리드 ──
        SizedBox(
          height: _kTimelineHeight,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 시간 레이블 컬럼
              SizedBox(
                width: 32,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    for (final h in [6, 9, 12, 15, 18, 21, 24])
                      Text(
                        '$h',
                        style: TextStyle(
                          fontSize: 9,
                          fontFamily: 'monospace',
                          color: colorScheme.onSurface.withValues(alpha: 0.3),
                        ),
                      ),
                  ],
                ),
              ),
              // 7개 날 컬럼
              ...List.generate(7, (i) {
                final day = weekStart.add(Duration(days: i));
                final isToday =
                    DateTime(day.year, day.month, day.day) == today;
                final daySessions = byDay[i];

                return Expanded(
                  child: Stack(
                    children: [
                      // 배경
                      Container(
                        decoration: BoxDecoration(
                          color: isToday
                              ? colorScheme.primary.withValues(alpha: 0.03)
                              : null,
                          border: Border(
                            left: BorderSide(
                              color: colorScheme.outline.withValues(alpha: 0.1),
                            ),
                          ),
                        ),
                      ),
                      // 세션 블록들
                      ...daySessions.map(
                          (s) => _weekBlock(s, catMap, colorScheme)),
                      // Now 마커 (오늘만)
                      if (isToday)
                        Positioned(
                          top: ((now.hour * 60 + now.minute - _kStartMin) /
                                  _kTotalMin *
                                  _kTimelineHeight)
                              .clamp(0.0, _kTimelineHeight),
                          left: 0,
                          right: 0,
                          child: Container(
                            height: 1.5,
                            color: Colors.redAccent,
                          ),
                        ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),

        const SizedBox(height: 10),
        // ── 주간 요약 ──
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '총 ${_fmtDur(totalSecs)}',
                style: const TextStyle(
                    fontSize: 11, color: Colors.green, fontFamily: 'monospace'),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '평균 ${_fmtDur(totalSecs ~/ 7)}/일',
              style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade500,
                  fontFamily: 'monospace'),
            ),
          ],
        ),

        // ── 카테고리 분포 바 (주간) ──
        if (totalSecs > 0) ...[
          const SizedBox(height: 14),
          Divider(height: 1, color: colorScheme.outline.withValues(alpha: 0.12)),
          const SizedBox(height: 10),
          _CategoryDistribution(
              catSecs: catSecs, catMap: catMap, totalSecs: totalSecs),
        ],
      ],
    );
  }

  Widget _weekBlock(
      TimerSession s, Map<int, Category> catMap, ColorScheme cs) {
    final start = DateTime.fromMillisecondsSinceEpoch(s.startedAt * 1000);
    final startMin = start.hour * 60 + start.minute;
    final durMin = (s.durationSec ?? 0) / 60;
    if (durMin < 1) return const SizedBox.shrink();

    final top = ((startMin - _kStartMin) / _kTotalMin * _kTimelineHeight)
        .clamp(0.0, _kTimelineHeight);
    final height = (durMin / _kTotalMin * _kTimelineHeight).clamp(2.0, _kTimelineHeight - top);

    final cat = catMap[s.categoryId];
    final color = cat != null ? parseHexColor(cat.color) : Colors.blueAccent;

    return Positioned(
      top: top,
      left: 2,
      right: 2,
      height: height,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(3),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
        child: height > 18
            ? Text(
                cat?.name ?? '',
                style: const TextStyle(
                    color: Colors.white, fontSize: 9, fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis,
              )
            : null,
      ),
    );
  }

  String _fmtDur(int secs) {
    final h = secs ~/ 3600;
    final m = (secs % 3600) ~/ 60;
    if (h > 0 && m > 0) return '${h}h ${m}m';
    if (h > 0) return '${h}h';
    return '${m}m';
  }
}

// ── 카테고리 분포 바 ──────────────────────────────────────────

class _CategoryDistribution extends StatelessWidget {
  const _CategoryDistribution({
    required this.catSecs,
    required this.catMap,
    required this.totalSecs,
  });

  final Map<int, int> catSecs;
  final Map<int, Category> catMap;
  final int totalSecs;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final sorted = catSecs.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '카테고리 분포',
          style: TextStyle(
            fontSize: 10.5,
            color: colorScheme.onSurface.withValues(alpha: 0.4),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        // 분포 바
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: SizedBox(
            height: 7,
            child: Row(
              children: sorted.map((e) {
                final cat = catMap[e.key];
                final color =
                    cat != null ? parseHexColor(cat.color) : Colors.grey;
                final pct = e.value / totalSecs;
                return Flexible(
                  flex: (pct * 1000).round(),
                  child: ColoredBox(color: color),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 6),
        // 범례
        Wrap(
          spacing: 12,
          runSpacing: 4,
          children: sorted.map((e) {
            final cat = catMap[e.key];
            final color =
                cat != null ? parseHexColor(cat.color) : Colors.grey;
            final h = e.value ~/ 3600;
            final m = (e.value % 3600) ~/ 60;
            final label = h > 0 ? '${h}h ${m}m' : '${m}m';
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                ),
                const SizedBox(width: 4),
                Text(
                  '${cat?.name ?? ''} $label',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontFamily: 'monospace',
                    color: colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}

// ── 공통 유틸 위젯 ────────────────────────────────────────────

class _AxisLabel extends StatelessWidget {
  const _AxisLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 9.5,
        fontFamily: 'monospace',
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.35),
      ),
    );
  }
}

class _NowMarker extends StatelessWidget {
  const _NowMarker({required this.left, required this.now});
  final double left;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final label =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    return Positioned(
      left: left - 1,
      top: -8,
      bottom: -8,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 수직선
          Container(width: 2, color: Colors.redAccent),
          // 원
          Positioned(
            top: 0,
            left: -3,
            child: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                  color: Colors.redAccent, shape: BoxShape.circle),
            ),
          ),
          // 시간 레이블
          Positioned(
            top: -18,
            left: -16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.redAccent, width: 0.8),
                borderRadius: BorderRadius.circular(3),
              ),
              child: Text(label,
                  style: const TextStyle(
                      fontSize: 9, color: Colors.redAccent, fontFamily: 'monospace')),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineFoot extends StatelessWidget {
  const _TimelineFoot({required this.sessions, required this.totalSecs});
  final List<TimerSession> sessions;
  final int totalSecs;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final h = totalSecs ~/ 3600;
    final m = (totalSecs % 3600) ~/ 60;
    final label = h > 0 ? '${h}h ${m}m' : '${m}m';

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            totalSecs > 0 ? label : '0m',
            style: const TextStyle(
                fontSize: 10.5, color: Colors.green, fontFamily: 'monospace'),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '${sessions.where((s) => s.endedAt != null).length}세션',
          style: TextStyle(
              fontSize: 11,
              color: colorScheme.onSurface.withValues(alpha: 0.4),
              fontFamily: 'monospace'),
        ),
      ],
    );
  }
}

class _LoadingBox extends StatelessWidget {
  const _LoadingBox();
  @override
  Widget build(BuildContext context) =>
      const Center(child: CircularProgressIndicator(strokeWidth: 2));
}

class _ErrorBox extends StatelessWidget {
  const _ErrorBox({required this.message});
  final String message;
  @override
  Widget build(BuildContext context) =>
      Center(child: Text(message, style: const TextStyle(color: Colors.red)));
}
