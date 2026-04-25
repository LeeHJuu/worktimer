import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/database/app_database.dart';
import '../../providers/category_provider.dart';
import '../../providers/shortcut_provider.dart';
import '../../providers/timer_provider.dart';

final manageControllerProvider = Provider<ManageController>(
  (ref) => ManageController(ref),
);

class ManageController {
  const ManageController(this._ref);

  final Ref _ref;

  Future<void> saveCategory(CategoriesCompanion companion) async {
    final repo = _ref.read(categoryRepositoryProvider);
    if (!companion.id.present) {
      final categories = _ref.read(categoriesProvider).valueOrNull ?? [];
      final nextOrder = categories.isEmpty
          ? 0
          : categories.map((c) => c.sortOrder).reduce((a, b) => a > b ? a : b) + 1;
      await repo.insert(companion.copyWith(sortOrder: Value(nextOrder)));
    } else {
      await repo.update(companion);
    }
  }

  Future<void> deleteCategory(int id) =>
      _ref.read(categoryRepositoryProvider).delete(id);

  Future<void> toggleCategoryVisible(Category cat) =>
      _ref.read(categoryRepositoryProvider).setVisible(cat.id, visible: !cat.isVisible);

  Future<void> resetCategorySessions(int categoryId) =>
      _ref.read(timerRepositoryProvider).deleteSessionsByCategory(categoryId);

  Future<void> resetAllSessions() =>
      _ref.read(timerRepositoryProvider).deleteAllSessions();

  Future<void> reorderCategories(List<Category> reordered) {
    final orders = reordered
        .asMap()
        .entries
        .map((e) => (id: e.value.id, sortOrder: e.key))
        .toList();
    return _ref.read(categoryRepositoryProvider).updateSortOrders(orders);
  }

  Future<void> saveShortcut(
    ShortcutsCompanion companion, {
    required int categoryId,
  }) async {
    final repo = _ref.read(shortcutRepositoryProvider);
    if (!companion.id.present) {
      final current =
          _ref.read(shortcutsByCategoryProvider(categoryId)).valueOrNull ?? [];
      final nextOrder = current.isEmpty
          ? 0
          : current.map((s) => s.sortOrder).reduce((a, b) => a > b ? a : b) + 1;
      await repo.insert(companion.copyWith(sortOrder: Value(nextOrder)));
    } else {
      await repo.update(companion);
    }
  }

  Future<void> deleteShortcut(int id) =>
      _ref.read(shortcutRepositoryProvider).delete(id);
}
