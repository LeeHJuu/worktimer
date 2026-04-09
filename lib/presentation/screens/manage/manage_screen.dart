import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/database/app_database.dart';
import '../../../domain/services/shortcut_launcher_service.dart';
import '../../providers/category_provider.dart';
import '../../providers/shortcut_provider.dart';
import '../../providers/timer_provider.dart';
import 'widgets/category_list_tile.dart';
import 'widgets/shortcut_list_tile.dart';

class ManageScreen extends ConsumerWidget {
  const ManageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('관리',
                  style: Theme.of(context).textTheme.headlineMedium),
              const Spacer(),
              // 전체 데이터 초기화 버튼
              OutlinedButton.icon(
                onPressed: () =>
                    _confirmResetAll(context, ref),
                icon: const Icon(Icons.delete_sweep_outlined,
                    size: 16, color: Colors.redAccent),
                label: const Text('전체 초기화',
                    style: TextStyle(color: Colors.redAccent)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.redAccent),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () =>
                    _showCategoryDialog(context, ref),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('카테고리 추가'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: categoriesAsync.when(
              data: (categories) {
                if (categories.isEmpty) {
                  return Center(
                    child: Text(
                      '카테고리가 없습니다.\n오른쪽 위 버튼으로 추가하세요.',
                      style: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.38)),
                      textAlign: TextAlign.center,
                    ),
                  );
                }
                return ListView.separated(
                  itemCount: categories.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final cat = categories[index];
                    return _CategorySection(
                      category: cat,
                      onEdit: () =>
                          _showCategoryDialog(context, ref,
                              existing: cat),
                      onDelete: () =>
                          _confirmDeleteCategory(context, ref, cat),
                      onResetSessions: () =>
                          _confirmResetCategory(context, ref, cat),
                      onToggleVisible: () {
                        ref
                            .read(categoryRepositoryProvider)
                            .setVisible(cat.id,
                                visible: !cat.isVisible);
                      },
                    );
                  },
                );
              },
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Text('오류: $e',
                    style: const TextStyle(color: Colors.red)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── 카테고리 추가/편집 다이얼로그 ──────────────

  Future<void> _showCategoryDialog(
    BuildContext context,
    WidgetRef ref, {
    Category? existing,
  }) async {
    await showDialog<void>(
      context: context,
      builder: (_) => _CategoryDialog(
        existing: existing,
        onSave: (companion) async {
          final repo = ref.read(categoryRepositoryProvider);
          if (existing == null) {
            final categories =
                ref.read(categoriesProvider).valueOrNull ?? [];
            final nextOrder = categories.isEmpty
                ? 0
                : categories
                        .map((c) => c.sortOrder)
                        .reduce((a, b) => a > b ? a : b) +
                    1;
            await repo.insert(
                companion.copyWith(sortOrder: Value(nextOrder)));
          } else {
            await repo.update(companion);
          }
        },
      ),
    );
  }

  Future<void> _confirmDeleteCategory(
    BuildContext context,
    WidgetRef ref,
    Category cat,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('카테고리 삭제'),
        content: Text(
            '"${cat.name}" 카테고리와\n관련된 모든 기록이 삭제됩니다.'),
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
      await ref.read(categoryRepositoryProvider).delete(cat.id);
    }
  }

  /// 카테고리별 세션 초기화
  Future<void> _confirmResetCategory(
    BuildContext context,
    WidgetRef ref,
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
      await ref.read(timerRepositoryProvider).deleteSessionsByCategory(cat.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('"${cat.name}" 기록이 초기화되었습니다.'),
          ),
        );
      }
    }
  }

  /// 전체 세션 초기화 (2단계 확인)
  Future<void> _confirmResetAll(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final step1 = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('전체 데이터 초기화'),
        content: const Text(
            '모든 카테고리의 타이머 기록이 삭제됩니다.\n\n정말 진행하시겠습니까?'),
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
      await ref.read(timerRepositoryProvider).deleteAllSessions();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('모든 타이머 기록이 초기화되었습니다.')),
        );
      }
    }
  }
}

// ── 카테고리 섹션 (카테고리 + 하위 바로가기 목록) ─

class _CategorySection extends ConsumerWidget {
  const _CategorySection({
    required this.category,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleVisible,
    this.onResetSessions,
  });

