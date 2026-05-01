import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:worktimer/core/database/app_database.dart';
import 'package:worktimer/features/timer/data/timer_provider.dart';
import 'package:worktimer/core/platform/platform_integration_service.dart';
import 'package:worktimer/features/timer/data/timer_service.dart';

/// 등록된 바로가기와 전경 창의 프로세스를 매칭해
/// 타이머를 자동으로 start/resume/pause 하는 컨트롤러.
///
/// 매칭 규칙 (플랫폼별 정규화는 [PlatformIntegrationService.isPathMatch] /
/// [PlatformIntegrationService.isBrowserPath]가 담당):
/// - `type == 'app'`: 바로가기 target과 전경 프로세스 경로 비교.
/// - `type == 'web'`: 전경 프로세스가 브라우저인지 여부로 판정.
///
/// 결정 로직:
/// - 매칭된 바로가기가 현재 활성 카테고리와 동일 → paused면 resume, running이면 유지.
/// - 타이머 idle + 매칭된 바로가기 `autoStart == true` → 새 카테고리 start.
/// - 타이머 활성(running/paused) + 다른 카테고리 앱 포커스 → running이면 pause만 (전환 없음).
/// - 매칭 없음 + running → pause.
class AutoTimerController {
  AutoTimerController({
    required this.ref,
    required this.integration,
    required this.shortcutsStream,
    required this.canFocusAutoTimer,
  });

  final Ref ref;
  final PlatformIntegrationService integration;
  final Stream<List<Shortcut>> shortcutsStream;
  final bool canFocusAutoTimer;

  TimerService get _timer => ref.read(timerServiceProvider.notifier);
  TimerState get _state => ref.read(timerServiceProvider);

  StreamSubscription<String?>? _focusSub;
  StreamSubscription<List<Shortcut>>? _scSub;

  List<Shortcut> _shortcuts = const [];
  bool _enabled = false;

  void enable() {
    if (_enabled) return;
    if (!canFocusAutoTimer) return;
    _enabled = true;

    _scSub = shortcutsStream.listen((scs) {
      _shortcuts = scs;
    });

    integration.startForegroundWatch();
    _focusSub = integration.foregroundExecutable.listen(_onFocusChanged);
  }

  void disable() {
    if (!_enabled) return;
    _enabled = false;
    integration.stopForegroundWatch();
    _focusSub?.cancel();
    _scSub?.cancel();
    _focusSub = null;
    _scSub = null;
  }

  Future<void> dispose() async {
    disable();
    // foreground watch dispose는 provider 단에서 일괄 처리
  }

  void _onFocusChanged(String? exePath) {
    if (!_enabled) return;
    final matched = _matchShortcut(exePath);
    _apply(matched);
  }

  Shortcut? _matchShortcut(String? exePath) {
    if (exePath == null || exePath.isEmpty) return null;
    final activeCategoryId = _state.activeCategoryId;
    if (activeCategoryId == null) return null;

    final isBrowserFg = integration.isBrowserPath(exePath);

    for (final sc
        in _shortcuts.where((s) => s.categoryId == activeCategoryId)) {
      if (sc.type == 'app') {
        if (integration.isPathMatch(sc.target, exePath)) return sc;
      } else if (sc.type == 'web' && isBrowserFg) {
        return sc;
      }
    }
    return null;
  }

  void _apply(Shortcut? matched) {
    final state = _state;
    if (state.isIdle) return;

    if (matched == null) {
      if (state.isRunning) _timer.pause();
      return;
    }

    // matched는 항상 activeCategoryId 소속 — 일시정지 상태면 resume
    if (state.isPaused) _timer.start(matched.categoryId);
  }
}
