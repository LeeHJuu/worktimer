import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/time_utils.dart';
import '../../../../domain/services/overload_service.dart';
import '../../../providers/overload_provider.dart';

/// 카테고리별 목표 진척도 카드
class GoalProgressCard extends ConsumerWidget {
  const GoalProgressCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overloadAsync = ref.watch(overloadResultProvider);

    return overloadAsync.when(
      data: (result) {
        if (result == null || result.categoryDetails.isEmpty) {
          return const SizedBox.shrink();
        }

        return Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.flag_outlined,
                        size: 18, color: Colors.amber),
                    const SizedBox(width: 8),
                    Text(
                      '목표 진척도',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ...result.categoryDetails.map(
                  (detail) => _GoalProgressItem(detail: detail),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _GoalProgressItem extends StatelessWidget {
  const _GoalProgressItem({required this.detail});

  final CategoryOverloadDetail detail;

  @override
  Widget build(BuildContext context) {
    final cat = detail.category;
    final color = _parseColor(cat.color);
    final target = cat.goalTargetHours ?? 0.0;
    final progress =
        target > 0 ? (detail.achievedHours / target).clamp(0.0, 1.0) : 0.0;
    final percent = (progress * 100).toStringAsFixed(1);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 카테고리명 + 달성률
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration:
                    BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  cat.goalTitle ?? cat.name,
                  style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.75),
                      fontWeight: FontWeight.w500),
                ),
              ),
              Text(
                '$percent%',
                style: TextStyle(
                    fontSize: 13,
                    color: progress >= 1.0
                        ? Colors.green
                        : Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.55),
                    fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // 진행 바
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: color.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation<Color>(
                progress >= 1.0 ? Colors.greenAccent : color,
              ),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 6),

          // 달성 시간 / 목표 시간 + 하루 권장 + 남은 날수
          Row(
            children: [
              Text(
                '${TimeUtils.formatHours(detail.achievedHours)} / '
                '${TimeUtils.formatHours(target)}',
                style: TextStyle(
                    fontSize: 11,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.4)),
              ),
              const Spacer(),
              if (detail.daysLeft > 0 && progress < 1.0) ...[
                Icon(Icons.schedule_outlined,
                    size: 11,
                    color: detail.dailyRecommendedHours > 0
                        ? Colors.amber.withValues(alpha: 0.7)
                        : Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.25)),
                const SizedBox(width: 3),
                Text(
                  '오늘 ${TimeUtils.formatHours(detail.dailyRecommendedHours)} 권장',
                  style: TextStyle(
                    fontSize: 11,
                    color: detail.dailyRecommendedHours > 0
                        ? Colors.amber.withValues(alpha: 0.7)
                        : Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.25),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'D-${detail.daysLeft}',
                  style: TextStyle(
                    fontSize: 11,
                    color: detail.daysLeft <= 7
                        ? Colors.orange
                        : Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.4),
                  ),
                ),
              ] else if (progress >= 1.0)
                const Text(
                  '목표 달성! 🎉',
                  style: TextStyle(
                      fontSize: 11, color: Colors.greenAccent),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Color _parseColor(String hex) {
    try {
      final h = hex.replaceAll('#', '');
      return Color(int.parse('FF$h', radix: 16));
    } catch (_) {
      return Colors.blueAccent;
    }
  }
}
