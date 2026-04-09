import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/i_timer_repository.dart';
import '../../data/repositories/timer_repository.dart';
import 'database_provider.dart';

export '../../domain/services/timer_service.dart' show
    timerServiceProvider,
    TimerService,
    TimerState,
    TimerStatus;

/// 타이머 Repository Provider
final timerRepositoryProvider = Provider<ITimerRepository>((ref) {
  return TimerRepository(ref.watch(appDatabaseProvider));
});
