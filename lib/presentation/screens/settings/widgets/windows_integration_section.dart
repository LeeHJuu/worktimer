import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/windows_integration_provider.dart';

class WindowsIntegrationSection extends ConsumerWidget {
  const WindowsIntegrationSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(windowsIntegrationProvider);
    final notifier = ref.read(windowsIntegrationProvider.notifier);
    final colorScheme = Theme.of(context).colorScheme;

    if (state.loading) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(
            child: SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
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
