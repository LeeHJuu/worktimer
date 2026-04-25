import 'dart:io';

/// Manages Windows desktop shortcut and startup registration.
class WindowsIntegrationService {
  String get _exePath => Platform.resolvedExecutable;

  Future<String> _desktopPath() async {
    final r = await Process.run('powershell', [
      '-NoProfile', '-Command',
      '[Environment]::GetFolderPath("Desktop")',
    ]);
    return r.stdout.toString().trim();
  }

  Future<String> _startupPath() async {
    final r = await Process.run('powershell', [
      '-NoProfile', '-Command',
      '[Environment]::GetFolderPath("Startup")',
    ]);
    return r.stdout.toString().trim();
  }

  Future<bool> hasDesktopShortcut() async {
    if (!Platform.isWindows) return false;
    final path = '${await _desktopPath()}\\WorkTimer.lnk';
    return File(path).exists();
  }

  Future<bool> isStartupEnabled() async {
    if (!Platform.isWindows) return false;
    final path = '${await _startupPath()}\\WorkTimer.lnk';
    return File(path).exists();
  }

  Future<void> setDesktopShortcut(bool enabled) async {
    if (!Platform.isWindows) return;
    final path = '${await _desktopPath()}\\WorkTimer.lnk';
    if (enabled) {
      await _createShortcut(path);
    } else {
      final f = File(path);
      if (await f.exists()) await f.delete();
    }
  }

  Future<void> setStartup(bool enabled) async {
    if (!Platform.isWindows) return;
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
      '-NoProfile', '-Command', script,
    ]);
    if (result.exitCode != 0) {
      throw Exception('바로가기 생성 실패: ${result.stderr}');
    }
  }
}
