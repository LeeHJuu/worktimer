import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants.dart';
import '../../providers/auto_timer_provider.dart';
import '../../providers/database_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/windows_integration_provider.dart';

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

  Future<void> _resetAllData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('모든 데이터 초기화'),
        content: const Text(
          '타이머 세션, 컨디션 기록, 카테고리, 바로가기가 모두 삭제됩니다.\n'
          '설정은 기본값으로 초기화됩니다.\n\n'
          '이 작업은 되돌릴 수 없습니다.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade400,
              foregroundColor: Colors.white,
            ),
            child: const Text('초기화'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    await ref.read(appDatabaseProvider).resetAllData();
    ref.read(autoTimerEnabledProvider.notifier).state = false;
    await _loadSettings();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('모든 데이터가 초기화되었습니다.')),
      );
    }
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

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
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

              // ── 포커스 자동 타이머 ──
              _SectionTitle(title: '포커스 자동 타이머'),
              const SizedBox(height: 12),
              const _AutoTimerSection(),
              const SizedBox(height: 32),

              // ── 시스템 통합 ──
              _SectionTitle(title: '시스템'),
              const SizedBox(height: 12),
              const _WindowsIntegrationSection(),
              const SizedBox(height: 32),

              // ── 가용 시간 ──
              _SectionTitle(title: '과부하 감지 — 가용 시간'),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Column(
                    children: [
                      _SettingRow(
                        label: '평일 가용시간',
                        hint: '시간 단위 (예: 1.5)',
                        child: TextField(
                          controller: _weekdayCtrl,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(
                            isDense: true,
                            suffixText: 'h',
                          ),
                        ),
                      ),
                      const Divider(height: 1),
                      _SettingRow(
                        label: '주말 가용시간',
                        hint: '시간 단위 (예: 4.0)',
                        child: TextField(
                          controller: _weekendCtrl,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(
                            isDense: true,
                            suffixText: 'h',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: _save,
                child: const Text('저장'),
              ),
              const SizedBox(height: 32),

              // ── 지원 ──
              _SectionTitle(title: '지원'),
              const SizedBox(height: 12),
              const _FeedbackSection(),
              const SizedBox(height: 32),

              // ── 위험 구역 ──
              _SectionTitle(title: '위험 구역'),
              const SizedBox(height: 12),
              _ResetDataCard(onReset: _resetAllData),
            ],
          ),
        ),
      ),
    );
  }
}

// ── 자동 타이머 섹션 ──────────────────────────────────────────

class _AutoTimerSection extends ConsumerWidget {
  const _AutoTimerSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabled = ref.watch(autoTimerEnabledProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.center_focus_strong_outlined,
                    size: 18, color: colorScheme.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '등록된 바로가기 프로그램/브라우저에 포커스된 동안에만 타이머가 동작합니다.',
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('자동 타이머 사용', style: TextStyle(fontSize: 13)),
              subtitle: Text(
                '꺼짐 상태에서는 포커스 변화로 타이머가 조작되지 않습니다.',
                style: TextStyle(
                  fontSize: 11,
                  color: colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
              value: enabled,
              onChanged: (v) async {
                ref.read(autoTimerEnabledProvider.notifier).state = v;
                await ref
                    .read(settingsRepositoryProvider)
                    .set(AppConstants.keyAutoTimerEnabled, v ? '1' : '0');
              },
            ),
          ],
        ),
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── 안내 ──
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Icon(Icons.info_outline,
                    size: 16, color: colorScheme.primary),
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

        // ── 메인(배경) + 서브(강조) 컬러 ──
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
                _ColorPickerRow(
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
                _ColorPickerRow(
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

    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('색상 선택'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: picked,
            onColorChanged: (c) => picked = c,
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
              final argb = picked.toARGB32();
              final hex =
                  '#${(argb & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';
              onApply(hex);
            },
            child: const Text('적용'),
          ),
        ],
      ),
    );
  }
}

// ── 색상 선택 행 ──────────────────────────────────────────────

class _ColorPickerRow extends StatelessWidget {
  const _ColorPickerRow({
    required this.label,
    required this.color,
    required this.hexString,
    required this.onPick,
  });

  final String label;
  final Color color;
  final String hexString;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        SizedBox(
          width: 70,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ),
        const SizedBox(width: 8),
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: onPick,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: colorScheme.outline.withValues(alpha: 0.3),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          hexString,
          style: TextStyle(
            fontSize: 12,
            fontFamily: 'monospace',
            color: colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(width: 10),
        OutlinedButton.icon(
          onPressed: onPick,
          icon: const Icon(Icons.colorize, size: 14),
          label: const Text('변경', style: TextStyle(fontSize: 12)),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
      ],
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

class _SettingRow extends StatelessWidget {
  const _SettingRow({
    required this.label,
    required this.child,
    this.hint,
  });

  final String label;
  final Widget child;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurface,
                  ),
                ),
                if (hint != null)
                  Text(
                    hint!,
                    style: TextStyle(
                      fontSize: 11,
                      color: colorScheme.onSurface.withValues(alpha: 0.45),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 3,
            child: child,
          ),
        ],
      ),
    );
  }
}

// ── 데이터 초기화 카드 ────────────────────────────────────────

class _ResetDataCard extends StatelessWidget {
  const _ResetDataCard({required this.onReset});
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '모든 데이터 초기화',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.red.shade400,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '세션·컨디션·카테고리·바로가기가 전부 삭제되고 설정이 기본값으로 돌아갑니다.',
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurface.withValues(alpha: 0.55),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            OutlinedButton.icon(
              onPressed: onReset,
              icon: const Icon(Icons.delete_forever_outlined, size: 16),
              label: const Text('초기화'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red.shade400,
                side: BorderSide(
                    color: Colors.red.shade400.withValues(alpha: 0.5)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── 시스템 통합 섹션 ──────────────────────────────────────────

class _WindowsIntegrationSection extends ConsumerWidget {
  const _WindowsIntegrationSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(windowsIntegrationProvider);
    final notifier = ref.read(windowsIntegrationProvider.notifier);
    final colorScheme = Theme.of(context).colorScheme;

    if (state.loading) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Column(
          children: [
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              secondary: Icon(Icons.desktop_windows_outlined,
                  size: 18, color: colorScheme.primary),
              title: const Text('바탕화면 바로가기', style: TextStyle(fontSize: 13)),
              subtitle: Text(
                '바탕화면에 WorkTimer 바로가기를 만듭니다.',
                style: TextStyle(
                  fontSize: 11,
                  color: colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
              value: state.desktopShortcut,
              onChanged: (v) async {
                try {
                  await notifier.setDesktopShortcut(v);
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('바로가기 생성 실패: $e')),
                    );
                  }
                }
              },
            ),
            const Divider(height: 1),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              secondary: Icon(Icons.rocket_launch_outlined,
                  size: 18, color: colorScheme.primary),
              title: const Text('시작 시 자동 실행', style: TextStyle(fontSize: 13)),
              subtitle: Text(
                'Windows 로그인 후 WorkTimer를 자동으로 실행합니다.',
                style: TextStyle(
                  fontSize: 11,
                  color: colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
              value: state.startup,
              onChanged: (v) async {
                try {
                  await notifier.setStartup(v);
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('자동 실행 설정 실패: $e')),
                    );
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ── 피드백 / 버그 리포트 섹션 ─────────────────────────────────

class _FeedbackSection extends StatelessWidget {
  const _FeedbackSection();

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
