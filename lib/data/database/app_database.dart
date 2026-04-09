import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'tables/categories_table.dart';
import 'tables/shortcuts_table.dart';
import 'tables/timer_sessions_table.dart';
import 'tables/condition_logs_table.dart';
import 'tables/settings_table.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Categories,
    Shortcuts,
    TimerSessions,
    ConditionLogs,
    Settings,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// 테스트용 in-memory DB 생성자
  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await _insertDefaultSettings();
        },
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            // v2: TimerSessions에 memo 컬럼 추가
            await m.addColumn(timerSessions, timerSessions.memo);
          }
        },
      );

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
