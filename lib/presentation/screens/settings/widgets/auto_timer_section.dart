import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants.dart';
import '../../../providers/auto_timer_provider.dart';
import '../../../providers/settings_provider.dart';

class AutoTimerSection extends ConsumerWidget {
  const AutoTimerSection({super.key});

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
