import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/services/overload_service.dart';
import 'category_provider.dart';
import 'settings_provider.dart';
import 'timer_provider.dart';

/// 카테고리별 달성 시간 맵 Provider (총 집중 시간 초 → 시간 변환)
final achievedHoursProvider =
    FutureProvider<Map<int, double>>((ref) async {
  final categories = ref.watch(categoriesProvider).valueOrNull ?? [];
  final repo = timerRepositoryProvider;
  final timerRepo = ref.read(repo);

  final map = <int, double>{};
  for (final cat in categories) {
    final totalSec = await timerRepo.getTotalFocusSeconds(cat.id);
    map[cat.id] = totalSec / 3600.0;
  }
  return map;
});

/// 과부하 계산 결과 Provider
final overloadResultProvider =
    FutureProvider<OverloadResult?>((ref) async {
  final categories = ref.watch(categoriesProvider).valueOrNull;
  if (categories == null || categories.isEmpty) return null;

  final achievedMap = await ref.watch(achievedHoursProvider.future);
  final settingsRepo = ref.read(settingsRepositoryProvider);

  final weekdayHours = await settingsRepo.getWeekdayHours();
  final weekendHours = await settingsRepo.getWeekendHours();

  final activeGoalCategories =
      categories.where((c) => c.goalIsActive).toList();
  if (activeGoalCategories.isEmpty) return null;

  return const OverloadService().calculate(
    categories: categories,
    achievedHoursMap: achievedMap,
    weekdayHours: weekdayHours,
    weekendHours: weekendHours,
  );
});
