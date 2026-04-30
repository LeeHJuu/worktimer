import 'package:drift/drift.dart';
import 'package:worktimer/core/database/app_database.dart';
import 'package:worktimer/features/manage/data/i_shortcut_repository.dart';

/// drift 기반 바로가기 Repository 구현체
class ShortcutRepository implements IShortcutRepository {
  ShortcutRepository(this._db);

  final AppDatabase _db;

  @override
  Stream<List<Shortcut>> watchByCategory(int categoryId) {
    return (_db.select(_db.shortcuts)
          ..where((t) => t.categoryId.equals(categoryId))
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .watch();
  }

  @override
  Stream<List<Shortcut>> watchAll() {
    return _db.select(_db.shortcuts).watch();
  }

  @override
  Future<Shortcut?> findById(int id) {
    return (_db.select(_db.shortcuts)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  @override
  Future<int> insert(ShortcutsCompanion companion) {
    return _db.into(_db.shortcuts).insert(companion);
  }

  @override
  Future<void> update(ShortcutsCompanion companion) async {
    await (_db.update(_db.shortcuts)
          ..where((t) => t.id.equals(companion.id.value)))
        .write(companion);
  }

  @override
  Future<void> delete(int id) async {
    await (_db.delete(_db.shortcuts)..where((t) => t.id.equals(id))).go();
  }

  @override
  Future<void> updateSortOrders(
      List<({int id, int sortOrder})> orders) async {
    await _db.transaction(() async {
      for (final o in orders) {
        await (_db.update(_db.shortcuts)..where((t) => t.id.equals(o.id)))
            .write(ShortcutsCompanion(sortOrder: Value(o.sortOrder)));
      }
    });
  }
}
