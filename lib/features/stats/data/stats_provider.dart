import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:worktimer/core/database/app_database.dart';
import 'package:worktimer/features/timer/data/timer_provider.dart';

// ── 통계 조회 기간 열거형 ───────────────────────────────────

enum StatsPeriod { today, week, month }

final statsPeriodProvider =
    StateProvider<StatsPeriod>((ref) => StatsPeriod.today);

// ── 기간별 세션 조회 Provider ────────────────────────────────

final statsSessionsProvider =
    FutureProvider<List<TimerSession>>((ref) async {
  final period = ref.watch(statsPeriodProvider);
  final repo = ref.read(timerRepositoryProvider);
  final now = DateTime.now();

  DateTime from;
  DateTime to;

  switch (period) {
    case StatsPeriod.today:
      from = DateTime(now.year, now.month, now.day);
      to = from.add(const Duration(days: 1));
    case StatsPeriod.week:
      final weekday = now.weekday; // 월=1, 일=7
      from = DateTime(now.year, now.month, now.day)
          .subtract(Duration(days: weekday - 1));
      to = now.add(const Duration(days: 1));
    case StatsPeriod.month:
      from = DateTime(now.year, now.month, 1);
      to = DateTime(now.year, now.month + 1, 1);
  }

  return repo.getSessionsInRange(from: from, to: to);
});

// ── 12개월 월별 데이터 Provider ─────────────────────────────

final monthlyStatsProvider =
    FutureProvider<List<_MonthStat>>((ref) async {
  final repo = ref.read(timerRepositoryProvider);
  final now = DateTime.now();
  final result = <_MonthStat>[];

  for (int i = 11; i >= 0; i--) {
    final year = now.month - i > 0
        ? now.year
        : now.year - 1;
    final month = ((now.month - i - 1) % 12) + 1;
    final from = DateTime(year, month, 1);
    final to = DateTime(year, month + 1, 1);
    final sessions =
        await repo.getSessionsInRange(from: from, to: to);
    final totalSec =
        sessions.fold<int>(0, (s, e) => s + (e.durationSec ?? 0));
    result.add(_MonthStat(
      year: year,
      month: month,
      totalSeconds: totalSec,
    ));
  }
  return result;
});

class _MonthStat {
  const _MonthStat({
    required this.year,
    required this.month,
    required this.totalSeconds,
  });
  final int year;
  final int month;
  final int totalSeconds;
}
