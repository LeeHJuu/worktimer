import '../shortcut_launch_result.dart';
import 'installed_app.dart';

export '../shortcut_launch_result.dart';
export 'installed_app.dart';

/// 플랫폼 의존 통합 기능의 단일 façade.
///
/// 호출부(`UI`, `AutoTimerController`, `TimerService`)는 이 인터페이스만 의존하며,
/// 플랫폼별 분기는 [platformIntegrationServiceProvider]가 담당한다.
///
/// 구현체:
///  - [WindowsIntegrationService] — Windows COM/Win32/PowerShell
///  - [NoopIntegrationService]    — 비지원 플랫폼(false / 빈 결과 / 닫힌 stream)
///  - macOS 구현체는 추후 PR (osascript / NSWorkspace / launchctl)
///
/// 향후 macOS 구현체가 한 클래스에 ~300줄을 넘기 시작하면
/// `AppLauncher` / `InstalledAppsSource` / `FocusSource` / `SystemIntegration` 으로
/// 내부 분리 (이 façade는 그대로 유지).
abstract class PlatformIntegrationService {
  // ── 데스크톱 통합 ────────────────────────────
  Future<bool> hasDesktopShortcut();
  Future<void> setDesktopShortcut(bool enabled);
  Future<bool> isStartupEnabled();
  Future<void> setStartup(bool enabled);

  // ── 앱 실행 ─────────────────────────────────
  Future<ShortcutLaunchResult> launchApp(String absolutePath);

  /// .exe 파일에서 아이콘을 추출해 [outputPngPath]에 PNG로 저장.
  /// 성공 시 true, 실패 시 false 반환 (예외 throw 안 함).
  Future<bool> extractAppIcon(String exePath, String outputPngPath);

  // ── 설치된 앱 목록 ───────────────────────────
  Future<List<InstalledApp>> fetchInstalledApps();

  // ── 전경 창 감시 (auto-timer) ───────────────
  Stream<String?> get foregroundExecutable;
  void startForegroundWatch();
  void stopForegroundWatch();
  Future<void> disposeForegroundWatch();

  // ── 매칭 헬퍼 (플랫폼별 정규화) ──────────────
  /// 바로가기 target과 전경 실행파일 경로가 같은 앱을 가리키는지.
  bool isPathMatch(String shortcutTarget, String foregroundPath);

  /// 전경 실행파일이 (등록된) 브라우저 계열인지 — `type='web'` 매칭에 사용.
  bool isBrowserPath(String foregroundPath);
}
