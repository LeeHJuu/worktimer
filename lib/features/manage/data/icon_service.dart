import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'package:worktimer/core/logging/app_logger.dart';
import 'package:worktimer/core/platform/platform_integration_service.dart';

class IconService {
  IconService(this._platform);

  final PlatformIntegrationService _platform;

  static const _iconDirName = 'shortcut_icons';

  Future<Directory> _cacheDir() async {
    final base = await getApplicationSupportDirectory();
    final dir = Directory(p.join(base.path, _iconDirName));
    if (!dir.existsSync()) {
      try {
        await dir.create(recursive: true);
      } catch (e, st) {
        AppLog.e('icon cacheDir create failed: ${dir.path}', e, st);
        rethrow;
      }
    }
    return dir;
  }

  /// web 타입 바로가기용 파비콘 URL 반환. 파싱 실패 시 null.
  String? faviconUrl(String target) {
    final uri = Uri.tryParse(target);
    if (uri == null || uri.host.isEmpty) return null;
    return 'https://www.google.com/s2/favicons?domain=${uri.host}&sz=32';
  }

  /// app 타입 바로가기용 아이콘 파일 경로 반환.
  /// 캐시가 있으면 즉시 반환, 없으면 추출 후 반환. 실패 시 null.
  Future<String?> resolveAppIconPath(int shortcutId, String exePath) async {
    final dir = await _cacheDir();
    final pngPath = p.join(dir.path, '$shortcutId.png');

    if (File(pngPath).existsSync()) return pngPath;
    if (!File(exePath).existsSync()) {
      AppLog.w('resolveAppIcon: exe not found id=$shortcutId path=$exePath');
      return null;
    }

    final ok = await _platform.extractAppIcon(exePath, pngPath);
    if (!ok) {
      AppLog.w('resolveAppIcon: extract failed id=$shortcutId exe=$exePath');
    }
    return ok ? pngPath : null;
  }

  /// 캐시된 아이콘 파일 삭제 (바로가기 수정/삭제 시 호출).
  Future<void> invalidate(int shortcutId) async {
    final dir = await _cacheDir();
    final file = File(p.join(dir.path, '$shortcutId.png'));
    if (file.existsSync()) await file.delete();
  }
}
