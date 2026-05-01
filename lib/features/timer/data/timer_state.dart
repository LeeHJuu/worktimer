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
