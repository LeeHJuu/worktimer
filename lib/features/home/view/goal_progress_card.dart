import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:worktimer/features/home/data/overload_provider.dart';
import 'package:worktimer/features/home/view/widgets/goal_progress_item.dart';

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
                  (detail) => GoalProgressItem(detail: detail),
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
