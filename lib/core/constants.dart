/// 앱 전역 상수
class AppConstants {
  AppConstants._();

  static const String appName = 'WorkTimer';
  static const String dbFileName = 'worktimer.db';

  /// 설정 키
  static const String keyWeekdayHours = 'weekday_available_hours';
  static const String keyWeekendHours = 'weekend_available_hours';

  /// 설정 기본값
  static const String defaultWeekdayHours = '1.5';
  static const String defaultWeekendHours = '4.0';

  /// 사이드바 너비
  static const double sidebarWidth = 220.0;
}
