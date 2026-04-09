import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../data/repositories/settings_repository.dart';
import 'database_provider.dart';

// ── ThemeNotifier ────────────────────────────────────────────

class ThemeNotifier extends Notifier<AppThemeConfig> {
  @override
  AppThemeConfig build() {
    // 비동기 초기화 후 상태를 업데이트
    _loadFromStorage();
    return const AppThemeConfig();
  }

  SettingsRepository get _settings =>
      SettingsRepository(ref.read(appDatabaseProvider));

  Future<void> _loadFromStorage() async {
    final modeStr = await _settings.get('theme_mode', defaultValue: 'dark');
    final colorHex =
        await _settings.get('theme_seed_color', defaultValue: '#6C63FF');
    final brightnessStr =
        await _settings.get('theme_brightness', defaultValue: 'dark');

    AppThemeMode mode = AppThemeMode.dark;
    if (modeStr == 'light') mode = AppThemeMode.light;
    if (modeStr == 'custom') mode = AppThemeMode.custom;

    final brightness =
        brightnessStr == 'light' ? Brightness.light : Brightness.dark;

    state = AppThemeConfig(
      mode: mode,
      seedColorHex: colorHex,
      customBrightness: brightness,
    );
  }

  /// 테마 모드 변경
  Future<void> setMode(AppThemeMode mode) async {
    state = state.copyWith(mode: mode);
    await _settings.set('theme_mode', mode.name);
  }

  /// 씨앗 색상 변경 (커스텀 모드 전용)
  Future<void> setSeedColor(String hex) async {
    state = state.copyWith(
      mode: AppThemeMode.custom,
      seedColorHex: hex,
    );
    await _settings.set('theme_mode', 'custom');
    await _settings.set('theme_seed_color', hex);
  }

  /// 커스텀 모드 밝기 변경
  Future<void> setBrightness(Brightness brightness) async {
    state = state.copyWith(customBrightness: brightness);
    await _settings.set(
      'theme_brightness',
      brightness == Brightness.light ? 'light' : 'dark',
    );
  }
}

final themeProvider =
    NotifierProvider<ThemeNotifier, AppThemeConfig>(ThemeNotifier.new);
