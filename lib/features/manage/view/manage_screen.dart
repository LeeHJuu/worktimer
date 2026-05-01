import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:worktimer/core/database/app_database.dart';
import 'package:worktimer/features/manage/data/category_provider.dart';
import 'package:worktimer/features/settings/view/settings_screen.dart';
import 'package:worktimer/features/manage/data/manage_controller.dart';
import 'package:worktimer/features/manage/view/category_dialog.dart';
import 'package:worktimer/features/manage/view/category_list_panel.dart';

const double _kCategoryPanelWidth = 520;
const double _kSettingsPanelWidth = 420;

class ManageScreen extends ConsumerStatefulWidget {
  const ManageScreen({super.key});

  @override
  ConsumerState<ManageScreen> createState() => _ManageScreenState();
}

class _ManageScreenState extends ConsumerState<ManageScreen> {
  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);

    final categoryPanel = CategoryListPanel(
      categoriesAsync: categoriesAsync,
      onAdd: () => _showCategoryDialog(context),
      onEdit: (cat) => _showCategoryDialog(context, existing: cat),
      onDelete: (cat) => _confirmDeleteCategory(context, cat),
      onToggleVisible: (cat) =>
          ref.read(manageControllerProvider).toggleCategoryVisible(cat),
      onResetSessions: (cat) => _confirmResetCategory(context, cat),
      onResetAll: () => _confirmResetAll(context),
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Wrap(
        spacing: 16,
        runSpacing: 16,
        crossAxisAlignment: WrapCrossAlignment.start,
        children: [
          SizedBox(width: _kCategoryPanelWidth, child: categoryPanel),
          const SizedBox(width: _kSettingsPanelWidth, child: SettingsScreen()),
        ],
      ),
    );
  }

  Future<void> _showCategoryDialog(
    BuildContext context, {
    Category? existing,
  }) async {
    await showDialog<void>(
      context: context,
      builder: (_) => CategoryDialog(
        existing: existing,
        onSave: (companion) =>
            ref.read(manageControllerProvider).saveCategory(companion),
      ),
    );
  }

  Future<void> _confirmDeleteCategory(
    BuildContext context,
    Category cat,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('카테고리 삭제'),
        content: Text('"${cat.name}" 카테고리와\n관련된 모든 기록이 삭제됩니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await ref.read(manageControllerProvider).deleteCategory(cat.id);
    }
  }

  Future<void> _confirmResetCategory(
    BuildContext context,
    Category cat,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('세션 데이터 초기화'),
        content: Text(
            '"${cat.name}" 카테고리의\n모든 타이머 기록이 삭제됩니다.\n\n이 작업은 되돌릴 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('초기화'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await ref.read(manageControllerProvider).resetCategorySessions(cat.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('"${cat.name}" 기록이 초기화되었습니다.')),
        );
      }
    }
  }

  Future<void> _confirmResetAll(BuildContext context) async {
    final step1 = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('전체 데이터 초기화'),
        content: const Text('모든 카테고리의 타이머 기록이 삭제됩니다.\n\n정말 진행하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade700),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('다음'),
          ),
        ],
      ),
    );
    if (step1 != true) return;

    if (!context.mounted) return;
    final step2 = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('⚠ 최종 확인'),
        content: const Text(
            '이 작업은 되돌릴 수 없습니다.\n모든 타이머 기록이 영구 삭제됩니다.\n\n계속하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade800),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('전체 초기화'),
          ),
        ],
      ),
    );
    if (step2 == true) {
      await ref.read(manageControllerProvider).resetAllSessions();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('모든 타이머 기록이 초기화되었습니다.')),
        );
      }
    }
  }
}
