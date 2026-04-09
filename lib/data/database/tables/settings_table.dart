import 'package:drift/drift.dart';

/// 설정 테이블
/// key-value 구조로 앱 설정을 저장
class Settings extends Table {
  /// 설정 키 (Primary Key)
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}
