import 'package:flutter/material.dart';

// ── 테마 설정 ────────────────────────────────────────────────
class AppThemeConfig {
  const AppThemeConfig({
    this.backgroundColorHex = '#1A1A2E',
    this.accentColorHex = '#6C63FF',
  });

  /// 메인 컬러 — 배경색의 기반. 명도로 다크/라이트 자동 판단.
  final String backgroundColorHex;

  /// 서브(강조) 컬러 — primary, 버튼, 하이라이트에 사용.
  final String accentColorHex;

  Color get backgroundColor =>
      _parseHex(backgroundColorHex, const Color(0xFF1A1A2E));
  Color get accentColor => _parseHex(accentColorHex, const Color(0xFF6C63FF));

  /// 배경색 명도로 다크/라이트 자동 결정
  Brightness get brightness => backgroundColor.computeLuminance() < 0.35
      ? Brightness.dark
      : Brightness.light;

  Color _parseHex(String hex, Color fallback) {
    try {
      return Color(int.parse('FF${hex.replaceAll('#', '')}', radix: 16));
    } catch (_) {
      return fallback;
    }
  }

  AppThemeConfig copyWith({
    String? backgroundColorHex,
    String? accentColorHex,
  }) =>
      AppThemeConfig(
        backgroundColorHex: backgroundColorHex ?? this.backgroundColorHex,
        accentColorHex: accentColorHex ?? this.accentColorHex,
      );
}

// ── 테마 빌더 ────────────────────────────────────────────────
class AppTheme {
  AppTheme._();

  static ThemeData buildTheme(AppThemeConfig config) {
    final bg = config.backgroundColor;
    final accent = config.accentColor;
    final isDark = config.brightness == Brightness.dark;

    // 사용자가 지정한 색을 그대로 보존.
    // 배경/카드/스캐폴드 모두 동일한 bg 사용. 카드와 배경의 분리는 outline 으로만.
    final onBg = isDark ? Colors.white : Colors.black;
    final onAccent = accent.computeLuminance() < 0.5 ? Colors.white : Colors.black;

    final cs = ColorScheme(
      brightness: isDark ? Brightness.dark : Brightness.light,
      primary: accent,
      onPrimary: onAccent,
      secondary: accent,
      onSecondary: onAccent,
      error: const Color(0xFFE57373),
      onError: Colors.white,
      surface: bg,
      onSurface: onBg,
      surfaceContainerHighest: bg,
      outline: onBg.withValues(alpha: 0.18),
      outlineVariant: onBg.withValues(alpha: 0.10),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: cs,
      scaffoldBackgroundColor: bg,
      canvasColor: bg,
      cardTheme: CardThemeData(
        color: bg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: onBg.withValues(alpha: 0.10)),
          borderRadius: const BorderRadius.all(Radius.circular(12)),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: onBg.withValues(alpha: 0.10),
        thickness: 1,
      ),
      textTheme: TextTheme(
        headlineMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: onBg,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: onBg,
        ),
        titleMedium: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: onBg,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: onBg.withValues(alpha: 0.72),
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          color: onBg.withValues(alpha: 0.55),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: onBg.withValues(alpha: 0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: onAccent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}
