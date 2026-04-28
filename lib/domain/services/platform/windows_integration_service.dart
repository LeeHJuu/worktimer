import 'dart:async';
import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';

import '../shortcut_launch_result.dart';
import 'installed_app.dart';
import 'platform_integration_service.dart';

/// Windows용 통합 기능 구현체.
///
/// 흡수한 기존 클래스들:
///  - 구 `WindowsIntegrationService`  → 데스크톱/시작프로그램 .lnk 관리
///  - 구 `FocusWatcherService`        → 전경 창 폴링 (Win32 FFI)
///  - 구 `InstalledAppsService`       → 시작 메뉴 .lnk 스캔으로 설치 앱 검색
class WindowsIntegrationService implements PlatformIntegrationService {
  WindowsIntegrationService({
    this.foregroundPollInterval = const Duration(seconds: 1),
  });

  final Duration foregroundPollInterval;

  // ── 전경 창 감시 상태 ─────────────────────────
  final _foregroundController = StreamController<String?>.broadcast();
  Timer? _foregroundTimer;
  String? _lastForegroundPath;
  bool _foregroundStarted = false;
  bool _disposed = false;

  // ── 매칭 ──────────────────────────────────────
  static const _browserExes = {
    'chrome.exe',
    'msedge.exe',
    'firefox.exe',
    'brave.exe',
    'opera.exe',
    'whale.exe',
    'vivaldi.exe',
  };

  // ── 데스크톱 통합 (.lnk 파일) ────────────────────────────────

  String get _exePath => Platform.resolvedExecutable;

  Future<String> _desktopPath() async {
    final r = await Process.run('powershell', [
      '-NoProfile',
      '-Command',
      '[Environment]::GetFolderPath("Desktop")',
    ]);
    return r.stdout.toString().trim();
  }

  Future<String> _startupPath() async {
    final r = await Process.run('powershell', [
      '-NoProfile',
      '-Command',
      '[Environment]::GetFolderPath("Startup")',
    ]);
    return r.stdout.toString().trim();
  }

  @override
  Future<bool> hasDesktopShortcut() async {
    final path = '${await _desktopPath()}\\WorkTimer.lnk';
    return File(path).exists();
  }

  @override
  Future<bool> isStartupEnabled() async {
    final path = '${await _startupPath()}\\WorkTimer.lnk';
    return File(path).exists();
  }

  @override
  Future<void> setDesktopShortcut(bool enabled) async {
    final path = '${await _desktopPath()}\\WorkTimer.lnk';
    if (enabled) {
      await _createShortcut(path);
    } else {
      final f = File(path);
      if (await f.exists()) await f.delete();
    }
  }

  @override
  Future<void> setStartup(bool enabled) async {
    final path = '${await _startupPath()}\\WorkTimer.lnk';
    if (enabled) {
      await _createShortcut(path);
    } else {
      final f = File(path);
      if (await f.exists()) await f.delete();
    }
  }

  Future<void> _createShortcut(String shortcutPath) async {
    final exe = _exePath;
    final workDir = File(exe).parent.path;
    final script = [
      r'$ws = New-Object -ComObject WScript.Shell',
      "\$s = \$ws.CreateShortcut('$shortcutPath')",
      "\$s.TargetPath = '$exe'",
      "\$s.WorkingDirectory = '$workDir'",
      "\$s.Description = 'WorkTimer'",
      r'$s.Save()',
    ].join('; ');

    final result = await Process.run('powershell', [
      '-NoProfile',
      '-Command',
      script,
    ]);
    if (result.exitCode != 0) {
      throw Exception('바로가기 생성 실패: ${result.stderr}');
    }
  }

  // ── 앱 실행 ─────────────────────────────────

  @override
  Future<ShortcutLaunchResult> launchApp(String absolutePath) async {
    if (!File(absolutePath).existsSync()) {
      return ShortcutLaunchResult.failure('파일을 찾을 수 없습니다: $absolutePath');
    }
    try {
      await Process.start(absolutePath, [], runInShell: false);
      return ShortcutLaunchResult.success();
    } catch (e) {
      return ShortcutLaunchResult.failure(e.toString());
    }
  }

