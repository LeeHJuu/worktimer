import 'dart:async';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/database/app_database.dart';
import '../../data/repositories/i_timer_repository.dart';
import '../../data/repositories/timer_repository.dart';
import '../../presentation/providers/database_provider.dart';

// ─────────────────────────────────────────────
// 타이머 상태
// ─────────────────────────────────────────────

enum TimerStatus { idle, running, paused }

class TimerState {
  const TimerState({
    this.status = TimerStatus.idle,
    this.activeCategoryId,
    this.activeSessionId,
    this.elapsedSeconds = 0,
    this.sessionStartedAt,
  });

  final TimerStatus status;
  final int? activeCategoryId;

  /// 현재 진행 중인 DB 세션 rowid
  final int? activeSessionId;

  /// 경과 시간 (초)
  final int elapsedSeconds;
  final int? sessionStartedAt;

  bool get isIdle => status == TimerStatus.idle;
  bool get isRunning => status == TimerStatus.running;
  bool get isPaused => status == TimerStatus.paused;

  TimerState copyWith({
    TimerStatus? status,
    int? activeCategoryId,
    int? activeSessionId,
    int? elapsedSeconds,
    int? sessionStartedAt,
    bool clearCategory = false,
    bool clearSession = false,
  }) {
    return TimerState(
      status: status ?? this.status,
      activeCategoryId:
          clearCategory ? null : (activeCategoryId ?? this.activeCategoryId),
      activeSessionId:
          clearSession ? null : (activeSessionId ?? this.activeSessionId),
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      sessionStartedAt: sessionStartedAt ?? this.sessionStartedAt,
    );
  }
}

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

  /// 타이머 시작
  /// - 일시정지 중 + 같은 카테고리 → resume()으로 이어가기
  /// - 일시정지 중 + 다른 카테고리 → 기존 세션 종료 후 새 시작
  /// - idle → 새 세션 시작
  Future<void> start(int categoryId) async {
    if (state.isPaused && state.activeCategoryId == categoryId) {
      resume();
      return;
    }
    if (state.isPaused && state.activeCategoryId != categoryId) {
      await stop();
    }
    if (state.isRunning) return;

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
