import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import '../../../../data/database/app_database.dart';

class CategoryDialog extends StatefulWidget {
  const CategoryDialog({super.key, required this.existing, required this.onSave});

  final Category? existing;
  final Future<void> Function(CategoriesCompanion companion) onSave;

  @override
  State<CategoryDialog> createState() => _CategoryDialogState();
}

class _CategoryDialogState extends State<CategoryDialog> {
  final _nameCtrl = TextEditingController();
  Color _selectedColor = const Color(0xFF6C63FF);
  bool _saving = false;

  final _goalTitleCtrl = TextEditingController();
  final _goalHoursCtrl = TextEditingController();
  DateTime? _goalDeadline;
  bool _goalIsActive = false;

  bool _autoTimerOn = false;

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
      _autoTimerOn = cat.autoTimerOn;
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
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text('포커스 시 자동 시작',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface)),
                    ),
                    Switch(
                      value: _autoTimerOn,
                      onChanged: (v) =>
                          setState(() => _autoTimerOn = v),
                    ),
                  ],
                ),
                Text(
                  '등록된 바로가기 프로그램/브라우저에 포커스가 가면 idle 상태에서 자동으로 타이머를 시작합니다.',
                  style: TextStyle(
                      fontSize: 11,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.55)),
                ),
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
            autoTimerOn: Value(_autoTimerOn),
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
            autoTimerOn: Value(_autoTimerOn),
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
