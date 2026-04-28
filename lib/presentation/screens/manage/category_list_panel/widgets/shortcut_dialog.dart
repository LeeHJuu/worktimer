import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/platform/capability.dart';
import '../../../../../data/database/app_database.dart';
import '../../../../../domain/services/platform/installed_app.dart';
import '../../../../providers/capability_provider.dart';
import 'app_picker_dialog.dart';
import 'shortcut_type_chip.dart';

class ShortcutDialog extends ConsumerStatefulWidget {
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
  ConsumerState<ShortcutDialog> createState() => _ShortcutDialogState();
}

class _ShortcutDialogState extends ConsumerState<ShortcutDialog> {
  final _nameCtrl = TextEditingController();
  final _targetCtrl = TextEditingController();
  String _type = 'web';
  bool _autoStart = true;
  bool _saving = false;
  bool _isNormalizingText = false;

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      _nameCtrl.text = widget.existing!.name;
      _targetCtrl.text = widget.existing!.target;
      _type = _normalizeType(widget.existing!.type);
      _autoStart = widget.existing!.autoStart;
    }
    _targetCtrl.addListener(_onTargetChanged);
  }

  @override
  void dispose() {
    _targetCtrl.removeListener(_onTargetChanged);
    _nameCtrl.dispose();
    _targetCtrl.dispose();
    super.dispose();
  }

  /// 구버전(v4 이하) 데이터 'exe' 값을 안전하게 'app'으로 정규화.
  String _normalizeType(String raw) => raw == 'exe' ? 'app' : raw;

  void _onTargetChanged() {
    if (_isNormalizingText) return;
    final raw = _targetCtrl.text;
    final stripped = _stripQuotes(raw);
    if (stripped != raw) {
      _isNormalizingText = true;
      _targetCtrl.text = stripped;
      _targetCtrl.selection =
          TextSelection.collapsed(offset: stripped.length);
      _isNormalizingText = false;
    }
    _autoDetectType(stripped);
  }

  String _stripQuotes(String s) {
    if (s.length >= 2 && s.startsWith('"') && s.endsWith('"')) {
      return s.substring(1, s.length - 1);
    }
    return s;
  }

  void _autoDetectType(String text) {
    final t = text.trim();
    final canApp = ref.read(capabilityProvider(Capability.appLaunch));
    if (t.startsWith('http://') || t.startsWith('https://')) {
      if (_type != 'web') setState(() => _type = 'web');
    } else if (canApp && t.toLowerCase().endsWith('.exe')) {
      if (_type != 'app') setState(() => _type = 'app');
    }
  }

  Future<void> _pickApp() async {
    final app = await showDialog<InstalledApp>(
      context: context,
      builder: (_) => const AppPickerDialog(),
    );
    if (app == null) return;
    setState(() {
      _nameCtrl.text = app.name;
      _targetCtrl.text = app.path;
      _type = 'app';
    });
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    final canApp = ref.watch(capabilityProvider(Capability.appLaunch));
    final canPicker =
        ref.watch(capabilityProvider(Capability.installedAppsPicker));

    // 비지원 플랫폼에서 'app' 타입이 잡혀 있으면 web으로 강제
    if (!canApp && _type == 'app') {
      _type = 'web';
    }

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
                if (canApp) ...[
                  const SizedBox(width: 8),
                  ShortcutTypeChip(
                    label: '앱',
                    icon: Icons.apps_outlined,
                    selected: _type == 'app',
                    onTap: () => setState(() => _type = 'app'),
                  ),
                ],
              ],
            ),
            if (_type == 'app' && canPicker) ...[
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: _pickApp,
                icon: const Icon(Icons.search, size: 14),
                label: const Text('앱 선택'),
                style: OutlinedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  textStyle: const TextStyle(fontSize: 13),
                ),
              ),
            ],
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
                labelText: _type == 'web' ? 'URL (https://...)' : '앱 실행파일 경로',
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
