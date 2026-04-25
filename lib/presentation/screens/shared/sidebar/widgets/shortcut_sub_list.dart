import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../data/database/app_database.dart';
import '../../../../providers/timer_provider.dart';

class ShortcutSubList extends ConsumerWidget {
  const ShortcutSubList({
    super.key,
    required this.shortcuts,
    required this.categoryId,
    required this.timerStatus,
    required this.categoryColor,
  });

  final List<Shortcut> shortcuts;
  final int categoryId;
  final TimerStatus timerStatus;
  final Color categoryColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Divider(
          height: 1,
          color: categoryColor.withValues(alpha: 0.2),
          indent: 10,
          endIndent: 10,
        ),
        ...shortcuts.map((s) {
          final isWeb = s.type == 'web';
          return MouseRegion(
            cursor: SystemMouseCursors.click,
            child: InkWell(
              onTap: () async {
                final result = await ref
                    .read(timerServiceProvider.notifier)
                    .launchAndStart(s);
                if (!result.success && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(result.errorMessage ?? '실행 실패'),
                    backgroundColor: Colors.red.shade700,
                  ));
                }
              },
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(9),
                bottomRight: Radius.circular(9),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 6, 12, 6),
                child: Row(
                  children: [
                    Icon(
                      isWeb
                          ? Icons.language_outlined
                          : Icons.apps_outlined,
                      size: 13,
                      color: colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        s.name,
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.open_in_new_rounded,
                      size: 11,
                      color: categoryColor.withValues(alpha: 0.6),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
        const SizedBox(height: 4),
      ],
    );
  }
}
