import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:worktimer/core/database/app_database.dart';
import 'package:worktimer/core/logging/app_logger.dart';

/// 앱 전역 AppDatabase 싱글턴 Provider
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  AppLog.i('creating AppDatabase');
  final db = AppDatabase();
  ref.onDispose(() {
    AppLog.i('disposing AppDatabase');
    db.close();
  });
  return db;
});
