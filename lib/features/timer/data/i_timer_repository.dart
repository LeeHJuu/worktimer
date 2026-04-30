import 'package:worktimer/core/database/app_database.dart';

/// 타이머 세션 Repository 인터페이스
abstract class ITimerRepository {
  /// 세션 삽입 (시작 시 호출), 생성된 rowid 반환
  Future<int> insertSession(TimerSessionsCompanion companion);

  /// 세션 종료 처리 (ended_at, duration_sec 업데이트)
  Future<void> endSession({
    required int id,
    required int endedAt,
    required int durationSec,
  });

  /// 오늘의 집중 세션 스트림 (is_focus=true만)
  Stream<List<TimerSession>> watchTodaySessions();

  /// 종료되지 않은 세션 조회 (앱 재시작 시 복구용)
  Future<List<TimerSession>> findOpenSessions();

  /// 특정 카테고리의 누적 집중 시간(초) 조회
  Future<int> getTotalFocusSeconds(int categoryId);

  /// 기간 내 집중 세션 목록 조회
  Future<List<TimerSession>> getSessionsInRange({
    required DateTime from,
    required DateTime to,
  });

  /// 세션에 메모 업데이트
  Future<void> updateSessionMemo(int id, String memo);

  /// 오늘의 집중 세션 스트림 (메모 포함, 최신순)
  Stream<List<TimerSession>> watchTodaySessionsDesc();

  /// 특정 카테고리의 세션 데이터 전체 삭제
  Future<void> deleteSessionsByCategory(int categoryId);

  /// 모든 세션 데이터 삭제
  Future<void> deleteAllSessions();
}
