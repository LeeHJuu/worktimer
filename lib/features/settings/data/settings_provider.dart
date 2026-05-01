import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:worktimer/features/settings/data/settings_repository.dart';
import 'package:worktimer/features/settings/data/i_settings_repository.dart';
import 'package:worktimer/core/database/database_provider.dart';

/// 설정 Repository Provider
final settingsRepositoryProvider = Provider<ISettingsRepository>((ref) {
  return SettingsRepository(ref.watch(appDatabaseProvider));
});
