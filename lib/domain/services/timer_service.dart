import 'dart:async';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/database/app_database.dart';
import '../../data/repositories/i_timer_repository.dart';
import '../../data/repositories/timer_repository.dart';
import '../../presentation/providers/database_provider.dart';
import '../../presentation/providers/platform_integration_provider.dart';
import 'shortcut_launch_result.dart';
import 'timer_state.dart';

export 'shortcut_launch_result.dart';
export 'timer_state.dart';

// ─────────────────────────────────────────────
// TimerService — Notifier
// ─────────────────────────────────────────────

class TimerService extends Notifier<TimerState> {
  Timer? _ticker;

  @override
  TimerState build() {
    ref.onDispose(_cancelTicker);
    return const TimerState();
  }

  ITimerRepository get _repo =>
      TimerRepository(ref.read(appDatabaseProvider));

  // ── 외부 API ──────────────────────────────

  /// 바로가기 실행 + 해당 카테고리 타이머 시작 (원자적)
  Future<ShortcutLaunchResult> launchAndStart(Shortcut shortcut) async {
    final result = await _launch(shortcut);
    if (result.success) await start(shortcut.categoryId);
    return result;
  }

  /// 바로가기 실행만 (타이머 조작 없음)
  Future<ShortcutLaunchResult> launch(Shortcut shortcut) => _launch(shortcut);

  /// 타이머 시작
  /// - running + 같은 카테고리 → no-op
  /// - paused  + 같은 카테고리 → resume
  /// - running/paused + 다른 카테고리 → 기존 세션 종료 후 새 시작
  /// - idle → 새 세션 시작
  Future<void> start(int categoryId) async {
    if (state.isRunning && state.activeCategoryId == categoryId) return;
    if (state.isPaused && state.activeCategoryId == categoryId) {
      resume();
      return;
    }
    if (!state.isIdle) await stop();
    await _startNormal(categoryId);
  }

  /// 일시정지 (running → paused)
  void pause() {
    if (!state.isRunning) return;
    _cancelTicker();
    state = state.copyWith(status: TimerStatus.paused);
  }

  /// 재개 (paused → running)
  void resume() {
    if (!state.isPaused) return;
    state = state.copyWith(status: TimerStatus.running);
    _startTicker();
  }

  /// 정지 (running/paused → idle) + DB 세션 종료
  Future<void> stop() async {
    if (state.isIdle) return;
    _cancelTicker();
    await _saveCurrentSession();
    state = const TimerState();
  }

  /// 카테고리 전환 — 기존 세션 종료 후 새 세션 시작
  Future<void> switchCategory(int newCategoryId) async {
    if (state.isIdle) {
      await start(newCategoryId);
      return;
    }
    await stop();
    await start(newCategoryId);
  }

  // ── 앱 시작 시 미종료 세션 복구 ────────────

  Future<void> recoverOpenSessions() async {
    final openSessions = await _repo.findOpenSessions();
    if (openSessions.isEmpty) return;

    final now = _nowTs();
    for (final s in openSessions) {
      final duration = now - s.startedAt;
      await _repo.endSession(
        id: s.id,
        endedAt: now,
        durationSec: duration > 0 ? duration : 0,
      );
    }
  }

  // ── 내부: 바로가기 실행 ───────────────────

  Future<ShortcutLaunchResult> _launch(Shortcut shortcut) async {
    try {
      if (shortcut.type == 'web') return await _launchWeb(shortcut.target);
      if (shortcut.type == 'app') {
        return await ref
            .read(platformIntegrationServiceProvider)
            .launchApp(shortcut.target);
      }
      return ShortcutLaunchResult.failure('알 수 없는 타입: ${shortcut.type}');
    } catch (e) {
      return ShortcutLaunchResult.failure(e.toString());
    }
  }

  Future<ShortcutLaunchResult> _launchWeb(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return ShortcutLaunchResult.failure('유효하지 않은 URL: $url');
    if (!await canLaunchUrl(uri)) {
      return ShortcutLaunchResult.failure('URL을 열 수 없습니다: $url');
    }
    await launchUrl(uri, mode: LaunchMode.externalApplication);
    return ShortcutLaunchResult.success();
  }

  // ── 내부: 타이머 시작 ─────────────────────

  Future<void> _startNormal(int categoryId) async {
    final now = _nowTs();
    final sessionId = await _repo.insertSession(
      TimerSessionsCompanion.insert(
        categoryId: categoryId,
        startedAt: now,
        mode: 'normal',
        isFocus: const Value(true),
      ),
    );

    state = TimerState(
      status: TimerStatus.running,
      activeCategoryId: categoryId,
      activeSessionId: sessionId,
      elapsedSeconds: 0,
      sessionStartedAt: now,
    );

    _startTicker();
  }

  // ── 내부 헬퍼 ─────────────────────────────

  void _startTicker() {
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!state.isRunning) return;
      state = state.copyWith(elapsedSeconds: state.elapsedSeconds + 1);
    });
  }

  void _cancelTicker() {
    _ticker?.cancel();
    _ticker = null;
  }

  Future<void> _saveCurrentSession() async {
    final sessionId = state.activeSessionId;
    if (sessionId == null) return;
    final now = _nowTs();
    await _repo.endSession(
      id: sessionId,
      endedAt: now,
      durationSec: state.elapsedSeconds,
    );
  }

  int _nowTs() => DateTime.now().millisecondsSinceEpoch ~/ 1000;
}

// ─────────────────────────────────────────────
// Provider
// ─────────────────────────────────────────────

final timerServiceProvider =
    NotifierProvider<TimerService, TimerState>(TimerService.new);
