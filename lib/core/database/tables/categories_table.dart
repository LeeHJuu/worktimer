import 'package:drift/drift.dart';

/// 카테고리 테이블
/// 작업 분류 단위로, 목표 설정 및 바로가기를 포함
class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();

  /// hex 색상 (예: '#FF5733')
  TextColumn get color => text()();
  IntColumn get sortOrder => integer()();

  /// 사이드바 표시 여부 (기본: 표시)
  BoolColumn get isVisible => boolean().withDefault(const Constant(true))();

  /// 월별 메모 (커미션 건수 등)
  TextColumn get memo => text().nullable()();

  /// 목표명
  TextColumn get goalTitle => text().nullable()();

  /// 목표 총 시간 (시간 단위)
  RealColumn get goalTargetHours => real().nullable()();

  /// 목표 마감일 (Unix timestamp, 날짜 기준)
  IntColumn get goalDeadline => integer().nullable()();

  /// 목표 활성화 여부
  BoolColumn get goalIsActive =>
      boolean().withDefault(const Constant(false))();

  /// 포커스 자동 타이머가 idle 상태에서 이 카테고리를 자동 시작할지 여부
  BoolColumn get autoTimerOn =>
      boolean().withDefault(const Constant(false))();

  /// 생성 시각 (Unix timestamp)
  IntColumn get createdAt => integer()();
}
