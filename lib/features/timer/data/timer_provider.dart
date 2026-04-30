import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:worktimer/features/timer/data/i_timer_repository.dart';
import 'package:worktimer/features/timer/data/timer_repository.dart';
import 'package:worktimer/core/database/database_provider.dart';

export 'package:worktimer/features/timer/data/timer_service.dart' show
    timerServiceProvider,
    TimerService,
    TimerState,
    TimerStatus;

/// 타이머 Repository Provider
final timerRepositoryProvider = Provider<ITimerRepository>((ref) {
  return TimerRepository(ref.watch(appDatabaseProvider));
});
