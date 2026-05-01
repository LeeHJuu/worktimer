import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:worktimer/core/theme.dart';
import 'package:worktimer/features/settings/data/settings_repository.dart';
import 'package:worktimer/core/database/database_provider.dart';

// ── ThemeNotifier ────────────────────────────────────────────

class ThemeNotifier extends Notifier<AppThemeConfig> {
  @override
  AppThemeConfig build() {
    _loadFromStorage();
    return const AppThemeConfig();
  }

  SettingsRepository get _settings =>
      SettingsRepository(ref.read(appDatabaseProvider));

  Future<void> _loadFromStorage() async {
    // 신규 키 우선
    String backgroundHex =
        await _settings.get('theme_background_color', defaultValue: '');
    String accentHex =
        await _settings.get('theme_accent_color', defaultValue: '');

    // 하위 호환 fallback: 기존 primary/seed 값이 있으면 accent로 사용
    if (accentHex.isEmpty) {
      final legacyPrimary =
          await _settings.get('theme_primary_color', defaultValue: '');
      final legacySeed =
          await _settings.get('theme_seed_color', defaultValue: '');
      accentHex = legacyPrimary.isNotEmpty
          ? legacyPrimary
          : (legacySeed.isNotEmpty ? legacySeed : '#6C63FF');
    }
    if (backgroundHex.isEmpty) {
      backgroundHex = '#1A1A2E';
    }

    state = AppThemeConfig(
      backgroundColorHex: backgroundHex,
      accentColorHex: accentHex,
    );
  }

  Future<void> setBackgroundColor(String hex) async {
    state = state.copyWith(backgroundColorHex: hex);
    await _settings.set('theme_background_color', hex);
  }

  Future<void> setAccentColor(String hex) async {
    state = state.copyWith(accentColorHex: hex);
    await _settings.set('theme_accent_color', hex);
  }
}

final themeProvider =
    NotifierProvider<ThemeNotifier, AppThemeConfig>(ThemeNotifier.new);
