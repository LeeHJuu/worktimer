import 'dart:async';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:worktimer/core/database/app_database.dart';
import 'package:worktimer/core/logging/app_logger.dart';
import 'package:worktimer/features/timer/data/i_timer_repository.dart';
import 'package:worktimer/features/timer/data/timer_repository.dart';
import 'package:worktimer/core/database/database_provider.dart';
import 'package:worktimer/core/platform/platform_integration_provider.dart';
import 'package:worktimer/features/timer/data/shortcut_launch_result.dart';
import 'package:worktimer/features/timer/data/timer_state.dart';

export 'package:worktimer/features/timer/data/shortcut_launch_result.dart';
export 'package:worktimer/features/timer/data/timer_state.dart';

// ─────────────────────────────────────────────
// TimerService — Notifier
// ─────────────────────────────────────────────

class TimerService extends Notifier<TimerState> {
  Timer? _ticker;
  Timer? _heartbeatTimer;

  /// 진행 중 세션의 durationSec을 DB에 주기적으로 백업하는 간격.
  /// 비정상 종료(앱 강제종료, OS 셧다운 등)가 일어나도 이 간격까지의 정확도로
  /// 작업 시간이 보존된다. 너무 짧으면 DB write 부담, 너무 길면 손실량 증가.
  static const _heartbeatInterval = Duration(minutes: 5);

  /// 비정상 종료된 세션을 복구할 때, durationSec 백업이 없는 경우(첫 heartbeat 이전)
  /// wall-clock 차이에 적용하는 안전 상한. 한 세션이 이보다 길게 진행됐다고
  /// 추정하는 건 거의 항상 사용자가 stop을 안 누른 채 PC를 꺼둔 케이스다.
  static const _maxRecoveryWithoutHeartbeat = Duration(hours: 4);

  @override
  TimerState build() {
    ref.onDispose(() {
      _cancelTicker();
      _cancelHeartbeat();
    });
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
    AppLog.i('start categoryId=$categoryId currentStatus=${state.status} active=${state.activeCategoryId}');
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
    _cancelHeartbeat();
    state = state.copyWith(status: TimerStatus.paused);
  }

  /// 재개 (paused → running)
  void resume() {
    if (!state.isPaused) return;
    state = state.copyWith(status: TimerStatus.running);
    _startTicker();
    _startHeartbeat();
  }

  /// 정지 (running/paused → idle) + DB 세션 종료
  Future<void> stop() async {
    AppLog.i('stop currentStatus=${state.status} sessionId=${state.activeSessionId} elapsed=${state.elapsedSeconds}s');
    if (state.isIdle) return;
    _cancelTicker();
    _cancelHeartbeat();
    await _saveCurrentSession();
    state = const TimerState();
  }

  /// 카테고리 전환 — 기존 세션 종료 후 새 세션 시작
  Future<void> switchCategory(int newCategoryId) async {
    AppLog.i('switchCategory $newCategoryId (from ${state.activeCategoryId})');
    if (state.isIdle) {
      await start(newCategoryId);
      return;
    }
    await stop();
    await start(newCategoryId);
  }

  // ── 앱 시작 시 미종료 세션 복구 ────────────

