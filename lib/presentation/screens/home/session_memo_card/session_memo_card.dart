import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/database/app_database.dart';
import '../../../providers/category_provider.dart';
import '../../../providers/timer_provider.dart';
import 'widgets/session_row.dart';

class SessionMemoCard extends ConsumerWidget {
  const SessionMemoCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsAsync = ref.watch(_todaySessionsDescProvider);
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
                Icon(Icons.notes_outlined,
                    size: 18, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  '오늘 세션 기록',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
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
                final cats = categoriesAsync.valueOrNull ?? [];
                return Column(
                  children: sessions
                      .map((s) => SessionRow(session: s, categories: cats))
                      .toList(),
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

final _todaySessionsDescProvider = StreamProvider<List<TimerSession>>((ref) {
  return ref.watch(timerRepositoryProvider).watchTodaySessionsDesc();
});
