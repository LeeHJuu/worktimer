import 'package:drift/drift.dart';
import 'package:worktimer/core/database/tables/categories_table.dart';

/// 바로가기 테이블
/// 각 카테고리에 연결된 웹 URL 또는 네이티브 앱 실행파일 경로
class Shortcuts extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// 소속 카테고리 (CASCADE 삭제)
  IntColumn get categoryId =>
      integer().references(Categories, #id, onDelete: KeyAction.cascade)();

  TextColumn get name => text()();

  /// URL 또는 네이티브 실행파일 절대경로 (Windows .exe / 향후 macOS .app)
  TextColumn get target => text()();

  /// [allowedShortcutTypes] 중 하나 — 'web' | 'app'.
  ///
  /// 'app'은 현재 OS의 네이티브 실행파일을 의미. v5 마이그레이션에서
  /// 기존 'exe' 값은 모두 'app'으로 일괄 변환됨.
  TextColumn get type => text()();
  IntColumn get sortOrder => integer()();

  /// 포커스 시 자동 시작 여부 (기본 true)
  BoolColumn get autoStart =>
      boolean().withDefault(const Constant(true))();
}

/// 허용 가능한 [Shortcuts.type] 값 — 신규 데이터 입력 시 이 셋 안의 값만 사용.
const allowedShortcutTypes = {'web', 'app'};