  // ── 설치된 앱 목록 ───────────────────────────

  static const _installedAppsScript = r'''
$ws = New-Object -ComObject WScript.Shell;
$dirs = @(
  [Environment]::GetFolderPath('Programs'),
  [Environment]::GetFolderPath('CommonPrograms')
);
$results = @();
foreach ($dir in $dirs) {
  if (-not (Test-Path $dir)) { continue }
  Get-ChildItem -Path $dir -Recurse -Filter *.lnk -ErrorAction SilentlyContinue | ForEach-Object {
    try {
      $lnk = $ws.CreateShortcut($_.FullName);
      $target = $lnk.TargetPath;
      if ($target -and $target.ToLower().EndsWith('.exe') -and (Test-Path $target)) {
        $results += ($_.BaseName + '|' + $target)
      }
    } catch {}
  }
};
$results | Sort-Object -Unique | Write-Output
''';

  @override
  Future<List<InstalledApp>> fetchInstalledApps() async {
    final result = await Process.run(
      'powershell',
      ['-NoProfile', '-NonInteractive', '-Command', _installedAppsScript],
    );
    if (result.exitCode != 0) return const [];

    final lines = result.stdout.toString().split('\n');
    final apps = <InstalledApp>[];
    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;
      final sep = trimmed.indexOf('|');
      if (sep < 0) continue;
      final name = trimmed.substring(0, sep).trim();
      final path = trimmed.substring(sep + 1).trim();
      if (name.isNotEmpty && path.isNotEmpty) {
        apps.add(InstalledApp(name: name, path: path));
      }
    }
    apps.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return apps;
  }

  // ── 전경 창 감시 ─────────────────────────────

  @override
  Stream<String?> get foregroundExecutable => _foregroundController.stream;

  @override
  void startForegroundWatch() {
    if (_foregroundStarted || _disposed) return;
    _foregroundStarted = true;
    _foregroundTimer =
        Timer.periodic(foregroundPollInterval, (_) => _tick());
    _tick();
  }

  @override
  void stopForegroundWatch() {
    _foregroundTimer?.cancel();
    _foregroundTimer = null;
    _foregroundStarted = false;
  }

  @override
  Future<void> disposeForegroundWatch() async {
    if (_disposed) return;
    _disposed = true;
    stopForegroundWatch();
    await _foregroundController.close();
  }

  void _tick() {
    final path = _readForegroundExe();
    if (path != _lastForegroundPath) {
      _lastForegroundPath = path;
      _foregroundController.add(path);
    }
  }

  String? _readForegroundExe() {
    final hwnd = GetForegroundWindow();
    if (hwnd == 0) return null;

    final pidPtr = calloc<Uint32>();
    try {
      GetWindowThreadProcessId(hwnd, pidPtr);
      final pid = pidPtr.value;
      if (pid == 0) return null;

      const accessRights = PROCESS_QUERY_LIMITED_INFORMATION;
      final hProc = OpenProcess(accessRights, FALSE, pid);
      if (hProc == 0) return null;

      try {
        final bufLen = calloc<Uint32>()..value = 1024;
        final buf = wsalloc(1024);
        try {
          final ok = QueryFullProcessImageName(hProc, 0, buf, bufLen);
          if (ok == 0) return null;
          return buf.toDartString();
        } finally {
          free(buf);
          calloc.free(bufLen);
        }
      } finally {
        CloseHandle(hProc);
      }
    } finally {
      calloc.free(pidPtr);
    }
  }

  // ── 매칭 헬퍼 ────────────────────────────────

  @override
  bool isPathMatch(String shortcutTarget, String foregroundPath) =>
      _normalizePath(shortcutTarget) == _normalizePath(foregroundPath);

  @override
  bool isBrowserPath(String foregroundPath) {
    final base = _baseName(foregroundPath).toLowerCase();
    return _browserExes.contains(base);
  }

  String _normalizePath(String p) => p.replaceAll('/', '\\').toLowerCase();

  String _baseName(String p) {
    final norm = p.replaceAll('/', '\\');
    final i = norm.lastIndexOf('\\');
    return i < 0 ? norm : norm.substring(i + 1);
  }
}
