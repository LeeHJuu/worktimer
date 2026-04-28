import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/platform/capability.dart';
import '../../../providers/capability_provider.dart';
import '../../../providers/platform_integration_provider.dart';

/// 플랫폼별 데스크톱 통합(바탕화면 바로가기 / 시작 시 자동 실행) 토글.
///
/// 두 capability 모두 미지원이면 빈 위젯을 반환 → 호출부에서 SectionTitle도 함께
/// 숨길 수 있도록 [shouldRender] 헬퍼 제공.
class PlatformIntegrationSection extends ConsumerWidget {
  const PlatformIntegrationSection({super.key});

  /// 호출부가 SectionTitle 표시 여부를 결정할 때 사용.
  static bool shouldRender(WidgetRef ref) {
    final caps = ref.watch(capabilitiesProvider);
    return caps.has(Capability.desktopShortcut) ||
        caps.has(Capability.startupAutorun);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final caps = ref.watch(capabilitiesProvider);
    final hasDesktop = caps.has(Capability.desktopShortcut);
    final hasStartup = caps.has(Capability.startupAutorun);
    if (!hasDesktop && !hasStartup) return const SizedBox.shrink();

    final state = ref.watch(platformIntegrationProvider);
    final notifier = ref.read(platformIntegrationProvider.notifier);
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

    final tiles = <Widget>[];
    if (hasDesktop) {
      tiles.add(
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
      );
    }
    if (hasStartup) {
      if (tiles.isNotEmpty) tiles.add(const Divider(height: 1));
      tiles.add(
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          secondary: Icon(Icons.rocket_launch_outlined,
              size: 18, color: colorScheme.primary),
          title: const Text('시작 시 자동 실행', style: TextStyle(fontSize: 13)),
          subtitle: Text(
            '로그인 후 WorkTimer를 자동으로 실행합니다.',
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
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Column(children: tiles),
      ),
    );
  }
}
