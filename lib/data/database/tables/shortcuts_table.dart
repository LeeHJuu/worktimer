import 'package:drift/drift.dart';
import 'categories_table.dart';

/// 바로가기 테이블
/// 각 카테고리에 연결된 웹 URL 또는 exe 경로
class Shortcuts extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// 소속 카테고리 (CASCADE 삭제)
  IntColumn get categoryId =>
      integer().references(Categories, #id, onDelete: KeyAction.cascade)();

  TextColumn get name => text()();

  /// URL 또는 exe 절대경로
  TextColumn get target => text()();

  /// 'web' | 'exe'
  TextColumn get type => text()();
  IntColumn get sortOrder => integer()();
}
