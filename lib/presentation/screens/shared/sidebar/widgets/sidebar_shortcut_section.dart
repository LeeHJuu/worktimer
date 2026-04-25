import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../providers/shortcut_provider.dart';
import '../../../../providers/timer_provider.dart';
import 'shortcut_sub_list.dart';

class SidebarShortcutSection extends ConsumerWidget {
  const SidebarShortcutSection({
    super.key,
    required this.categoryId,
    required this.categoryColor,
    required this.timerStatus,
  });

  final int categoryId;
  final Color categoryColor;
  final TimerStatus timerStatus;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shortcutsAsync = ref.watch(shortcutsByCategoryProvider(categoryId));
    return shortcutsAsync.maybeWhen(
      data: (shortcuts) => shortcuts.isNotEmpty
          ? ShortcutSubList(
              shortcuts: shortcuts,
              categoryId: categoryId,
              timerStatus: timerStatus,
              categoryColor: categoryColor,
            )
          : const SizedBox.shrink(),
      orElse: () => const SizedBox.shrink(),
    );
  }
}
