import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/color_utils.dart';
import '../../../providers/category_provider.dart';
import '../../../providers/timer_provider.dart';
import 'widgets/category_label.dart';
import 'widgets/elapsed_time_display.dart';
import 'widgets/timer_controls.dart';

class TimerCard extends ConsumerWidget {
  const TimerCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerState = ref.watch(timerServiceProvider);
    final categoriesAsync = ref.watch(categoriesProvider);

    final activeCategory = categoriesAsync.valueOrNull
        ?.where((c) => c.id == timerState.activeCategoryId)
        .firstOrNull;

    final color = activeCategory != null
        ? parseHexColor(activeCategory.color)
        : null;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CategoryLabel(
              category: activeCategory,
              color: color,
              timerState: timerState,
            ),
            const SizedBox(height: 20),
            ElapsedTimeDisplay(
              seconds: timerState.elapsedSeconds,
              color: color,
              status: timerState.status,
            ),
            const SizedBox(height: 28),
            TimerControls(
              state: timerState,
              color: color,
              categories: categoriesAsync.valueOrNull ?? [],
            ),
          ],
        ),
      ),
    );
  }
}
