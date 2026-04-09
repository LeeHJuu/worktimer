import 'package:drift/drift.dart';
import '../database/app_database.dart';
import 'i_category_repository.dart';

/// drift 기반 카테고리 Repository 구현체
class CategoryRepository implements ICategoryRepository {
  CategoryRepository(this._db);

  final AppDatabase _db;

  @override
  Stream<List<Category>> watchAll() {
    return (_db.select(_db.categories)
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .watch();
  }

  @override
  Stream<List<Category>> watchVisible() {
    return (_db.select(_db.categories)
          ..where((t) => t.isVisible.equals(true))
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .watch();
  }

  @override
  Future<Category?> findById(int id) {
    return (_db.select(_db.categories)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  @override
  Future<int> insert(CategoriesCompanion companion) async {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return _db.into(_db.categories).insert(
          companion.copyWith(createdAt: Value(now)),
        );
  }

  @override
  Future<void> update(CategoriesCompanion companion) async {
    await (_db.update(_db.categories)
          ..where((t) => t.id.equals(companion.id.value)))
        .write(companion);
  }

  @override
  Future<void> delete(int id) async {
    await (_db.delete(_db.categories)
          ..where((t) => t.id.equals(id)))
        .go();
  }

  @override
  Future<void> updateSortOrders(
      List<({int id, int sortOrder})> orders) async {
    await _db.transaction(() async {
      for (final o in orders) {
        await (_db.update(_db.categories)
              ..where((t) => t.id.equals(o.id)))
            .write(CategoriesCompanion(sortOrder: Value(o.sortOrder)));
      }
    });
  }

  @override
  Future<void> setVisible(int id, {required bool visible}) async {
    await (_db.update(_db.categories)
          ..where((t) => t.id.equals(id)))
        .write(CategoriesCompanion(isVisible: Value(visible)));
  }
}
