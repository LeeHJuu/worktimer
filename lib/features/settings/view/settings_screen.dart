import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:worktimer/core/constants.dart';
import 'package:worktimer/core/database/database_provider.dart';
import 'package:worktimer/features/settings/data/settings_provider.dart';
import 'package:worktimer/features/settings/view/widgets/feedback_section.dart';
import 'package:worktimer/features/settings/view/widgets/platform_integration_section.dart';
import 'package:worktimer/features/settings/view/widgets/reset_data_card.dart';
import 'package:worktimer/features/settings/view/widgets/section_title.dart';
import 'package:worktimer/features/settings/view/widgets/setting_row.dart';
import 'package:worktimer/features/settings/view/widgets/theme_section.dart';

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

    final showSystem = PlatformIntegrationSection.shouldRender(ref);

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

              const SectionTitle(title: '테마'),
              const SizedBox(height: 12),
              const ThemeSection(),
              const SizedBox(height: 32),

              if (showSystem) ...[
                const SectionTitle(title: '시스템'),
                const SizedBox(height: 12),
                const PlatformIntegrationSection(),
                const SizedBox(height: 32),
              ],

              const SectionTitle(title: '과부하 감지 — 가용 시간'),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Column(
                    children: [
                      SettingRow(
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
                      SettingRow(
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

              const SectionTitle(title: '지원'),
              const SizedBox(height: 12),
              const FeedbackSection(),
              const SizedBox(height: 32),

              const SectionTitle(title: '위험 구역'),
              const SizedBox(height: 12),
              ResetDataCard(onReset: _resetAllData),
            ],
          ),
        ),
      ),
    );
  }
}
