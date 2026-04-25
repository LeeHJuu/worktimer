import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import '../../../../../data/database/app_database.dart';
import 'shortcut_type_chip.dart';

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
  bool _autoStart = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      _nameCtrl.text = widget.existing!.name;
      _targetCtrl.text = widget.existing!.target;
      _type = widget.existing!.type;
      _autoStart = widget.existing!.autoStart;
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
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '포커스 시 자동 시작',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
                Switch(
                  value: _autoStart,
                  onChanged: (v) => setState(() => _autoStart = v),
                ),
              ],
            ),
            Text(
              '이 앱/브라우저에 포커스가 가면 자동으로 타이머를 시작합니다.',
              style: TextStyle(
                fontSize: 11,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.55),
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
            autoStart: Value(_autoStart),
          )
        : ShortcutsCompanion.insert(
            categoryId: widget.categoryId,
            name: name,
            target: target,
            type: _type,
            sortOrder: 0,
            autoStart: Value(_autoStart),
          );

    await widget.onSave(companion);
    if (mounted) Navigator.pop(context);
  }
}
