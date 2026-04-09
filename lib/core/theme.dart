import 'package:flutter/material.dart';

// ── 테마 모드 열거형 ────────────────────────────────────────
enum AppThemeMode { dark, light, custom }

// ── 테마 설정 데이터 클래스 ──────────────────────────────────
class AppThemeConfig {
  const AppThemeConfig({
    this.mode = AppThemeMode.dark,
    this.seedColorHex = '#6C63FF',
    this.customBrightness = Brightness.dark,
  });

  final AppThemeMode mode;
  final String seedColorHex;

  /// 커스텀 모드에서만 사용되는 밝기 설정
  final Brightness customBrightness;

  Color get seedColor {
    try {
      final h = seedColorHex.replaceAll('#', '');
      return Color(int.parse('FF$h', radix: 16));
    } catch (_) {
      return const Color(0xFF6C63FF);
    }
  }

  Brightness get brightness {
    switch (mode) {
      case AppThemeMode.light:
        return Brightness.light;
      case AppThemeMode.dark:
        return Brightness.dark;
      case AppThemeMode.custom:
        return customBrightness;
    }
  }

  AppThemeConfig copyWith({
    AppThemeMode? mode,
    String? seedColorHex,
    Brightness? customBrightness,
  }) {
    return AppThemeConfig(
      mode: mode ?? this.mode,
      seedColorHex: seedColorHex ?? this.seedColorHex,
      customBrightness: customBrightness ?? this.customBrightness,
    );
  }
}

// ── 테마 빌더 ────────────────────────────────────────────────
class AppTheme {
  AppTheme._();

  static ThemeData buildTheme(AppThemeConfig config) {
    switch (config.mode) {
      case AppThemeMode.dark:
        return darkTheme;
      case AppThemeMode.light:
        return lightTheme;
      case AppThemeMode.custom:
        return customTheme(config.seedColor, config.brightness);
    }
  }

  // ── 다크 테마 ────────────────────────────────────────────
  static ThemeData get darkTheme {
    const seedColor = Color(0xFF6C63FF);
    final cs = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.dark,
    );
    return _buildThemeData(cs);
  }

  // ── 라이트(파스텔) 테마 ─────────────────────────────────
  static ThemeData get lightTheme {
    const seedColor = Color(0xFF7B6CF6);
    final cs = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.light,
    ).copyWith(
      surface: const Color(0xFFF8F7FF),
      surfaceContainerHighest: const Color(0xFFEEECFF),
    );
    return _buildThemeData(cs);
  }

  // ── 커스텀 테마 ──────────────────────────────────────────
  static ThemeData customTheme(Color seedColor, Brightness brightness) {
    final cs = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: brightness,
    );
    return _buildThemeData(cs);
  }

  // ── 공통 ThemeData 빌더 ──────────────────────────────────
  static ThemeData _buildThemeData(ColorScheme cs) {
    final isDark = cs.brightness == Brightness.dark;

    return ThemeData(
      useMaterial3: true,
      colorScheme: cs,
      scaffoldBackgroundColor:
          isDark ? const Color(0xFF1A1A2E) : const Color(0xFFF5F4FF),
      cardTheme: CardThemeData(
        color: isDark ? const Color(0xFF16213E) : Colors.white,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: isDark ? const Color(0xFF2A2A4A) : const Color(0xFFE0DEFF),
        thickness: 1,
      ),
      textTheme: TextTheme(
        headlineMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : const Color(0xFF1A1A2E),
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white : const Color(0xFF1A1A2E),
        ),
        titleMedium: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: isDark ? Colors.white : const Color(0xFF1A1A2E),
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: isDark ? const Color(0xFFB0B0C8) : const Color(0xFF5A5A7A),
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          color: isDark ? const Color(0xFF8888AA) : const Color(0xFF7A7A9A),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark
            ? const Color(0xFF1E1E3A)
            : const Color(0xFFF0EEFF),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: cs.primary,
          foregroundColor: cs.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}
