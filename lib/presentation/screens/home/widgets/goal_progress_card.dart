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
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── 왼쪽: 색상 인디케이터 + 제목 + 달성/목표 ──
          SizedBox(
            width: 150,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                          color: color, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        cat.goalTitle ?? cat.name,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: cs.onSurface.withValues(alpha: 0.8),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Padding(
                  padding: const EdgeInsets.only(left: 14),
                  child: Text(
                    '${TimeUtils.formatHours(detail.achievedHours)} / '
                    '${TimeUtils.formatHours(target)}',
                    style: TextStyle(
                      fontSize: 10,
                      color: cs.onSurface.withValues(alpha: 0.4),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // ── 오른쪽: 진행 바 + 달성률 + D-N ──
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor: color.withValues(alpha: 0.1),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            progress >= 1.0 ? Colors.greenAccent : color,
                          ),
                          minHeight: 7,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 40,
                      child: Text(
                        '$percent%',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: progress >= 1.0
                              ? Colors.green
                              : cs.onSurface.withValues(alpha: 0.6),
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                    if (detail.daysLeft > 0 && progress < 1.0) ...[
                      const SizedBox(width: 6),
                      Text(
                        'D-${detail.daysLeft}',
                        style: TextStyle(
                          fontSize: 11,
                          color: detail.daysLeft <= 7
                              ? Colors.orange
                              : cs.onSurface.withValues(alpha: 0.35),
                        ),
                      ),
                    ],
                  ],
                ),
                if (progress >= 1.0)
                  const Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: Text(
                      '목표 달성! 🎉',
                      style: TextStyle(fontSize: 10, color: Colors.greenAccent),
                    ),
                  )
                else if (detail.daysLeft > 0 && detail.dailyRecommendedHours > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Icon(Icons.schedule_outlined,
                            size: 10,
                            color: Colors.amber.withValues(alpha: 0.7)),
                        const SizedBox(width: 3),
                        Text(
                          '오늘 ${TimeUtils.formatHours(detail.dailyRecommendedHours)} 권장',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.amber.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
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
