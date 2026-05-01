import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:worktimer/core/database/app_database.dart';
import 'package:worktimer/features/manage/data/i_shortcut_repository.dart';
import 'package:worktimer/features/manage/data/shortcut_repository.dart';
import 'package:worktimer/core/database/database_provider.dart';

/// 바로가기 Repository Provider
final shortcutRepositoryProvider = Provider<IShortcutRepository>((ref) {
  return ShortcutRepository(ref.watch(appDatabaseProvider));
});

/// 특정 카테고리의 바로가기 스트림 Provider
final shortcutsByCategoryProvider =
    StreamProvider.family<List<Shortcut>, int>((ref, categoryId) {
  return ref.watch(shortcutRepositoryProvider).watchByCategory(categoryId);
});

/// 모든 바로가기 스트림 Provider (자동 타이머 매칭용)
final allShortcutsProvider = StreamProvider<List<Shortcut>>((ref) {
  return ref.watch(shortcutRepositoryProvider).watchAll();
});
