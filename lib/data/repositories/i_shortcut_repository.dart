import '../database/app_database.dart';

/// 바로가기 Repository 인터페이스
abstract class IShortcutRepository {
  /// 특정 카테고리의 바로가기 스트림 (sort_order 순)
  Stream<List<Shortcut>> watchByCategory(int categoryId);

  /// 모든 바로가기 스트림 (자동 타이머 매칭용)
  Stream<List<Shortcut>> watchAll();

  /// 단일 바로가기 조회
  Future<Shortcut?> findById(int id);

  /// 바로가기 추가
  Future<int> insert(ShortcutsCompanion companion);

  /// 바로가기 수정
  Future<void> update(ShortcutsCompanion companion);

  /// 바로가기 삭제
  Future<void> delete(int id);

  /// 순서 일괄 업데이트
  Future<void> updateSortOrders(List<({int id, int sortOrder})> orders);
}
