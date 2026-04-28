import 'dart:io';

class InstalledApp {
  const InstalledApp({required this.name, required this.path});
  final String name;
  final String path;
}

class InstalledAppsService {
  static const _script = r'''
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

  Future<List<InstalledApp>> fetchInstalledApps() async {
    if (!Platform.isWindows) return const [];

    final result = await Process.run(
      'powershell',
      ['-NoProfile', '-NonInteractive', '-Command', _script],
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
}
