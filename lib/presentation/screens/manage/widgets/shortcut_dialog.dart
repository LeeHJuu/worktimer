import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import '../../../../data/database/app_database.dart';

class ShortcutDialog extends StatefulWidget {
  const ShortcutDialog({
    super.key,
    required this.categoryId,
    required this.existing,
    required this.onSave,
  });

  final int categoryId;
  final Shortcut? existing;
  final Future<void> Function(ShortcutsCompanion companion) onSave;

  @override
  State<ShortcutDialog> createState() => _ShortcutDialogState();
}

class _ShortcutDialogState extends State<ShortcutDialog> {
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
            Row(
              children: [
                ShortcutTypeChip(
                  label: '웹 URL',
                  icon: Icons.language_outlined,
                  selected: _type == 'web',
                  onTap: () => setState(() => _type = 'web'),
                ),
                const SizedBox(width: 8),
                ShortcutTypeChip(
                  label: 'exe 파일',
                  icon: Icons.apps_outlined,
                  selected: _type == 'exe',
                  onTap: () => setState(() => _type = 'exe'),
                ),
              ],
            ),
            const SizedBox(height: 16),
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

class ShortcutTypeChip extends StatelessWidget {
  const ShortcutTypeChip({
    super.key,
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
