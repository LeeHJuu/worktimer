/// 앱이 지원하는 플랫폼 식별자.
enum PlatformId { windows, macos, linux, android, ios, web }

/// 플랫폼 의존 기능 플래그.
///
/// 새 기능을 추가할 때:
///  1. 이 enum에 항목 추가
///  2. [capability_registry.dart]의 `_support` 맵에 지원 플랫폼 셋 등록
///  3. UI/서비스 호출부에서 `capabilityProvider(...)`로 게이팅
enum Capability {
  // ── Core (모든 플랫폼) ─────────────────────
  timer,
  stats,
  memo,
  categories,
  settingsBasic,
  conditionLog,

  // ── 데스크톱 통합 ────────────────────────
  desktopShortcut,
  startupAutorun,
  appLaunch,
  installedAppsPicker,
  focusAutoTimer,
  miniWindowIPC,
  appUpdater,
}
