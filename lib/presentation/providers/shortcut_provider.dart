import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/database/app_database.dart';
import '../../data/repositories/i_shortcut_repository.dart';
import '../../data/repositories/shortcut_repository.dart';
import 'database_provider.dart';

/// 바로가기 Repository Provider
final shortcutRepositoryProvider = Provider<IShortcutRepository>((ref) {
  return ShortcutRepository(ref.watch(appDatabaseProvider));
});

/// 특정 카테고리의 바로가기 스트림 Provider
final shortcutsByCategoryProvider =
    StreamProvider.family<List<Shortcut>, int>((ref, categoryId) {
  return ref.watch(shortcutRepositoryProvider).watchByCategory(categoryId);
});
