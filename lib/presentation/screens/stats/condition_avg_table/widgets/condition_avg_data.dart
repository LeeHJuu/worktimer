import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/utils/time_utils.dart';
import '../../../../../data/database/app_database.dart';
import '../../../../providers/condition_provider.dart';
import '../../../../providers/timer_provider.dart';
import '../../stats_helpers.dart';

final last30DaysConditionsProvider =
    FutureProvider<List<ConditionLog>>((ref) async {
  final repo = ref.read(conditionRepositoryProvider);
  final now = DateTime.now();
  final from = now.subtract(const Duration(days: 30));
  final fromStr =
      '${from.year}-${from.month.toString().padLeft(2, '0')}-${from.day.toString().padLeft(2, '0')}';
  final toStr =
      '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  return repo.getConditionsInRange(fromDate: fromStr, toDate: toStr);
});

final last30DaysSessionsProvider =
    FutureProvider<List<TimerSession>>((ref) async {
  final repo = ref.read(timerRepositoryProvider);
  final now = DateTime.now();
  final from = now.subtract(const Duration(days: 30));
  return repo.getSessionsInRange(from: from, to: now);
});

class ConditionAvgData extends ConsumerWidget {
  const ConditionAvgData({super.key});

  static const emojis = ['😩', '😕', '😐', '🙂', '😄'];
  static const labels = ['매우 나쁨', '나쁨', '보통', '좋음', '매우 좋음'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conditionsAsync = ref.watch(last30DaysConditionsProvider);
    final sessionsAsync = ref.watch(last30DaysSessionsProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return conditionsAsync.when(
      data: (conditions) => sessionsAsync.when(
        data: (sessions) {
          if (conditions.isEmpty) return statsEmptyText(context);

          final condMap = {
            for (final c in conditions) c.date: c.level,
          };
          final daySec = <String, int>{};
          for (final s in sessions) {
            final d =
                DateTime.fromMillisecondsSinceEpoch(s.startedAt * 1000);
            final key =
                '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
            daySec[key] = (daySec[key] ?? 0) + (s.durationSec ?? 0);
          }
          final levelSums = List<int>.filled(5, 0);
          final levelCounts = List<int>.filled(5, 0);
          for (final entry in condMap.entries) {
            final sec = daySec[entry.key] ?? 0;
            final lvl = entry.value - 1;
            if (lvl >= 0 && lvl < 5) {
              levelSums[lvl] += sec;
              levelCounts[lvl]++;
            }
          }

          return Column(
            children: List.generate(5, (i) {
              final avg =
                  levelCounts[i] > 0 ? levelSums[i] ~/ levelCounts[i] : 0;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  children: [
                    Text(emojis[i], style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 52,
                      child: Text(
                        labels[i],
                        style: TextStyle(
                          fontSize: 11,
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: LinearProgressIndicator(
                        value:
                            avg > 0 ? (avg / 28800).clamp(0.0, 1.0) : 0,
                        backgroundColor:
                            colorScheme.outline.withValues(alpha: 0.15),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          colorScheme.primary.withValues(alpha: 0.7),
                        ),
                        minHeight: 6,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 55,
                      child: Text(
                        levelCounts[i] > 0
                            ? TimeUtils.formatSecondsToHuman(avg)
                            : '-',
                        style: TextStyle(
                          fontSize: 12,
                          color:
                              colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              );
            }),
          );
        },
        loading: () => const LinearProgressIndicator(),
        error: (e, _) =>
            Text('오류: $e', style: const TextStyle(color: Colors.red)),
      ),
      loading: () => const LinearProgressIndicator(),
      error: (e, _) =>
          Text('오류: $e', style: const TextStyle(color: Colors.red)),
    );
  }
}
