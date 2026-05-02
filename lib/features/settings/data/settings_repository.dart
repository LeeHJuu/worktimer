import 'package:worktimer/core/database/app_database.dart';
import 'package:worktimer/core/constants.dart';
import 'package:worktimer/core/logging/app_logger.dart';
import 'package:worktimer/features/settings/data/i_settings_repository.dart';

/// drift 기반 설정 Repository 구현체
class SettingsRepository implements ISettingsRepository {
  SettingsRepository(this._db);

  final AppDatabase _db;

  @override
  Future<String> get(String key, {String defaultValue = ''}) async {
    final row = await (_db.select(_db.settings)
          ..where((t) => t.key.equals(key)))
        .getSingleOrNull();
    return row?.value ?? defaultValue;
  }

  @override
  Future<void> set(String key, String value) async {
    await _db.into(_db.settings).insertOnConflictUpdate(
          SettingsCompanion.insert(key: key, value: value),
        );
  }

  @override
  Future<double> getWeekdayHours() async {
    final v = await get(
      AppConstants.keyWeekdayHours,
      defaultValue: AppConstants.defaultWeekdayHours,
    );
    final parsed = double.tryParse(v);
    if (parsed == null) {
      AppLog.w('weekdayHours unparseable: "$v" (using fallback 1.5)');
      return 1.5;
    }
    return parsed;
  }

  @override
  Future<double> getWeekendHours() async {
    final v = await get(
      AppConstants.keyWeekendHours,
      defaultValue: AppConstants.defaultWeekendHours,
    );
    final parsed = double.tryParse(v);
    if (parsed == null) {
      AppLog.w('weekendHours unparseable: "$v" (using fallback 4.0)');
      return 4.0;
    }
    return parsed;
  }
}
