/// 시간 관련 유틸리티 함수 모음
class TimeUtils {
  TimeUtils._();

  /// 초를 HH:MM:SS 문자열로 변환
  static String formatSeconds(int totalSeconds) {
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:'
          '${minutes.toString().padLeft(2, '0')}:'
          '${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  /// 초를 "X시간 Y분" 형식으로 변환
  static String formatSecondsToHuman(int totalSeconds) {
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;

    if (hours > 0 && minutes > 0) return '$hours시간 $minutes분';
    if (hours > 0) return '$hours시간';
    if (minutes > 0) return '$minutes분';
    return '${totalSeconds}초'; // ignore: unnecessary_brace_in_string_interps
  }

  /// double 시간을 "X시간 Y분" 형식으로 변환
  static String formatHours(double hours) {
    final totalMinutes = (hours * 60).round();
    return formatSecondsToHuman(totalMinutes * 60);
  }

  /// DateTime을 Unix timestamp(초)로 변환
  static int toUnixTimestamp(DateTime dt) =>
      dt.millisecondsSinceEpoch ~/ 1000;

  /// Unix timestamp(초)를 DateTime으로 변환
  static DateTime fromUnixTimestamp(int ts) =>
      DateTime.fromMillisecondsSinceEpoch(ts * 1000);

  /// 오늘 날짜 문자열 (YYYY-MM-DD)
  static String todayString() {
    final now = DateTime.now();
    return '${now.year}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
  }
}
