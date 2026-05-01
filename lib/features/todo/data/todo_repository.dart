import 'package:drift/drift.dart';
import 'package:worktimer/core/database/app_database.dart';

class TodoRepository {
  TodoRepository(this._db);

  final AppDatabase _db;

  Stream<List<Todo>> watchAll() {
    return (_db.select(_db.todos)
          ..orderBy([
            (t) => OrderingTerm.asc(t.isCompleted),
            (t) => OrderingTerm.asc(t.sortOrder),
            (t) => OrderingTerm.asc(t.createdAt),
          ]))
        .watch();
  }

  Future<int> insert({
    required String title,
    int? categoryId,
    int? estimatedMinutes,
  }) {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return _db.into(_db.todos).insert(TodosCompanion.insert(
          title: title,
          categoryId: Value(categoryId),
          estimatedMinutes: Value(estimatedMinutes),
          createdAt: now,
        ));
  }

  Future<void> complete(int id) async {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    await (_db.update(_db.todos)..where((t) => t.id.equals(id))).write(
      TodosCompanion(
        isCompleted: const Value(true),
        completedAt: Value(now),
      ),
    );
  }

  Future<void> uncomplete(int id) async {
    await (_db.update(_db.todos)..where((t) => t.id.equals(id))).write(
      const TodosCompanion(
        isCompleted: Value(false),
        completedAt: Value(null),
      ),
    );
  }

  Future<void> delete(int id) async {
    await (_db.delete(_db.todos)..where((t) => t.id.equals(id))).go();
  }

  Future<void> updateTitle(int id, String title) async {
    await (_db.update(_db.todos)..where((t) => t.id.equals(id))).write(
      TodosCompanion(title: Value(title)),
    );
  }

  Future<void> updateCategory(int id, int? categoryId) async {
    await (_db.update(_db.todos)..where((t) => t.id.equals(id))).write(
      TodosCompanion(categoryId: Value(categoryId)),
    );
  }
}
