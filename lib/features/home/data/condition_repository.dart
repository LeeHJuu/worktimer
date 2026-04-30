import 'package:drift/drift.dart';
import 'package:worktimer/core/database/app_database.dart';
import 'package:worktimer/features/home/data/i_condition_repository.dart';

/// Drift 기반 컨디션 Repository 구현체
class ConditionRepository implements IConditionRepository {
  ConditionRepository(this._db);

  final AppDatabase _db;

  @override
  Future<ConditionLog?> getTodayCondition() async {
    final today = _todayString();
    return (_db.select(_db.conditionLogs)
          ..where((t) => t.date.equals(today)))
        .getSingleOrNull();
  }

  @override
  Future<void> saveCondition({
    required String date,
    required int level,
  }) async {
    await _db.into(_db.conditionLogs).insert(
          ConditionLogsCompanion.insert(date: date, level: level),
          onConflict: DoUpdate(
            (old) => ConditionLogsCompanion.custom(
              level: Variable(level),
            ),
            target: [_db.conditionLogs.date],
          ),
        );
  }

  @override
  Future<List<ConditionLog>> getConditionsInRange({
    required String fromDate,
    required String toDate,
  }) {
    return (_db.select(_db.conditionLogs)
          ..where((t) =>
              t.date.isBiggerOrEqualValue(fromDate) &
              t.date.isSmallerOrEqualValue(toDate))
          ..orderBy([(t) => OrderingTerm.asc(t.date)]))
        .get();
  }

  /// 오늘 날짜 문자열 (YYYY-MM-DD)
  String _todayString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }
}
