import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:worktimer/core/database/app_database.dart';
import 'package:worktimer/features/timer/data/timer_provider.dart';

// ── 통계 조회 기간 열거형 ───────────────────────────────────

enum StatsPeriod { today, week, month }

final statsPeriodProvider =
    StateProvider<StatsPeriod>((ref) => StatsPeriod.today);

// ── 기간 anchor 날짜 (이동 기준점) ──────────────────────────

final statsAnchorDateProvider = StateProvider<DateTime>((ref) {
  final n = DateTime.now();
  return DateTime(n.year, n.month, n.day);
});

// ── 기간별 세션 조회 Provider ────────────────────────────────

final statsSessionsProvider =
    FutureProvider<List<TimerSession>>((ref) async {
  final period = ref.watch(statsPeriodProvider);
  final anchor = ref.watch(statsAnchorDateProvider);
  final repo = ref.read(timerRepositoryProvider);

  DateTime from;
  DateTime to;

  switch (period) {
    case StatsPeriod.today:
      from = DateTime(anchor.year, anchor.month, anchor.day);
      to = from.add(const Duration(days: 1));
    case StatsPeriod.week:
      final weekday = anchor.weekday;
      from = DateTime(anchor.year, anchor.month, anchor.day)
          .subtract(Duration(days: weekday - 1));
      to = from.add(const Duration(days: 7));
    case StatsPeriod.month:
      from = DateTime(anchor.year, anchor.month, 1);
      to = DateTime(anchor.year, anchor.month + 1, 1);
  }

  return repo.getSessionsInRange(from: from, to: to);
});

// ── 12개월 월별 데이터 Provider ─────────────────────────────

final monthlyStatsProvider =
    FutureProvider<List<MonthStat>>((ref) async {
  final repo = ref.read(timerRepositoryProvider);
  final now = DateTime.now();
  final result = <MonthStat>[];

  for (int i = 11; i >= 0; i--) {
    final year = now.month - i > 0 ? now.year : now.year - 1;
    final month = ((now.month - i - 1) % 12) + 1;
    final from = DateTime(year, month, 1);
    final to = DateTime(year, month + 1, 1);
    final sessions =
        await repo.getSessionsInRange(from: from, to: to);
    final totalSec =
        sessions.fold<int>(0, (s, e) => s + (e.durationSec ?? 0));
    result.add(MonthStat(year: year, month: month, totalSeconds: totalSec));
  }
  return result;
});

class MonthStat {
  const MonthStat({
    required this.year,
    required this.month,
    required this.totalSeconds,
  });
  final int year;
  final int month;
  final int totalSeconds;
}

// ── 기간 이동 헬퍼 함수 ──────────────────────────────────────

/// anchor에서 delta 단위(+1/-1) 이동한 DateTime 반환
DateTime statsShiftAnchor(StatsPeriod period, DateTime anchor, int delta) {
  switch (period) {
    case StatsPeriod.today:
      return anchor.add(Duration(days: delta));
    case StatsPeriod.week:
      return anchor.add(Duration(days: 7 * delta));
    case StatsPeriod.month:
      return DateTime(anchor.year, anchor.month + delta, 1);
  }
}

/// anchor가 현재 기간(오늘/이번주/이번달)이거나 미래인지 확인
bool statsIsAtOrBeyondNow(StatsPeriod period, DateTime anchor) {
  final now = DateTime.now();
  switch (period) {
    case StatsPeriod.today:
      final today = DateTime(now.year, now.month, now.day);
      return !anchor.isBefore(today);
    case StatsPeriod.week:
      final monday = now.subtract(Duration(days: now.weekday - 1));
      final thisWeekStart = DateTime(monday.year, monday.month, monday.day);
      final anchorWeekday = anchor.weekday;
      final anchorWeekStart = DateTime(anchor.year, anchor.month, anchor.day)
          .subtract(Duration(days: anchorWeekday - 1));
      return !anchorWeekStart.isBefore(thisWeekStart);
    case StatsPeriod.month:
      return anchor.year > now.year ||
          (anchor.year == now.year && anchor.month >= now.month);
  }
}

/// 기간에 맞는 표시 레이블 반환 ("오늘", "이번 주", "2025년 3월" 등)
String statsPeriodLabel(StatsPeriod period, DateTime anchor) {
  final now = DateTime.now();
  switch (period) {
    case StatsPeriod.today:
      final today = DateTime(now.year, now.month, now.day);
      if (anchor == today) return '오늘';
      return '${anchor.month}/${anchor.day}';
    case StatsPeriod.week:
      final weekday = anchor.weekday;
      final weekStart = DateTime(anchor.year, anchor.month, anchor.day)
          .subtract(Duration(days: weekday - 1));
      final weekEnd = weekStart.add(const Duration(days: 6));
      if (statsIsAtOrBeyondNow(StatsPeriod.week, anchor)) return '이번 주';
      return '${weekStart.month}/${weekStart.day}~${weekEnd.month}/${weekEnd.day}';
    case StatsPeriod.month:
      if (anchor.year == now.year && anchor.month == now.month) return '이번 달';
      if (anchor.year == now.year) return '${anchor.month}월';
      return '${anchor.year}년 ${anchor.month}월';
  }
}
