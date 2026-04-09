import '../database/app_database.dart';

/// 컨디션 기록 Repository 인터페이스
abstract class IConditionRepository {
  /// 오늘 날짜의 컨디션 조회 (없으면 null)
  Future<ConditionLog?> getTodayCondition();

  /// 컨디션 저장 또는 업데이트 (하루 1회, upsert)
  Future<void> saveCondition({required String date, required int level});

  /// 기간 내 컨디션 목록 조회
  Future<List<ConditionLog>> getConditionsInRange({
    required String fromDate,
    required String toDate,
  });
}
