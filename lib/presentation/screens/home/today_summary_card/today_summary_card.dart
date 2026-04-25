import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/time_utils.dart';
import '../../../../data/database/app_database.dart';
import '../../../providers/category_provider.dart';
import 'widgets/category_row.dart';

class TodaySummaryCard extends ConsumerWidget {
  const TodaySummaryCard({super.key, required this.sessionsAsync});

  final AsyncValue<List<TimerSession>> sessionsAsync;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.today_outlined, size: 18, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text('오늘 요약',
                    style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 14),
            sessionsAsync.when(
              data: (sessions) {
                if (sessions.isEmpty) {
                  return Text(
                    '오늘 기록된 세션이 없습니다.',
                    style: Theme.of(context).textTheme.bodySmall,
                  );
                }

                final categorySeconds = <int, int>{};
                for (final s in sessions) {
                  categorySeconds[s.categoryId] =
                      (categorySeconds[s.categoryId] ?? 0) +
                          (s.durationSec ?? 0);
                }
                final totalSec = categorySeconds.values.fold<int>(0, (a, b) => a + b);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('총 집중',
                            style: Theme.of(context).textTheme.bodySmall),
                        const Spacer(),
                        Text(
                          TimeUtils.formatSecondsToHuman(totalSec),
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Divider(height: 1, color: colorScheme.outlineVariant),
                    const SizedBox(height: 10),
                    ...categoriesAsync.valueOrNull
                            ?.where((c) => categorySeconds.containsKey(c.id))
                            .map(
                              (c) => CategoryRow(
                                category: c,
                                seconds: categorySeconds[c.id] ?? 0,
                              ),
                            ) ??
                        [],
                  ],
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
