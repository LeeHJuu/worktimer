import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:worktimer/core/database/app_database.dart';
import 'package:worktimer/features/timer/data/timer_provider.dart';
import 'package:worktimer/features/home/view/compact_stats_panel.dart';
import 'package:worktimer/features/home/view/condition_card.dart';
import 'package:worktimer/features/home/view/goal_progress_card.dart';
import 'package:worktimer/features/home/view/home_panel.dart';
import 'package:worktimer/features/home/view/overload_banner.dart';
import 'package:worktimer/features/home/view/session_memo_card.dart';
import 'package:worktimer/features/timer/view/timer_card.dart';
import 'package:worktimer/features/home/view/today_summary_card.dart';

final _todaySessionsProvider = StreamProvider<List<TimerSession>>((ref) {
  return ref.watch(timerRepositoryProvider).watchTodaySessions();
});

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todaySessionsAsync = ref.watch(_todaySessionsProvider);

    final timerPanel = HomePanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [TimerCard()],
      ),
    );

    final summaryPanel = HomePanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TodaySummaryCard(sessionsAsync: todaySessionsAsync),
          SessionMemoCard(),
        ],
      ),
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('홈', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 14),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [timerPanel, summaryPanel],
          ),
          const SizedBox(height: 20),
          Divider(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          ),
          const SizedBox(height: 14),
          const CompactStatsPanel(),
          const SizedBox(height: 14),
          const OverloadBanner(),
          const GoalProgressCard(),
          const SizedBox(height: 14),
          const ConditionCard(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
