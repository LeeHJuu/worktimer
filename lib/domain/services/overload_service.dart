import '../../data/database/app_database.dart';

/// 과부하 계산 결과
class OverloadResult {
  const OverloadResult({
    required this.weeklyAvailableHours,
    required this.weeklyRequiredHours,
    required this.isOverloaded,
    required this.excessHours,
    required this.categoryDetails,
  });

  /// 주당 가용 시간
  final double weeklyAvailableHours;

  /// 목표 달성을 위한 주당 필요 시간 합계
  final double weeklyRequiredHours;

  final bool isOverloaded;

  /// 초과 시간 (음수면 여유)
  final double excessHours;

  /// 카테고리별 세부 정보
  final List<CategoryOverloadDetail> categoryDetails;
}

class CategoryOverloadDetail {
  const CategoryOverloadDetail({
    required this.category,
    required this.achievedHours,
    required this.remainingHours,
    required this.daysLeft,
    required this.weeklyRequiredHours,
    required this.dailyRecommendedHours,
  });

  final Category category;

  /// 현재까지 달성한 시간
  final double achievedHours;

  /// 남은 목표 시간
  final double remainingHours;

  /// 마감까지 남은 일수
  final int daysLeft;

  /// 주당 필요 시간
  final double weeklyRequiredHours;

  /// 오늘 권장 시간 (평일/주말 비율 반영)
  final double dailyRecommendedHours;
}

/// 과부하 경고 계산 서비스 (순수 함수)
class OverloadService {
  const OverloadService();

  /// 과부하 계산
  OverloadResult calculate({
    required List<Category> categories,
    required Map<int, double> achievedHoursMap,
    required double weekdayHours,
    required double weekendHours,
  }) {
    final weeklyAvailable = (weekdayHours * 5) + (weekendHours * 2);
    final now = DateTime.now();

    double totalWeeklyRequired = 0;
    final details = <CategoryOverloadDetail>[];

    for (final cat in categories) {
      if (!cat.goalIsActive) continue;
      if (cat.goalTargetHours == null || cat.goalDeadline == null) continue;

      final deadline = DateTime.fromMillisecondsSinceEpoch(
          cat.goalDeadline! * 1000);
      final daysLeft = deadline.difference(now).inDays;
      if (daysLeft <= 0) continue;

      final achieved = achievedHoursMap[cat.id] ?? 0.0;
      final remaining =
          (cat.goalTargetHours! - achieved).clamp(0.0, double.infinity);

      // 주당 필요 시간 = (남은 시간 / 남은 일수) * 7
      final weeklyRequired = (remaining / daysLeft) * 7;
      totalWeeklyRequired += weeklyRequired;

      // 오늘 권장 시간
      final dailyRec = _calcDailyRecommended(
        remainingHours: remaining,
        deadline: deadline,
        weekdayHours: weekdayHours,
        weekendHours: weekendHours,
        now: now,
      );

      details.add(CategoryOverloadDetail(
        category: cat,
        achievedHours: achieved,
        remainingHours: remaining,
        daysLeft: daysLeft,
        weeklyRequiredHours: weeklyRequired,
        dailyRecommendedHours: dailyRec,
      ));
    }

    return OverloadResult(
      weeklyAvailableHours: weeklyAvailable,
      weeklyRequiredHours: totalWeeklyRequired,
      isOverloaded: totalWeeklyRequired > weeklyAvailable,
      excessHours: totalWeeklyRequired - weeklyAvailable,
      categoryDetails: details,
    );
  }

  /// 하루 권장시간 계산 (평일/주말 가용 시간 비율 반영)
  double _calcDailyRecommended({
    required double remainingHours,
    required DateTime deadline,
    required double weekdayHours,
    required double weekendHours,
    required DateTime now,
  }) {
    final daysLeft = deadline.difference(now).inDays;
    if (daysLeft <= 0 || remainingHours <= 0) return 0;

    int weekdays = 0;
    int weekends = 0;
    for (int i = 0; i < daysLeft; i++) {
      final day = now.add(Duration(days: i)).weekday;
      // weekday: 1=월 ~ 7=일, 6=토, 7=일
      if (day >= 6) {
        weekends++;
      } else {
        weekdays++;
      }
    }

    final totalAvailable =
        (weekdays * weekdayHours) + (weekends * weekendHours);
    if (totalAvailable <= 0) return 0;

    final isWeekend = now.weekday >= 6;
    if (isWeekend) {
      if (weekends == 0) return 0;
      final weekendTotal =
          remainingHours * (weekends * weekendHours / totalAvailable);
      return weekendTotal / weekends;
    } else {
      if (weekdays == 0) return 0;
      final weekdayTotal =
          remainingHours * (weekdays * weekdayHours / totalAvailable);
      return weekdayTotal / weekdays;
    }
  }
}
