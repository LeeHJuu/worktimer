import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/services/auto_timer_controller.dart';
import '../../domain/services/focus_watcher_service.dart';
import 'category_provider.dart';
import 'shortcut_provider.dart';

/// 전역 자동 타이머 활성화 상태 (사용자가 설정에서 토글).
/// 초기값은 SettingsRepository 로드 후 반영.
final autoTimerEnabledProvider = StateProvider<bool>((ref) => false);

/// 포커스 감시자 — 앱 수명과 동일.
final focusWatcherProvider = Provider<FocusWatcherService>((ref) {
  final svc = FocusWatcherService();
  ref.onDispose(svc.dispose);
  return svc;
});

/// 자동 타이머 컨트롤러 — enable/disable 은 autoTimerEnabledProvider 변경에 연동.
final autoTimerControllerProvider = Provider<AutoTimerController>((ref) {
  final controller = AutoTimerController(
    ref: ref,
    focusWatcher: ref.watch(focusWatcherProvider),
    categoriesStream: ref.read(categoryRepositoryProvider).watchAll(),
    shortcutsStream: ref.read(shortcutRepositoryProvider).watchAll(),
  );

  ref.listen<bool>(autoTimerEnabledProvider, (_, enabled) {
    if (enabled) {
      controller.enable();
    } else {
      controller.disable();
    }
  }, fireImmediately: true);

  ref.onDispose(() => controller.dispose());
  return controller;
});
