import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/settings_repository.dart';
import '../../data/repositories/i_settings_repository.dart';
import 'database_provider.dart';

/// 설정 Repository Provider
final settingsRepositoryProvider = Provider<ISettingsRepository>((ref) {
  return SettingsRepository(ref.watch(appDatabaseProvider));
});
