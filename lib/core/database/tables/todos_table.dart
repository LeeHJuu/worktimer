import 'package:drift/drift.dart';
import 'package:worktimer/core/database/tables/categories_table.dart';

class Todos extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get categoryId => integer()
      .nullable()
      .references(Categories, #id, onDelete: KeyAction.setNull)();
  TextColumn get title => text()();

  /// 예상 소요 시간 (분 단위, null이면 미지정)
  IntColumn get estimatedMinutes => integer().nullable()();

  BoolColumn get isCompleted =>
      boolean().withDefault(const Constant(false))();

  /// 완료 시각 (Unix timestamp, null이면 미완료)
  IntColumn get completedAt => integer().nullable()();

  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  /// 생성 시각 (Unix timestamp)
  IntColumn get createdAt => integer()();
}
