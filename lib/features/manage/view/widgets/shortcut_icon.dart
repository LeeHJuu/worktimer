import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:worktimer/core/database/app_database.dart';
import 'package:worktimer/features/manage/data/icon_provider.dart';

/// 바로가기 아이콘 위젯.
/// - web: Google Favicon Service에서 파비콘 표시
/// - app: .exe에서 추출한 PNG 아이콘 표시
/// 로드 실패 시 Material 폴백 아이콘으로 대체.
class ShortcutIconWidget extends ConsumerWidget {
  const ShortcutIconWidget({
    super.key,
    required this.shortcut,
    this.size = 16,
    this.withBackground = false,
  });

  final Shortcut shortcut;
  final double size;

  /// true면 32×32 컨테이너(둥근 모서리 + 배경색)로 감쌈.
  final bool withBackground;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isWeb = shortcut.type == 'web';
    final color = isWeb ? Colors.blue : Colors.orange;

    Widget icon;
    if (isWeb) {
      icon = _buildWebIcon(color);
    } else {
      icon = _buildAppIcon(ref, color);
    }

    if (!withBackground) return icon;

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Center(child: icon),
    );
  }

  Widget _buildWebIcon(Color fallbackColor) {
    final url = _faviconUrl();
    if (url == null) return _fallback(fallbackColor);

    return Image.network(
      url,
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => _fallback(fallbackColor),
    );
  }

  Widget _buildAppIcon(WidgetRef ref, Color fallbackColor) {
    final iconAsync = ref.watch(
      appIconPathProvider((id: shortcut.id, exePath: shortcut.target)),
    );

    return iconAsync.when(
      data: (path) {
        if (path == null) return _fallback(fallbackColor);
        return Image.file(
          File(path),
          width: size,
          height: size,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => _fallback(fallbackColor),
        );
      },
      loading: () => _fallback(fallbackColor),
      error: (_, __) => _fallback(fallbackColor),
    );
  }

  String? _faviconUrl() {
    final uri = Uri.tryParse(shortcut.target);
    if (uri == null || uri.host.isEmpty) return null;
    return 'https://www.google.com/s2/favicons?domain=${uri.host}&sz=32';
  }

  Widget _fallback(Color color) => Icon(
        shortcut.type == 'web'
            ? Icons.language_outlined
            : Icons.apps_outlined,
        size: size,
        color: color,
      );
}