  final Category category;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggleVisible;
  final VoidCallback? onResetSessions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shortcutsAsync =
        ref.watch(shortcutsByCategoryProvider(category.id));

    return Card(
      margin: EdgeInsets.zero,
      child: Column(
        children: [
          // 카테고리 타일
          CategoryListTile(
            category: category,
            onEdit: onEdit,
            onDelete: onDelete,
            onToggleVisible: onToggleVisible,
            onResetSessions: onResetSessions,
          ),

          // 바로가기 섹션
          shortcutsAsync.when(
            data: (shortcuts) => _ShortcutSection(
              category: category,
              shortcuts: shortcuts,
            ),
            loading: () => const SizedBox(
              height: 32,
              child: Center(
                child: CircularProgressIndicator(strokeWidth: 1.5),
              ),
            ),
            error: (e, _) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

// ── 바로가기 섹션 ─────────────────────────────────

class _ShortcutSection extends ConsumerWidget {
  const _ShortcutSection({
    required this.category,
    required this.shortcuts,
  });

  final Category category;
  final List<Shortcut> shortcuts;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final launcher = const ShortcutLauncherService();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 바로가기 헤더
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 8, 4),
          child: Row(
            children: [
              Icon(Icons.link,
                  size: 13,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.3)),
              const SizedBox(width: 6),
              Text(
                '바로가기',
                style: TextStyle(
                  fontSize: 11,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.4),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () =>
                    _showShortcutDialog(context, ref, category.id),
                icon: const Icon(Icons.add, size: 13),
                label: const Text('추가', style: TextStyle(fontSize: 12)),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ],
          ),
        ),

        // 바로가기 목록
        if (shortcuts.isEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 16, 12),
            child: Text(
              '바로가기가 없습니다',
              style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.25)),
            ),
          )
        else
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            buildDefaultDragHandles: false,
            itemCount: shortcuts.length,
            itemBuilder: (context, index) {
              final s = shortcuts[index];
              return ReorderableDragStartListener(
                key: ValueKey(s.id),
                index: index,
                child: ShortcutListTile(
                  shortcut: s,
                  onEdit: () => _showShortcutDialog(context, ref,
                      category.id,
                      existing: s),
                  onDelete: () =>
                      _confirmDeleteShortcut(context, ref, s),
                  onLaunch: () async {
                    final result = await launcher.launch(s);
                    if (!result.success && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content:
                              Text(result.errorMessage ?? '실행 실패'),
                          backgroundColor: Colors.red.shade700,
                        ),
                      );
                    }
                  },
                ),
              );
            },
            onReorder: (oldIndex, newIndex) async {
              if (newIndex > oldIndex) newIndex--;
              final reordered = [...shortcuts];
              final item = reordered.removeAt(oldIndex);
              reordered.insert(newIndex, item);
              final orders = reordered
                  .asMap()
                  .entries
                  .map((e) => (id: e.value.id, sortOrder: e.key))
                  .toList();
              await ref
                  .read(shortcutRepositoryProvider)
                  .updateSortOrders(orders);
            },
          ),
        const SizedBox(height: 4),
      ],
    );
  }

  Future<void> _showShortcutDialog(
    BuildContext context,
    WidgetRef ref,
    int categoryId, {
    Shortcut? existing,
  }) async {
    await showDialog<void>(
      context: context,
      builder: (_) => _ShortcutDialog(
        categoryId: categoryId,
        existing: existing,
        onSave: (companion) async {
          final repo = ref.read(shortcutRepositoryProvider);
          if (existing == null) {
            final nextOrder = shortcuts.isEmpty
                ? 0
                : shortcuts
                        .map((s) => s.sortOrder)
                        .reduce((a, b) => a > b ? a : b) +
                    1;
            await repo.insert(
                companion.copyWith(sortOrder: Value(nextOrder)));
          } else {
            await repo.update(companion);
          }
        },
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
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await ref.read(shortcutRepositoryProvider).delete(shortcut.id);
    }
  }
}

// ── 카테고리 추가/편집 다이얼로그 ────────────────

class _CategoryDialog extends StatefulWidget {
  const _CategoryDialog({required this.existing, required this.onSave});

  final Category? existing;
  final Future<void> Function(CategoriesCompanion companion) onSave;

  @override
  State<_CategoryDialog> createState() => _CategoryDialogState();
}

