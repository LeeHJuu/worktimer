import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/database/app_database.dart';
import '../../data/repositories/condition_repository.dart';
import '../../data/repositories/i_condition_repository.dart';
import 'database_provider.dart';

final conditionRepositoryProvider = Provider<IConditionRepository>((ref) {
  return ConditionRepository(ref.read(appDatabaseProvider));
});

/// 오늘의 컨디션 조회 Provider
final todayConditionProvider = FutureProvider<ConditionLog?>((ref) {
  return ref.read(conditionRepositoryProvider).getTodayCondition();
});
