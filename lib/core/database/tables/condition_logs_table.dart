import 'package:drift/drift.dart';

/// 컨디션 기록 테이블
/// 하루 1회 1~5단계 컨디션을 기록
class ConditionLogs extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// 날짜 (YYYY-MM-DD), 하루 1건 고유
  TextColumn get date => text().unique()();

  /// 컨디션 수준 1~5
  IntColumn get level => integer()();
}
