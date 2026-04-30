import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:worktimer/features/home/data/condition_provider.dart';
import 'package:worktimer/features/home/view/widgets/condition_selector.dart';

class ConditionCard extends ConsumerWidget {
  const ConditionCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conditionAsync = ref.watch(todayConditionProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.mood_outlined, size: 18, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  '오늘 컨디션',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 14),
            conditionAsync.when(
              data: (log) => ConditionSelector(
                currentLevel: log?.level,
                onSelect: (level) async {
                  final today = _todayString();
                  await ref
                      .read(conditionRepositoryProvider)
                      .saveCondition(date: today, level: level);
                  ref.invalidate(todayConditionProvider);
                },
              ),
              loading: () => const LinearProgressIndicator(),
              error: (e, _) =>
                  Text('오류: $e', style: const TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ),
    );
  }

  static String _todayString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }
}