class _CategoryDialogState extends State<_CategoryDialog> {
  final _nameCtrl = TextEditingController();
  Color _selectedColor = const Color(0xFF6C63FF);
  bool _saving = false;

  // 목표 설정 상태
  final _goalTitleCtrl = TextEditingController();
  final _goalHoursCtrl = TextEditingController();
  DateTime? _goalDeadline;
  bool _goalIsActive = false;

  static const _colorOptions = [
    Color(0xFF6C63FF),
    Color(0xFFFF6584),
    Color(0xFF43D9AD),
    Color(0xFFFFB347),
    Color(0xFF4FC3F7),
    Color(0xFFF06292),
    Color(0xFFAED581),
    Color(0xFFBA68C8),
    Color(0xFFFF7043),
    Color(0xFF4DB6AC),
  ];

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      final cat = widget.existing!;
      _nameCtrl.text = cat.name;
      _selectedColor = _parseColor(cat.color);
      _goalTitleCtrl.text = cat.goalTitle ?? '';
      _goalHoursCtrl.text = cat.goalTargetHours?.toString() ?? '';
      _goalIsActive = cat.goalIsActive;
      if (cat.goalDeadline != null) {
        _goalDeadline =
            DateTime.fromMillisecondsSinceEpoch(cat.goalDeadline! * 1000);
      }
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _goalTitleCtrl.dispose();
    _goalHoursCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    return AlertDialog(
      title: Text(isEdit ? '카테고리 편집' : '카테고리 추가'),
      content: SizedBox(
        width: 360,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 500),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _nameCtrl,
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: '카테고리 이름',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 20),
                Text('색상',
                    style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.55),
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _colorOptions.map((c) {
                    final selected =
                        c.toARGB32() == _selectedColor.toARGB32();
                    return GestureDetector(
                      onTap: () => setState(() => _selectedColor = c),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: c,
                          shape: BoxShape.circle,
                          border: selected
                              ? Border.all(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface,
                                  width: 2.5)
                              : null,
                          boxShadow: selected
                              ? [
                                  BoxShadow(
                                      color: c.withValues(alpha: 0.6),
                                      blurRadius: 6)
                                ]
                              : null,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 8),
                // ── 목표 설정 섹션 ──────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('목표 설정',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurface)),
                    Switch(
                      value: _goalIsActive,
                      onChanged: (v) =>
                          setState(() => _goalIsActive = v),
                    ),
                  ],
                ),
                if (_goalIsActive) ...[
                  const SizedBox(height: 12),
                  TextField(
                    controller: _goalTitleCtrl,
                    decoration: const InputDecoration(
                      labelText: '목표명',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _goalHoursCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true),
                    decoration: const InputDecoration(
                      labelText: '목표 시간 (h)',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _goalDeadline == null
                              ? '마감일 미설정'
                              : '마감일: ${_goalDeadline!.year}-${_goalDeadline!.month.toString().padLeft(2, '0')}-${_goalDeadline!.day.toString().padLeft(2, '0')}',
                          style: TextStyle(
                              fontSize: 13,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.75)),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate:
                                _goalDeadline ?? DateTime.now(),
                            firstDate: DateTime.now()
                                .subtract(const Duration(days: 1)),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            setState(() => _goalDeadline = picked);
                          }
                        },
                        icon: const Icon(Icons.calendar_today, size: 16),
                        label: const Text('선택'),
                      ),
                      if (_goalDeadline != null)
                        IconButton(
                          icon: const Icon(Icons.clear, size: 16),
                          tooltip: '마감일 해제',
                          onPressed: () =>
                              setState(() => _goalDeadline = null),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('취소'),
        ),
        ElevatedButton(
          onPressed: _saving ? null : _submit,
          child: Text(isEdit ? '저장' : '추가'),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;
    setState(() => _saving = true);

    final argb = _selectedColor.toARGB32();
    final hexColor =
        '#${(argb & 0x00FFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';

    final goalTitle =
        _goalIsActive ? _goalTitleCtrl.text.trim() : null;
    final goalTargetHours =
        _goalIsActive ? double.tryParse(_goalHoursCtrl.text.trim()) : null;
    final goalDeadlineTs = (_goalIsActive && _goalDeadline != null)
        ? _goalDeadline!.millisecondsSinceEpoch ~/ 1000
        : null;

    final companion = widget.existing != null
        ? CategoriesCompanion(
            id: Value(widget.existing!.id),
            name: Value(name),
            color: Value(hexColor),
            sortOrder: Value(widget.existing!.sortOrder),
            createdAt: Value(widget.existing!.createdAt),
            goalTitle: Value(goalTitle),
            goalTargetHours: Value(goalTargetHours),
            goalDeadline: Value(goalDeadlineTs),
            goalIsActive: Value(_goalIsActive),
          )
        : CategoriesCompanion.insert(
            name: name,
            color: hexColor,
            sortOrder: 0,
            createdAt: DateTime.now().millisecondsSinceEpoch ~/ 1000,
            goalTitle: Value(goalTitle),
            goalTargetHours: Value(goalTargetHours),
            goalDeadline: Value(goalDeadlineTs),
            goalIsActive: Value(_goalIsActive),
          );

    await widget.onSave(companion);
    if (mounted) Navigator.pop(context);
  }

  Color _parseColor(String hex) {
    try {
      final h = hex.replaceAll('#', '');
      return Color(int.parse('FF$h', radix: 16));
    } catch (_) {
      return const Color(0xFF6C63FF);
    }
  }
}

