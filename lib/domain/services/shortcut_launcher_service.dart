import 'dart:io';
import 'package:url_launcher/url_launcher.dart';
import '../../data/database/app_database.dart';
import 'shortcut_launch_result.dart';

export 'shortcut_launch_result.dart';

/// 바로가기 실행 서비스
/// 웹 URL은 url_launcher, exe는 dart:io Process.run 사용
class ShortcutLauncherService {
  const ShortcutLauncherService();

  /// 바로가기 실행
  /// [shortcut.type] == 'web' → 브라우저 열기
  /// [shortcut.type] == 'exe' → 프로세스 실행
  Future<ShortcutLaunchResult> launch(Shortcut shortcut) async {
    try {
      if (shortcut.type == 'web') {
        return await _launchWeb(shortcut.target);
      } else if (shortcut.type == 'exe') {
        return await _launchExe(shortcut.target);
      } else {
        return ShortcutLaunchResult.failure('알 수 없는 타입: ${shortcut.type}');
      }
    } catch (e) {
      return ShortcutLaunchResult.failure(e.toString());
    }
  }

  Future<ShortcutLaunchResult> _launchWeb(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) {
      return ShortcutLaunchResult.failure('유효하지 않은 URL: $url');
    }

    final canLaunch = await canLaunchUrl(uri);
    if (!canLaunch) {
      return ShortcutLaunchResult.failure('URL을 열 수 없습니다: $url');
    }

    await launchUrl(uri, mode: LaunchMode.externalApplication);
    return ShortcutLaunchResult.success();
  }

  Future<ShortcutLaunchResult> _launchExe(String exePath) async {
    // exe 실행은 Windows 전용
    if (!Platform.isWindows) {
      return ShortcutLaunchResult.failure('exe 실행은 Windows에서만 지원됩니다.');
    }

    final file = File(exePath);
    if (!file.existsSync()) {
      return ShortcutLaunchResult.failure('파일을 찾을 수 없습니다: $exePath');
    }

    /// Process.run 대신 Process.start로 비동기 실행 (앱이 블록되지 않음)
    await Process.start(exePath, [], runInShell: false);
    return ShortcutLaunchResult.success();
  }
}

