import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database/app_database.dart';
import '../../presentation/providers/timer_provider.dart';
import 'focus_watcher_service.dart';
import 'timer_service.dart';

/// 등록된 카테고리 바로가기와 전경 창의 프로세스를 매칭해
/// 타이머를 자동으로 start/resume/pause 하는 컨트롤러.
///
/// 매칭 규칙:
/// - `type == 'exe'`: 바로가기의 target 절대경로와 전경 프로세스 경로 비교 (대소문자·슬래시 정규화).
/// - `type == 'web'`: 해당 카테고리에 웹 바로가기가 하나라도 있으면
///   전경 프로세스가 브라우저(chrome/edge/firefox/brave/opera/whale/vivaldi)인지 여부로 판정.
///   URL 구분은 하지 않음.
///
/// 결정 로직:
/// - 매칭된 카테고리가 현재 활성 카테고리와 동일 → paused면 resume, running이면 유지.
/// - 매칭된 카테고리가 다르고 `autoTimerOn == true` → 현재 타이머 pause(running) 후 새 카테고리 start.
/// - 매칭된 카테고리가 다르고 `autoTimerOn == false` → running이면 pause만.
/// - 매칭 없음 + running → pause.
class AutoTimerController {
  AutoTimerController({
    required this.ref,
    required this.focusWatcher,
    required this.categoriesStream,
    required this.shortcutsStream,
  });

  final Ref ref;
  final FocusWatcherService focusWatcher;
  final Stream<List<Category>> categoriesStream;
  final Stream<List<Shortcut>> shortcutsStream;

  TimerService get _timer => ref.read(timerServiceProvider.notifier);
  TimerState get _state => ref.read(timerServiceProvider);

  StreamSubscription<String?>? _focusSub;
  StreamSubscription<List<Category>>? _catSub;
  StreamSubscription<List<Shortcut>>? _scSub;

  List<Category> _categories = const [];
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

  /// 컨트롤러 활성화 — 포커스 감시 시작.
  void enable() {
    if (_enabled) return;
    if (!Platform.isWindows) return;
    _enabled = true;

    _catSub = categoriesStream.listen((cats) {
      _categories = cats;
    });
    _scSub = shortcutsStream.listen((scs) {
      _shortcuts = scs;
    });

    focusWatcher.start();
    _focusSub = focusWatcher.foregroundExePath.listen(_onFocusChanged);
  }

  /// 컨트롤러 비활성화.
  void disable() {
    if (!_enabled) return;
    _enabled = false;
    focusWatcher.stop();
    _focusSub?.cancel();
    _catSub?.cancel();
    _scSub?.cancel();
    _focusSub = null;
    _catSub = null;
    _scSub = null;
  }

  Future<void> dispose() async {
    disable();
    await focusWatcher.dispose();
  }

  void _onFocusChanged(String? exePath) {
    if (!_enabled) return;
    final matchedCategoryId = _matchCategory(exePath);
    _apply(matchedCategoryId);
  }

  int? _matchCategory(String? exePath) {
    if (exePath == null || exePath.isEmpty) return null;
    final normalizedFg = _normalizePath(exePath);
    final baseNameFg = _baseName(exePath).toLowerCase();
    final isBrowserFg = _browserExes.contains(baseNameFg);

    for (final sc in _shortcuts) {
      if (sc.type == 'exe') {
        if (_normalizePath(sc.target) == normalizedFg) {
          return sc.categoryId;
        }
      } else if (sc.type == 'web' && isBrowserFg) {
        return sc.categoryId;
      }
    }
    return null;
  }

  void _apply(int? matchedCategoryId) {
    final state = _state;

    // 등록된 앱이 포커스되지 않음 → 실행 중이면 pause
    if (matchedCategoryId == null) {
      if (state.isRunning) _timer.pause();
      return;
    }

    // 현재 활성 카테고리와 동일 → 일시정지 상태면 resume
    if (state.activeCategoryId == matchedCategoryId) {
      if (state.isPaused) _timer.resume();
      return;
    }

    // 다른 카테고리: 매칭된 카테고리 조회
    Category? matched;
    for (final c in _categories) {
      if (c.id == matchedCategoryId) {
        matched = c;
        break;
      }
    }

    if (matched == null || !matched.autoTimerOn) {
      // 자동 시작 비활성 카테고리 → 실행 중이면 pause만
      if (state.isRunning) _timer.pause();
      return;
    }

    // autoTimerOn 카테고리에 포커스:
    // pause()는 동기 → 즉시 state가 paused로 전환.
    // start()는 (paused + 다른 카테고리) 케이스를 감지해 stop() 후 새 세션 시작.
    // idle 상태라면 start()가 곧바로 _startNormal()로 진행.
    if (state.isRunning) _timer.pause();
    _timer.start(matchedCategoryId);
  }

  String _normalizePath(String p) =>
      p.replaceAll('/', '\\').toLowerCase();

  String _baseName(String p) {
    final norm = p.replaceAll('/', '\\');
    final i = norm.lastIndexOf('\\');
    return i < 0 ? norm : norm.substring(i + 1);
  }
}