// ── 바로가기 추가/편집 다이얼로그 ────────────────

class _ShortcutDialog extends StatefulWidget {
  const _ShortcutDialog({
    required this.categoryId,
    required this.existing,
    required this.onSave,
  });

  final int categoryId;
  final Shortcut? existing;
  final Future<void> Function(ShortcutsCompanion companion) onSave;

  @override
  State<_ShortcutDialog> createState() => _ShortcutDialogState();
}

class _ShortcutDialogState extends State<_ShortcutDialog> {
  final _nameCtrl = TextEditingController();
  final _targetCtrl = TextEditingController();
  String _type = 'web';
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      _nameCtrl.text = widget.existing!.name;
      _targetCtrl.text = widget.existing!.target;
      _type = widget.existing!.type;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _targetCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    return AlertDialog(
      title: Text(isEdit ? '바로가기 편집' : '바로가기 추가'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 타입 선택
            Row(
              children: [
                _TypeChip(
                  label: '웹 URL',
                  icon: Icons.language_outlined,
                  selected: _type == 'web',
                  onTap: () => setState(() => _type = 'web'),
                ),
                const SizedBox(width: 8),
                _TypeChip(
                  label: 'exe 파일',
                  icon: Icons.apps_outlined,
                  selected: _type == 'exe',
                  onTap: () => setState(() => _type = 'exe'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 이름
            TextField(
              controller: _nameCtrl,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: '이름',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
            const SizedBox(height: 12),

            // 대상
            TextField(
              controller: _targetCtrl,
              decoration: InputDecoration(
                labelText: _type == 'web' ? 'URL (https://...)' : 'exe 파일 경로',
                border: const OutlineInputBorder(),
                isDense: true,
                hintText: _type == 'web'
                    ? 'https://example.com'
                    : 'C:\\Program Files\\app.exe',
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('취소'),
        ),
        ElevatedButton(
          onPressed: _saving ? null : _submit,
          child: Text(isEdit ? '저장' : '추가'),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    final name = _nameCtrl.text.trim();
    final target = _targetCtrl.text.trim();
    if (name.isEmpty || target.isEmpty) return;

    setState(() => _saving = true);

    final companion = widget.existing != null
        ? ShortcutsCompanion(
            id: Value(widget.existing!.id),
            categoryId: Value(widget.categoryId),
            name: Value(name),
            target: Value(target),
            type: Value(_type),
            sortOrder: Value(widget.existing!.sortOrder),
          )
        : ShortcutsCompanion.insert(
            categoryId: widget.categoryId,
            name: name,
            target: target,
            type: _type,
            sortOrder: 0,
          );

    await widget.onSave(companion);
    if (mounted) Navigator.pop(context);
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? colorScheme.primary.withValues(alpha: 0.15)
              : Colors.transparent,
          border: Border.all(
            color: selected
                ? colorScheme.primary
                : colorScheme.onSurface.withValues(alpha: 0.25),
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 14,
                color: selected
                    ? colorScheme.primary
                    : colorScheme.onSurface.withValues(alpha: 0.55)),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: selected
                    ? colorScheme.primary
                    : colorScheme.onSurface.withValues(alpha: 0.55),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

