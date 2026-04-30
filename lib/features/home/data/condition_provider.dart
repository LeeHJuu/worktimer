import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:worktimer/core/database/app_database.dart';
import 'package:worktimer/features/home/data/condition_repository.dart';
import 'package:worktimer/features/home/data/i_condition_repository.dart';
import 'package:worktimer/core/database/database_provider.dart';

final conditionRepositoryProvider = Provider<IConditionRepository>((ref) {
  return ConditionRepository(ref.read(appDatabaseProvider));
});

/// 오늘의 컨디션 조회 Provider
final todayConditionProvider = FutureProvider<ConditionLog?>((ref) {
  return ref.read(conditionRepositoryProvider).getTodayCondition();
});
