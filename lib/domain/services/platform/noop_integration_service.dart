import 'dart:async';

import '../shortcut_launch_result.dart';
import 'installed_app.dart';
import 'platform_integration_service.dart';

/// 비지원 플랫폼용 — 모든 메서드가 즉시 false / 빈 결과 / 닫힌 stream을 반환.
class NoopIntegrationService implements PlatformIntegrationService {
  NoopIntegrationService();

  final _foregroundController = StreamController<String?>.broadcast();
  bool _disposed = false;

  @override
  Future<bool> hasDesktopShortcut() async => false;

  @override
  Future<void> setDesktopShortcut(bool enabled) async {}

  @override
  Future<bool> isStartupEnabled() async => false;

  @override
  Future<void> setStartup(bool enabled) async {}

  @override
  Future<ShortcutLaunchResult> launchApp(String absolutePath) async =>
      ShortcutLaunchResult.failure('앱 실행은 이 플랫폼에서 지원되지 않습니다.');

  @override
  Future<List<InstalledApp>> fetchInstalledApps() async => const [];

  @override
  Future<bool> extractAppIcon(String exePath, String outputPngPath) async =>
      false;

  @override
  Stream<String?> get foregroundExecutable => _foregroundController.stream;

  @override
  void startForegroundWatch() {}

  @override
  void stopForegroundWatch() {}

  @override
  Future<void> disposeForegroundWatch() async {
    if (_disposed) return;
    _disposed = true;
    await _foregroundController.close();
  }

  @override
  bool isPathMatch(String shortcutTarget, String foregroundPath) => false;

  @override
  bool isBrowserPath(String foregroundPath) => false;
}
