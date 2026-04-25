import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/time_utils.dart';
import '../../providers/category_provider.dart';
import '../../providers/stats_provider.dart';
import 'stats_helpers.dart';

class TodaySessionList extends ConsumerWidget {
  const TodaySessionList({super.key});

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
                Icon(Icons.list_alt_outlined,
                    size: 18, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text('오늘 세션',
                    style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 16),
            sessionsAsync.when(
              data: (sessions) {
                final cats = categoriesAsync.valueOrNull ?? [];
                if (sessions.isEmpty) return statsEmptyText(context);

                final sorted = [...sessions]
                  ..sort((a, b) => b.startedAt.compareTo(a.startedAt));

                return Column(
                  children: sorted.map((s) {
                    final cat = cats
                        .where((c) => c.id == s.categoryId)
                        .firstOrNull;
                    final color = cat != null
                        ? statsParseColor(cat.color)
                        : colorScheme.primary;
                    final startDt = DateTime.fromMillisecondsSinceEpoch(
                        s.startedAt * 1000);
                    final h = startDt.hour.toString().padLeft(2, '0');
                    final m = startDt.minute.toString().padLeft(2, '0');

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 42,
                            child: Text(
                              '$h:$m',
                              style: TextStyle(
                                fontSize: 12,
                                color: colorScheme.onSurface
                                    .withValues(alpha: 0.45),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                                color: color, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              cat?.name ?? '?',
                              style: TextStyle(
                                fontSize: 13,
                                color: colorScheme.onSurface
                                    .withValues(alpha: 0.8),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          Text(
                            TimeUtils.formatSecondsToHuman(
                                s.durationSec ?? 0),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: color,
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
