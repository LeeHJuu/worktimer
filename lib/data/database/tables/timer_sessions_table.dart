import 'package:drift/drift.dart';
import 'categories_table.dart';

/// 타이머 세션 테이블
/// 시작/종료 시각 및 집중/휴식 구분을 기록
class TimerSessions extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// 소속 카테고리 (CASCADE 삭제)
  IntColumn get categoryId =>
      integer().references(Categories, #id, onDelete: KeyAction.cascade)();

  /// 세션 시작 시각 (Unix timestamp)
  IntColumn get startedAt => integer()();

  /// 세션 종료 시각 (null이면 진행 중)
  IntColumn get endedAt => integer().nullable()();

  /// 종료 시 계산하여 저장 (초 단위)
  IntColumn get durationSec => integer().nullable()();

  /// 'normal' | 'pomodoro'
  TextColumn get mode => text()();

  /// 집중 여부 (false = 휴식, 통계 집계 제외)
  BoolColumn get isFocus => boolean().withDefault(const Constant(true))();

  /// 세션 종료 후 사용자가 남기는 메모 (선택 사항)
  TextColumn get memo => text().nullable()();
}
