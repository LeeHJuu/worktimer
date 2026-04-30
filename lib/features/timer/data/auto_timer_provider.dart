import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:worktimer/core/platform/capability.dart';
import 'package:worktimer/features/timer/data/auto_timer_controller.dart';
import 'package:worktimer/core/platform/capability_provider.dart';
import 'package:worktimer/core/platform/platform_integration_provider.dart';
import 'package:worktimer/features/manage/data/shortcut_provider.dart';

/// 자동 타이머 컨트롤러 — 항상 활성화 상태로 시작.
///
/// `Capability.focusAutoTimer` 미지원 플랫폼에서는 enable() 내부에서 즉시 종료.
final autoTimerControllerProvider = Provider<AutoTimerController>((ref) {
  final integration = ref.watch(platformIntegrationServiceProvider);
  final canFocus = ref.watch(capabilityProvider(Capability.focusAutoTimer));
  final controller = AutoTimerController(
    ref: ref,
    integration: integration,
    shortcutsStream: ref.read(shortcutRepositoryProvider).watchAll(),
    canFocusAutoTimer: canFocus,
  );

  controller.enable();
  ref.onDispose(() => controller.dispose());
  return controller;
});
