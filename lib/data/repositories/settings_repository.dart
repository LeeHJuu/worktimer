import '../database/app_database.dart';
import '../../core/constants.dart';
import 'i_settings_repository.dart';

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
    return double.tryParse(v) ?? 1.5;
  }

  @override
  Future<double> getWeekendHours() async {
    final v = await get(
      AppConstants.keyWeekendHours,
      defaultValue: AppConstants.defaultWeekendHours,
    );
    return double.tryParse(v) ?? 4.0;
  }
}
