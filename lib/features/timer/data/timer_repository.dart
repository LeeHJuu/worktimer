import 'package:drift/drift.dart';
import 'package:worktimer/core/database/app_database.dart';
import 'package:worktimer/core/logging/app_logger.dart';
import 'package:worktimer/features/timer/data/i_timer_repository.dart';

/// drift 기반 타이머 세션 Repository 구현체
class TimerRepository implements ITimerRepository {
  TimerRepository(this._db);

  final AppDatabase _db;

  @override
  Future<int> insertSession(TimerSessionsCompanion companion) {
    return _db.into(_db.timerSessions).insert(companion);
  }

  @override
  Future<void> endSession({
    required int id,
    required int endedAt,
    required int durationSec,
  }) async {
    await (_db.update(_db.timerSessions)..where((t) => t.id.equals(id)))
        .write(TimerSessionsCompanion(
      endedAt: Value(endedAt),
      durationSec: Value(durationSec),
    ));
  }

  @override
  Future<void> heartbeatSession({
    required int id,
    required int durationSec,
  }) async {
    await (_db.update(_db.timerSessions)..where((t) => t.id.equals(id)))
        .write(TimerSessionsCompanion(
      durationSec: Value(durationSec),
    ));
  }

  @override
  Stream<List<TimerSession>> watchTodaySessions() {
    final todayStart = _todayStartUnix();
    final todayEnd = todayStart + 86400;
    return (_db.select(_db.timerSessions)
          ..where((t) =>
              t.startedAt.isBiggerOrEqualValue(todayStart) &
              t.startedAt.isSmallerThanValue(todayEnd) &
              t.isFocus.equals(true))
          ..orderBy([(t) => OrderingTerm.asc(t.startedAt)]))
        .watch();
  }

  @override
  Future<List<TimerSession>> findOpenSessions() async {
    final rows = await (_db.select(_db.timerSessions)
          ..where((t) => t.endedAt.isNull()))
        .get();
    AppLog.d('findOpenSessions -> ${rows.length}');
    return rows;
  }

  @override
  Future<int> getTotalFocusSeconds(int categoryId) async {
    final rows = await (_db.select(_db.timerSessions)
          ..where((t) =>
              t.categoryId.equals(categoryId) &
              t.isFocus.equals(true) &
              t.durationSec.isNotNull()))
        .get();
    return rows.fold<int>(0, (sum, s) => sum + (s.durationSec ?? 0));
  }

  @override
  Future<List<TimerSession>> getSessionsInRange({
    required DateTime from,
    required DateTime to,
  }) {
    final fromTs = from.millisecondsSinceEpoch ~/ 1000;
    final toTs = to.millisecondsSinceEpoch ~/ 1000;
    return (_db.select(_db.timerSessions)
          ..where((t) =>
              t.startedAt.isBiggerOrEqualValue(fromTs) &
              t.startedAt.isSmallerThanValue(toTs) &
              t.isFocus.equals(true))
          ..orderBy([(t) => OrderingTerm.asc(t.startedAt)]))
        .get();
  }

  @override
  Future<void> updateSessionMemo(int id, String memo) async {
    await (_db.update(_db.timerSessions)..where((t) => t.id.equals(id)))
        .write(TimerSessionsCompanion(memo: Value(memo)));
  }

  @override
  Stream<List<TimerSession>> watchTodaySessionsDesc() {
    final todayStart = _todayStartUnix();
    final todayEnd = todayStart + 86400;
    return (_db.select(_db.timerSessions)
          ..where((t) =>
              t.startedAt.isBiggerOrEqualValue(todayStart) &
              t.startedAt.isSmallerThanValue(todayEnd) &
              t.isFocus.equals(true))
          ..orderBy([(t) => OrderingTerm.desc(t.startedAt)]))
        .watch();
  }

  @override
  Future<void> deleteSessionsByCategory(int categoryId) async {
    await (_db.delete(_db.timerSessions)
          ..where((t) => t.categoryId.equals(categoryId)))
        .go();
  }

  @override
  Future<void> deleteAllSessions() async {
    await _db.delete(_db.timerSessions).go();
  }

  @override
  Stream<List<TimerSession>> watchWeekSessions(DateTime weekStart) {
    final start = weekStart.millisecondsSinceEpoch ~/ 1000;
    final end = start + 7 * 86400;
    return (_db.select(_db.timerSessions)
          ..where((t) =>
              t.startedAt.isBiggerOrEqualValue(start) &
              t.startedAt.isSmallerThanValue(end) &
              t.isFocus.equals(true))
          ..orderBy([(t) => OrderingTerm.asc(t.startedAt)]))
        .watch();
  }

  @override
  Stream<List<TimerSession>> watchDaySessions(DateTime date) {
    final dayStart =
        DateTime(date.year, date.month, date.day).millisecondsSinceEpoch ~/
            1000;
    return (_db.select(_db.timerSessions)
          ..where((t) =>
              t.startedAt.isBiggerOrEqualValue(dayStart) &
              t.startedAt.isSmallerThanValue(dayStart + 86400) &
              t.isFocus.equals(true))
          ..orderBy([(t) => OrderingTerm.asc(t.startedAt)]))
        .watch();
  }

  /// 오늘 00:00:00 Unix timestamp
  int _todayStartUnix() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return today.millisecondsSinceEpoch ~/ 1000;
  }
}
