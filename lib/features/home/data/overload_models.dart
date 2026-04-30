import 'package:worktimer/core/database/app_database.dart';

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
