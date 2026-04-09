import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/time_utils.dart';
import '../../../data/database/app_database.dart';
import '../../providers/category_provider.dart';
import '../../providers/timer_provider.dart';
import 'widgets/condition_card.dart';
import 'widgets/goal_progress_card.dart';
import 'widgets/overload_banner.dart';
import 'widgets/session_memo_card.dart';
import 'widgets/timer_card.dart';

// 오늘 집중 세션 스트림 Provider
final _todaySessionsProvider = StreamProvider<List<TimerSession>>((ref) {
  return ref.watch(timerRepositoryProvider).watchTodaySessions();
});

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todaySessionsAsync = ref.watch(_todaySessionsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('홈', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 16),

          // 과부하 경고 배너 (목표 초과 시 표시)
          const OverloadBanner(),
          const SizedBox(height: 12),

          // 타이머 카드
          const TimerCard(),
          const SizedBox(height: 16),

          // 오늘 요약 + 컨디션 — 너비가 충분하면 가로 배치, 좁으면 세로 배치
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 480;
              if (isWide) {
                return IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        flex: 3,
                        child: _TodaySummaryCard(
                            sessionsAsync: todaySessionsAsync),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: const ConditionCard(),
                      ),
                    ],
                  ),
                );
              }
              return Column(
                children: [
                  _TodaySummaryCard(sessionsAsync: todaySessionsAsync),
                  const SizedBox(height: 12),
                  const ConditionCard(),
                ],
              );
            },
          ),
          const SizedBox(height: 16),

          // 오늘 세션 기록 (메모 포함)
          const SessionMemoCard(),
          const SizedBox(height: 16),

          // 목표 진척도 카드 (목표 설정된 카테고리 있을 때)
          const GoalProgressCard(),
        ],
      ),
    );
  }
}

// ── 오늘 요약 카드 ────────────────────────────

class _TodaySummaryCard extends ConsumerWidget {
  const _TodaySummaryCard({required this.sessionsAsync});

  final AsyncValue<List<TimerSession>> sessionsAsync;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                Icon(Icons.today_outlined,
                    size: 18, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text('오늘 요약',
                    style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 16),
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
                final totalSec = categorySeconds.values
                    .fold<int>(0, (a, b) => a + b);

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
                              color: colorScheme.onSurface),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Divider(height: 1, color: colorScheme.outlineVariant),
                    const SizedBox(height: 10),
                    ...categoriesAsync.valueOrNull
                            ?.where((c) =>
                                categorySeconds.containsKey(c.id))
                            .map((c) => _CategoryRow(
                                  category: c,
                                  seconds: categorySeconds[c.id] ?? 0,
                                )) ??
                        [],
                  ],
                );
              },
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text('오류: $e',
                  style: const TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({required this.category, required this.seconds});

  final Category category;
  final int seconds;

  @override
  Widget build(BuildContext context) {
    final color = _parseColor(category.color);
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(category.name,
                style: TextStyle(
                    fontSize: 13,
                    color:
                        colorScheme.onSurface.withValues(alpha: 0.75))),
          ),
          Text(TimeUtils.formatSecondsToHuman(seconds),
              style: TextStyle(
                  fontSize: 13,
                  color: colorScheme.onSurface.withValues(alpha: 0.55))),
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