  /// 비정상 종료된 세션을 복구한다.
  ///
  /// heartbeat가 한 번이라도 돌았으면 그 값(`durationSec`)을 신뢰하고
  /// `endedAt = startedAt + durationSec`으로 닫는다. 그렇지 않으면
  /// (heartbeat 이전에 죽은 짧은 세션) wall-clock 차이를 사용하되
  /// `_maxRecoveryWithoutHeartbeat`로 cap한다 — 사용자가 stop을 안 누르고
  /// PC를 꺼둔 케이스에서 시간이 비현실적으로 부풀어 오르는 걸 방지.
  Future<void> recoverOpenSessions() async {
    try {
      final openSessions = await _repo.findOpenSessions();
      if (openSessions.isEmpty) {
        AppLog.i('recoverOpenSessions: no open sessions');
        return;
      }
      AppLog.i('recoverOpenSessions: closing ${openSessions.length} session(s)');

      final now = _nowTs();
      final maxCapSec = _maxRecoveryWithoutHeartbeat.inSeconds;

      for (final s in openSessions) {
        final wallClock = now - s.startedAt;
        final heartbeat = s.durationSec;

        int duration;
        int endedAt;
        if (heartbeat != null && heartbeat > 0) {
          // heartbeat 있음 — 마지막으로 살아있던 시점까지의 정확한 값
          duration = heartbeat;
          endedAt = s.startedAt + heartbeat;
          AppLog.i('  recover id=${s.id} heartbeat=${duration}s '
              '(wall-clock was ${wallClock}s)');
        } else if (wallClock <= 0) {
          duration = 0;
          endedAt = s.startedAt;
          AppLog.w('  recover id=${s.id} negative wall-clock=$wallClock — clamped to 0');
        } else if (wallClock > maxCapSec) {
          // heartbeat 없는데 너무 긴 시간 — 사용자가 stop 안 누른 채 PC 꺼둔 케이스로 추정
          duration = maxCapSec;
          endedAt = s.startedAt + maxCapSec;
          AppLog.w('  recover id=${s.id} no heartbeat, wall-clock=${wallClock}s '
              '> cap ${maxCapSec}s — capped');
        } else {
          duration = wallClock;
          endedAt = now;
          AppLog.i('  recover id=${s.id} no heartbeat, wall-clock=${duration}s (within cap)');
        }

        await _repo.endSession(
          id: s.id,
          endedAt: endedAt,
          durationSec: duration,
        );
      }
    } catch (e, st) {
      AppLog.e('recoverOpenSessions failed', e, st);
    }
  }

  // ── 내부: 바로가기 실행 ───────────────────

  Future<ShortcutLaunchResult> _launch(Shortcut shortcut) async {
    AppLog.i('launch shortcut id=${shortcut.id} type=${shortcut.type} target=${shortcut.target}');
    try {
      if (shortcut.type == 'web') return await _launchWeb(shortcut.target);
      if (shortcut.type == 'app') {
        return await ref
            .read(platformIntegrationServiceProvider)
            .launchApp(shortcut.target);
      }
      AppLog.w('unknown shortcut type: ${shortcut.type}');
      return ShortcutLaunchResult.failure('알 수 없는 타입: ${shortcut.type}');
    } catch (e, st) {
      AppLog.e('shortcut launch threw', e, st);
      return ShortcutLaunchResult.failure(e.toString());
    }
  }

  Future<ShortcutLaunchResult> _launchWeb(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) {
      AppLog.w('invalid web URL: $url');
      return ShortcutLaunchResult.failure('유효하지 않은 URL: $url');
    }
    if (!await canLaunchUrl(uri)) {
      AppLog.w('canLaunchUrl false: $url');
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
    _startHeartbeat();
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

  void _startHeartbeat() {
    _cancelHeartbeat();
    _heartbeatTimer = Timer.periodic(_heartbeatInterval, (_) async {
      final sessionId = state.activeSessionId;
      if (sessionId == null || !state.isRunning) return;
      try {
        await _repo.heartbeatSession(
          id: sessionId,
          durationSec: state.elapsedSeconds,
        );
      } catch (e, st) {
        AppLog.w('heartbeat failed sessionId=$sessionId', e, st);
      }
    });
  }

  void _cancelHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  Future<void> _saveCurrentSession() async {
    final sessionId = state.activeSessionId;
    if (sessionId == null) return;
    final now = _nowTs();
    try {
      await _repo.endSession(
        id: sessionId,
        endedAt: now,
        durationSec: state.elapsedSeconds,
      );
    } catch (e, st) {
      AppLog.e('endSession failed sessionId=$sessionId', e, st);
    }
  }

  int _nowTs() => DateTime.now().millisecondsSinceEpoch ~/ 1000;
}

// ─────────────────────────────────────────────
// Provider
// ─────────────────────────────────────────────

final timerServiceProvider =
    NotifierProvider<TimerService, TimerState>(TimerService.new);
