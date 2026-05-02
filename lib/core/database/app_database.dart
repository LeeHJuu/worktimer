import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:worktimer/core/logging/app_logger.dart';
import 'package:worktimer/core/database/tables/categories_table.dart';
import 'package:worktimer/core/database/tables/shortcuts_table.dart';
import 'package:worktimer/core/database/tables/timer_sessions_table.dart';
import 'package:worktimer/core/database/tables/condition_logs_table.dart';
import 'package:worktimer/core/database/tables/settings_table.dart';
import 'package:worktimer/core/database/tables/todos_table.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Categories,
    Shortcuts,
    TimerSessions,
    ConditionLogs,
    Settings,
    Todos,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// 테스트용 in-memory DB 생성자
  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 6;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          AppLog.i('DB onCreate (schema=$schemaVersion)');
          await m.createAll();
          await _insertDefaultSettings();
          AppLog.i('DB onCreate done');
        },
        onUpgrade: (m, from, to) async {
          AppLog.i('DB onUpgrade $from -> $to');
          if (from < 2) {
            AppLog.i('migrate v2: add timerSessions.memo');
            await m.addColumn(timerSessions, timerSessions.memo);
          }
          if (from < 3) {
            AppLog.i('migrate v3: add categories.autoTimerOn');
            await m.addColumn(categories, categories.autoTimerOn);
          }
          if (from < 4) {
            AppLog.i('migrate v4: add shortcuts.autoStart');
            await m.addColumn(shortcuts, shortcuts.autoStart);
          }
          if (from < 5) {
            AppLog.i("migrate v5: shortcuts.type 'exe' -> 'app'");
            await m.database.customStatement(
              "UPDATE shortcuts SET type = 'app' WHERE type = 'exe'",
            );
          }
          if (from < 6) {
            AppLog.i('migrate v6: create todos table');
            await m.createTable(todos);
          }
          AppLog.i('DB onUpgrade done');
        },
      );

  /// 모든 사용자 데이터를 삭제하고 설정을 기본값으로 초기화
  Future<void> resetAllData() async {
    AppLog.i('resetAllData start');
    await transaction(() async {
      await delete(timerSessions).go();
      await delete(conditionLogs).go();
      await delete(shortcuts).go();
      await delete(categories).go();
      await delete(settings).go();
      await _insertDefaultSettings();
    });
    AppLog.i('resetAllData done');
  }

  /// 기본 설정값 삽입
  Future<void> _insertDefaultSettings() async {
    final defaults = {
      'weekday_available_hours': '1.5',
      'weekend_available_hours': '4.0',
    };
    for (final entry in defaults.entries) {
      await into(settings).insert(
        SettingsCompanion.insert(key: entry.key, value: entry.value),
      );
    }
  }
}

/// SQLite 파일 기반 연결 (path_provider 사용)
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    try {
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, 'worktimer.db'));
      AppLog.i('opening DB at ${file.path} (exists=${file.existsSync()})');
      return NativeDatabase.createInBackground(file);
    } catch (e, st) {
      AppLog.e('DB open failed', e, st);
      rethrow;
    }
  });
}
