import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:worktimer/core/database/app_database.dart';
import 'package:worktimer/features/timer/data/timer_service.dart';
import 'package:worktimer/features/timer/data/timer_provider.dart';
import 'package:worktimer/features/manage/data/shortcut_provider.dart';
import 'package:worktimer/features/manage/data/manage_controller.dart';
import 'package:worktimer/features/manage/view/widgets/shortcut_dialog.dart';
import 'package:worktimer/features/manage/view/widgets/shortcut_list_tile.dart';

class InlineShortcutSection extends ConsumerWidget {
  const InlineShortcutSection({super.key, required this.categoryId});

  final int categoryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shortcutsAsync = ref.watch(shortcutsByCategoryProvider(categoryId));
    final colorScheme = Theme.of(context).colorScheme;

    return shortcutsAsync.when(
      data: (shortcuts) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(height: 1, color: colorScheme.outline.withValues(alpha: 0.15)),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 6, 10, 6),
            child: Row(
              children: [
                Icon(Icons.link,
                    size: 12,
                    color: colorScheme.onSurface.withValues(alpha: 0.35)),
                const SizedBox(width: 6),
                Text(
                  '바로가기 (${shortcuts.length})',
                  style: TextStyle(
                    fontSize: 11,
                    color: colorScheme.onSurface.withValues(alpha: 0.45),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () =>
                      _showShortcutDialog(context, ref, categoryId, null),
                  icon: const Icon(Icons.add, size: 13),
                  label: const Text('추가', style: TextStyle(fontSize: 11)),
                  style: TextButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ],
            ),
          ),
          if (shortcuts.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 0, 14, 10),
              child: Text(
                '바로가기가 없습니다',
                style: TextStyle(
                    fontSize: 11,
                    color: colorScheme.onSurface.withValues(alpha: 0.3)),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Column(
                children: shortcuts
                    .map((s) => _ShortcutRow(
                          shortcut: s,
                          onEdit: () =>
                              _showShortcutDialog(context, ref, categoryId, s),
                          onDelete: () =>
                              _confirmDeleteShortcut(context, ref, s),
                        ))
                    .toList(),
              ),
            ),
        ],
      ),
      loading: () => const SizedBox(
          height: 24,
          child: Center(
              child: SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 1.5)))),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Future<void> _showShortcutDialog(
    BuildContext context,
    WidgetRef ref,
    int categoryId,
    Shortcut? existing,
  ) async {
    await showDialog<void>(
      context: context,
      builder: (_) => ShortcutDialog(
        categoryId: categoryId,
        existing: existing,
        onSave: (companion) => ref
            .read(manageControllerProvider)
            .saveShortcut(companion, categoryId: categoryId),
      ),
    );
  }

  Future<void> _confirmDeleteShortcut(
    BuildContext context,
    WidgetRef ref,
    Shortcut shortcut,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('바로가기 삭제'),
        content: Text('"${shortcut.name}"을(를) 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          ElevatedButton(
            style:
                ElevatedButton.styleFrom(backgroundColor: Colors.red.shade700),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await ref.read(manageControllerProvider).deleteShortcut(shortcut.id);
    }
  }
}

class _ShortcutRow extends ConsumerWidget {
  const _ShortcutRow({
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
