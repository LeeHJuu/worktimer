import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/time_utils.dart';
import '../../../providers/category_provider.dart';
import '../../../providers/stats_provider.dart';
import 'stats_helpers.dart';

class CommissionSummary extends ConsumerWidget {
  const CommissionSummary({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsAsync = ref.watch(statsSessionsProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.work_outline, size: 18, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text('카테고리 총 시간 & 메모',
                    style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 16),
            sessionsAsync.when(
              data: (sessions) {
                final cats = categoriesAsync.valueOrNull ?? [];
                if (sessions.isEmpty) return statsEmptyText(context);

                final catSec = <int, int>{};
                for (final s in sessions) {
                  catSec[s.categoryId] =
                      (catSec[s.categoryId] ?? 0) + (s.durationSec ?? 0);
                }

                return Column(
                  children: cats
                      .where((c) => catSec.containsKey(c.id))
                      .map((c) {
                    final color = statsParseColor(c.color);
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            margin: const EdgeInsets.only(top: 3),
                            decoration: BoxDecoration(
                                color: color, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        c.name,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: colorScheme.onSurface,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      TimeUtils.formatSecondsToHuman(
                                          catSec[c.id] ?? 0),
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: color,
                                      ),
                                    ),
                                  ],
                                ),
                                if (c.memo != null && c.memo!.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      c.memo!,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: colorScheme.onSurface
                                            .withValues(alpha: 0.55),
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
              loading: () => const LinearProgressIndicator(),
              error: (e, _) =>
                  Text('오류: $e', style: const TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ),
    );
  }
}
