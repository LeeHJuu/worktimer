/// 설정 Repository 인터페이스
abstract class ISettingsRepository {
  /// 키로 값 조회 (없으면 defaultValue 반환)
  Future<String> get(String key, {String defaultValue = ''});

  /// 키-값 저장 (upsert)
  Future<void> set(String key, String value);

  /// 평일 가용 시간 (시간 단위)
  Future<double> getWeekdayHours();

  /// 주말 가용 시간 (시간 단위)
  Future<double> getWeekendHours();
}
