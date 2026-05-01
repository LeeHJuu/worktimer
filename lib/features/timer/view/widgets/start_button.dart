import 'package:flutter/material.dart';
import 'package:worktimer/core/utils/color_utils.dart';
import 'package:worktimer/core/database/app_database.dart';

class StartButton extends StatefulWidget {
  const StartButton({
    super.key,
    required this.categories,
    required this.onStart,
  });

  final List<Category> categories;
  final ValueChanged<int> onStart;

  @override
  State<StartButton> createState() => StartButtonState();
}

class StartButtonState extends State<StartButton> {
  int? _selectedId;

  @override
  void didUpdateWidget(StartButton old) {
    super.didUpdateWidget(old);
    if (_selectedId != null &&
        !widget.categories.any((c) => c.id == _selectedId)) {
      _selectedId = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (widget.categories.isEmpty) {
      return Text(
        '관리 탭에서 카테고리를 추가하세요',
        style: TextStyle(
          color: colorScheme.onSurface.withValues(alpha: 0.38),
          fontSize: 13,
        ),
      );
    }

    return Column(
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 300),
          child: DropdownButtonFormField<int>(
            initialValue: _selectedId,
            hint: const Text('카테고리 선택'),
            decoration: const InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              border: OutlineInputBorder(),
            ),
            isExpanded: true,
            items: widget.categories
                .map(
                  (c) => DropdownMenuItem(
                    value: c.id,
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: parseHexColor(c.color),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            c.name,
                            style: const TextStyle(fontSize: 13),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
            onChanged: (v) => setState(() => _selectedId = v),
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed:
              _selectedId != null ? () => widget.onStart(_selectedId!) : null,
          icon: const Icon(Icons.play_arrow),
          label: const Text('시작'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
          ),
        ),
      ],
    );
  }
}
