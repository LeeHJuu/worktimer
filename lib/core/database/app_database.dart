import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
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
          await m.createAll();
          await _insertDefaultSettings();
        },
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.addColumn(timerSessions, timerSessions.memo);
          }
          if (from < 3) {
            await m.addColumn(categories, categories.autoTimerOn);
          }
          if (from < 4) {
            // v4: Shortcuts에 auto_start 컬럼 추가 (기본 true)
            await m.addColumn(shortcuts, shortcuts.autoStart);
          }
          if (from < 5) {
            // v5: type='exe' 값을 OS 중립적인 'app'으로 일반화.
            //     향후 macOS .app도 동일 'app' 타입으로 처리.
            await m.database.customStatement(
              "UPDATE shortcuts SET type = 'app' WHERE type = 'exe'",
            );
          }
          if (from < 6) {
            await m.createTable(todos);
          }
        },
      );

  /// 모든 사용자 데이터를 삭제하고 설정을 기본값으로 초기화
  Future<void> resetAllData() async {
    await transaction(() async {
      await delete(timerSessions).go();
      await delete(conditionLogs).go();
      await delete(shortcuts).go();
      await delete(categories).go();
      await delete(settings).go();
      await _insertDefaultSettings();
    });
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
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'worktimer.db'));
    return NativeDatabase.createInBackground(file);
  });
}
