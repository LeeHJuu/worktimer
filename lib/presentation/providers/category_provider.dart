import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/database/app_database.dart';
import '../../data/repositories/category_repository.dart';
import '../../data/repositories/i_category_repository.dart';
import 'database_provider.dart';

/// 카테고리 Repository Provider
final categoryRepositoryProvider = Provider<ICategoryRepository>((ref) {
  return CategoryRepository(ref.watch(appDatabaseProvider));
});

/// 전체 카테고리 스트림 Provider
final categoriesProvider = StreamProvider<List<Category>>((ref) {
  return ref.watch(categoryRepositoryProvider).watchAll();
});

/// 사이드바 표시용 카테고리 스트림 Provider
final visibleCategoriesProvider = StreamProvider<List<Category>>((ref) {
  return ref.watch(categoryRepositoryProvider).watchVisible();
});
