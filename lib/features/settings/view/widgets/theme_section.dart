import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:worktimer/features/settings/data/theme_provider.dart';
import 'package:worktimer/features/settings/view/widgets/color_picker_row.dart';

class ThemeSection extends ConsumerWidget {
  const ThemeSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeConfig = ref.watch(themeProvider);
    final notifier = ref.read(themeProvider.notifier);
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: colorScheme.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '메인 컬러가 밝으면 라이트 테마, 어두우면 다크 테마가 자동 적용됩니다.',
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '컬러 커스텀',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 14),
                ColorPickerRow(
                  label: '메인 (배경)',
                  color: themeConfig.backgroundColor,
                  hexString: themeConfig.backgroundColorHex.toUpperCase(),
                  onPick: () => _pickColor(
                    context,
                    ref,
                    themeConfig.backgroundColor,
                    (hex) => notifier.setBackgroundColor(hex),
                  ),
                ),
                const SizedBox(height: 12),
                ColorPickerRow(
                  label: '서브 (강조)',
                  color: themeConfig.accentColor,
                  hexString: themeConfig.accentColorHex.toUpperCase(),
                  onPick: () => _pickColor(
                    context,
                    ref,
                    themeConfig.accentColor,
                    (hex) => notifier.setAccentColor(hex),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickColor(
    BuildContext context,
    WidgetRef ref,
    Color initial,
    void Function(String hex) onApply,
  ) async {
    Color picked = initial;
    final hexController = TextEditingController(text: _colorToHex(initial));

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('색상 선택'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ColorPicker(
                  pickerColor: picked,
                  onColorChanged: (c) {
                    setState(() {
                      picked = c;
                      hexController.text = _colorToHex(c);
                    });
                  },
                  enableAlpha: false,
                  pickerAreaHeightPercent: 0.7,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: hexController,
                  decoration: const InputDecoration(
                    labelText: '헥스 코드',
                    hintText: '#FFFFFF',
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  style: const TextStyle(fontFamily: 'monospace'),
                  onChanged: (value) {
                    final match = RegExp(r'^#?([0-9A-Fa-f]{6})$')
                        .firstMatch(value.trim());
                    if (match != null) {
                      setState(() {
                        picked = Color(
                          int.parse('FF${match.group(1)!}', radix: 16),
                        );
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                onApply(_colorToHex(picked));
              },
              child: const Text('적용'),
            ),
          ],
        ),
      ),
    );
    hexController.dispose();
  }

  String _colorToHex(Color color) {
    final argb = color.toARGB32();
    return '#${(argb & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';
  }
}
