import '../database/app_database.dart';

/// 카테고리 Repository 인터페이스
/// drift 구현체 교체를 위한 추상 계층
abstract class ICategoryRepository {
  /// 전체 카테고리 스트림 (sort_order 순)
  Stream<List<Category>> watchAll();

  /// 표시 가능한 카테고리만 스트림
  Stream<List<Category>> watchVisible();

  /// 단일 카테고리 조회
  Future<Category?> findById(int id);

  /// 카테고리 추가 (생성 시각 자동 세팅)
  Future<int> insert(CategoriesCompanion companion);

  /// 카테고리 수정
  Future<void> update(CategoriesCompanion companion);

  /// 카테고리 삭제 (timer_sessions CASCADE)
  Future<void> delete(int id);

  /// 순서 일괄 업데이트 (드래그 앤 드롭 후 호출)
  Future<void> updateSortOrders(List<({int id, int sortOrder})> orders);

  /// 표시/숨김 토글
  Future<void> setVisible(int id, {required bool visible});
}
