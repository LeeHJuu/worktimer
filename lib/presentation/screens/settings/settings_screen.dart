import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants.dart';
import '../../../core/theme.dart';
import '../../providers/settings_provider.dart';
import '../../providers/theme_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _weekdayCtrl = TextEditingController();
  final _weekendCtrl = TextEditingController();
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final repo = ref.read(settingsRepositoryProvider);
    _weekdayCtrl.text = (await repo.getWeekdayHours()).toString();
    _weekendCtrl.text = (await repo.getWeekendHours()).toString();
    if (mounted) setState(() => _loaded = true);
  }

  Future<void> _save() async {
    final repo = ref.read(settingsRepositoryProvider);
    await repo.set(AppConstants.keyWeekdayHours, _weekdayCtrl.text);
    await repo.set(AppConstants.keyWeekendHours, _weekendCtrl.text);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('설정이 저장되었습니다.')),
      );
    }
  }

  @override
  void dispose() {
    _weekdayCtrl.dispose();
    _weekendCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('설정', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 24),

          // ── 테마 섹션 ──
          _SectionTitle(title: '테마'),
          const SizedBox(height: 12),
          const _ThemeSection(),
          const SizedBox(height: 32),

          // ── 가용 시간 ──
          _SectionTitle(title: '과부하 감지 — 가용 시간'),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _SettingField(
                  label: '평일 가용시간 (시간)',
                  controller: _weekdayCtrl,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _SettingField(
                  label: '주말 가용시간 (시간)',
                  controller: _weekendCtrl,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: _save,
            child: const Text('저장'),
          ),
          const SizedBox(height: 32),

          // ── 지원 ──
          _SectionTitle(title: '지원'),
          const SizedBox(height: 12),
          const _FeedbackSection(),
        ],
      ),
    );
  }
}

// ── 테마 섹션 ─────────────────────────────────────────────────

class _ThemeSection extends ConsumerWidget {
  const _ThemeSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeConfig = ref.watch(themeProvider);
    final notifier = ref.read(themeProvider.notifier);
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 라이트 / 다크 / 커스텀 선택
            Row(
              children: [
                _ThemeModeChip(
                  label: '다크',
                  icon: Icons.dark_mode_outlined,
                  selected: themeConfig.mode == AppThemeMode.dark,
                  onTap: () => notifier.setMode(AppThemeMode.dark),
                ),
                const SizedBox(width: 8),
                _ThemeModeChip(
                  label: '라이트',
                  icon: Icons.light_mode_outlined,
                  selected: themeConfig.mode == AppThemeMode.light,
                  onTap: () => notifier.setMode(AppThemeMode.light),
                ),
                const SizedBox(width: 8),
                _ThemeModeChip(
                  label: '커스텀',
                  icon: Icons.palette_outlined,
                  selected: themeConfig.mode == AppThemeMode.custom,
                  onTap: () => notifier.setMode(AppThemeMode.custom),
                ),
              ],
            ),

            // 커스텀 모드일 때만 색상 선택기 표시
            if (themeConfig.mode == AppThemeMode.custom) ...[
              const SizedBox(height: 16),
              Text(
                '씨앗 색상 (Seed Color)',
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  // 현재 색상 프리뷰
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () => _pickColor(context, ref, themeConfig),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: themeConfig.seedColor,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: colorScheme.outline.withValues(alpha: 0.3),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    themeConfig.seedColorHex.toUpperCase(),
                    style: TextStyle(
                      fontSize: 13,
                      fontFamily: 'monospace',
                      color: colorScheme.onSurface.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: () =>
                        _pickColor(context, ref, themeConfig),
                    icon: const Icon(Icons.colorize, size: 16),
                    label: const Text('색상 선택'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // 밝기 토글 (라이트/다크)
              Row(
                children: [
                  Text(
                    '배경 밝기',
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(width: 16),
                  SegmentedButton<Brightness>(
                    segments: const [
                      ButtonSegment(
                        value: Brightness.dark,
                        icon: Icon(Icons.dark_mode_outlined, size: 16),
                        label: Text('다크'),
                      ),
                      ButtonSegment(
                        value: Brightness.light,
                        icon: Icon(Icons.light_mode_outlined, size: 16),
                        label: Text('라이트'),
                      ),
                    ],
                    selected: {themeConfig.brightness},
                    onSelectionChanged: (s) async {
                      await ref
                          .read(themeProvider.notifier)
                          .setBrightness(s.first);
                    },
                    style: const ButtonStyle(
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _pickColor(
      BuildContext context, WidgetRef ref, AppThemeConfig config) async {
    Color pickedColor = config.seedColor;

    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('색상 선택'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: pickedColor,
            onColorChanged: (c) => pickedColor = c,
            enableAlpha: false,
            pickerAreaHeightPercent: 0.7,
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
              final argb = pickedColor.toARGB32();
              final hex =
                  '#${(argb & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';
              ref.read(themeProvider.notifier).setSeedColor(hex);
            },
            child: const Text('적용'),
          ),
        ],
      ),
    );
  }
}

// ── 테마 모드 칩 ─────────────────────────────────────────────

class _ThemeModeChip extends StatelessWidget {
  const _ThemeModeChip({
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
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: selected
                ? colorScheme.primary.withValues(alpha: 0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: selected
                  ? colorScheme.primary
                  : colorScheme.outline.withValues(alpha: 0.3),
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: selected
                    ? colorScheme.primary
                    : colorScheme.onSurface.withValues(alpha: 0.5),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight:
                      selected ? FontWeight.w600 : FontWeight.normal,
                  color: selected
                      ? colorScheme.primary
                      : colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── 공통 위젯 ─────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Text(
      title,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurface.withValues(alpha: 0.5),
        letterSpacing: 0.5,
      ),
    );
  }
}

class _SettingField extends StatelessWidget {
  const _SettingField({required this.label, required this.controller});
  final String label;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
        ),
      ],
    );
  }
}

// ── 피드백 / 버그 리포트 섹션 ─────────────────────────────────

class _FeedbackSection extends StatelessWidget {
  const _FeedbackSection();

  // 수신 주소 — UI에 노출하지 않음
  static const _to = 'xyident124@naver.com';

  Future<void> _sendMail(BuildContext context, String subject) async {
    final uri = Uri(
      scheme: 'mailto',
      path: _to,
      queryParameters: {'subject': '[WorkTimer] $subject'},
    );
    if (!await launchUrl(uri)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('이메일 앱을 열 수 없습니다.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '문제가 발생했거나 개선 아이디어가 있다면 알려주세요.',
              style: TextStyle(
                fontSize: 13,
                color: colorScheme.onSurface.withValues(alpha: 0.65),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: () => _sendMail(context, '버그 신고'),
                  icon: const Icon(Icons.bug_report_outlined, size: 16),
                  label: const Text('버그 신고'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red.shade400,
                    side: BorderSide(
                        color: Colors.red.shade400.withValues(alpha: 0.5)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                  ),
                ),
                const SizedBox(width: 10),
                OutlinedButton.icon(
                  onPressed: () => _sendMail(context, '기능 제안'),
                  icon: const Icon(Icons.lightbulb_outline, size: 16),
                  label: const Text('기능 제안'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colorScheme.primary,
                    side: BorderSide(
                        color: colorScheme.primary.withValues(alpha: 0.5)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
