import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database/app_database.dart';
import '../../presentation/providers/timer_provider.dart';
import 'focus_watcher_service.dart';
import 'timer_service.dart';

/// 등록된 바로가기와 전경 창의 프로세스를 매칭해
/// 타이머를 자동으로 start/resume/pause 하는 컨트롤러.
///
/// 매칭 규칙:
/// - `type == 'exe'`: 바로가기의 target 절대경로와 전경 프로세스 경로 비교.
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
    required this.focusWatcher,
    required this.shortcutsStream,
  });

  final Ref ref;
  final FocusWatcherService focusWatcher;
  final Stream<List<Shortcut>> shortcutsStream;

  TimerService get _timer => ref.read(timerServiceProvider.notifier);
  TimerState get _state => ref.read(timerServiceProvider);

  StreamSubscription<String?>? _focusSub;
  StreamSubscription<List<Shortcut>>? _scSub;

  List<Shortcut> _shortcuts = const [];
  bool _enabled = false;

  static const _browserExes = {
    'chrome.exe',
    'msedge.exe',
    'firefox.exe',
    'brave.exe',
    'opera.exe',
    'whale.exe',
    'vivaldi.exe',
  };

  void enable() {
    if (_enabled) return;
    if (!Platform.isWindows) return;
    _enabled = true;

    _scSub = shortcutsStream.listen((scs) {
      _shortcuts = scs;
    });

    focusWatcher.start();
    _focusSub = focusWatcher.foregroundExePath.listen(_onFocusChanged);
  }

  void disable() {
    if (!_enabled) return;
    _enabled = false;
    focusWatcher.stop();
    _focusSub?.cancel();
    _scSub?.cancel();
    _focusSub = null;
    _scSub = null;
  }

  Future<void> dispose() async {
    disable();
    await focusWatcher.dispose();
  }

  void _onFocusChanged(String? exePath) {
    if (!_enabled) return;
    final matched = _matchShortcut(exePath);
    _apply(matched);
  }

  Shortcut? _matchShortcut(String? exePath) {
    if (exePath == null || exePath.isEmpty) return null;
    final normalizedFg = _normalizePath(exePath);
    final baseNameFg = _baseName(exePath).toLowerCase();
    final isBrowserFg = _browserExes.contains(baseNameFg);

    for (final sc in _shortcuts) {
      if (sc.type == 'exe') {
        if (_normalizePath(sc.target) == normalizedFg) return sc;
      } else if (sc.type == 'web' && isBrowserFg) {
        return sc;
      }
    }
    return null;
  }

  void _apply(Shortcut? matched) {
    final state = _state;

    // 등록된 앱이 포커스되지 않음 → 실행 중이면 pause
    if (matched == null) {
      if (state.isRunning) _timer.pause();
      return;
    }

    final matchedCategoryId = matched.categoryId;

    // 현재 활성 카테고리와 동일 → 일시정지 상태면 resume
    if (state.activeCategoryId == matchedCategoryId) {
      if (state.isPaused) _timer.start(matchedCategoryId);
      return;
    }

    // 타이머가 idle 상태일 때만 autoStart로 새 카테고리 시작.
    // 이미 타이머가 활성(running/paused)이면 카테고리를 강제 전환하지 않는다.
    // → 수동으로 선택한 카테고리 타이머를 자동으로 덮어쓰는 버그를 방지.
    if (state.isIdle) {
      if (matched.autoStart) _timer.start(matchedCategoryId);
      return;
    }

    // 다른 카테고리의 앱이 포커스됐지만 타이머가 이미 활성 상태:
    // running이면 pause만 (카테고리 전환 없음).
    if (state.isRunning) _timer.pause();
  }

  String _normalizePath(String p) => p.replaceAll('/', '\\').toLowerCase();

  String _baseName(String p) {
    final norm = p.replaceAll('/', '\\');
    final i = norm.lastIndexOf('\\');
    return i < 0 ? norm : norm.substring(i + 1);
  }
}
