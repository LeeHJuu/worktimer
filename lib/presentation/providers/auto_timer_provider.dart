import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/services/auto_timer_controller.dart';
import '../../domain/services/focus_watcher_service.dart';
import 'shortcut_provider.dart';

/// 포커스 감시자 — 앱 수명과 동일.
final focusWatcherProvider = Provider<FocusWatcherService>((ref) {
  final svc = FocusWatcherService();
  ref.onDispose(svc.dispose);
  return svc;
});

/// 자동 타이머 컨트롤러 — 항상 활성화 상태로 시작.
final autoTimerControllerProvider = Provider<AutoTimerController>((ref) {
  final controller = AutoTimerController(
    ref: ref,
    focusWatcher: ref.watch(focusWatcherProvider),
    shortcutsStream: ref.read(shortcutRepositoryProvider).watchAll(),
  );

  controller.enable();
  ref.onDispose(() => controller.dispose());
  return controller;
});
