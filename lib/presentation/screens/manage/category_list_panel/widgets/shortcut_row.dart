import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../data/database/app_database.dart';
import '../../../../providers/timer_provider.dart';
import 'shortcut_list_tile.dart';

class ShortcutRow extends ConsumerWidget {
  const ShortcutRow({
    super.key,
    required this.shortcut,
    required this.onEdit,
    required this.onDelete,
  });

  final Shortcut shortcut;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ShortcutListTile(
      shortcut: shortcut,
      onEdit: onEdit,
      onDelete: onDelete,
      onLaunch: () async {
        final result =
            await ref.read(timerServiceProvider.notifier).launch(shortcut);
        if (!result.success && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.errorMessage ?? '실행 실패'),
              backgroundColor: Colors.red.shade700,
            ),
          );
        }
      },
    );
  }
}
