import 'dart:convert';

import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:worktimer/core/platform/capability.dart';
import 'package:worktimer/core/database/app_database.dart';
import 'package:worktimer/features/timer/data/timer_repository.dart';
import 'package:worktimer/core/platform/capability_provider.dart';
import 'package:worktimer/core/database/database_provider.dart';
import 'package:worktimer/features/timer/data/timer_provider.dart';
import 'package:worktimer/features/mini_timer/data/mini_window_provider.dart';
import 'package:worktimer/features/timer/view/widgets/control_btn.dart';
import 'package:worktimer/features/timer/view/widgets/start_button.dart';

class TimerControls extends ConsumerWidget {
  const TimerControls({
    super.key,
    required this.state,
    required this.color,
    required this.categories,
  });

  final TimerState state;
  final Color? color;
  final List<Category> categories;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(timerServiceProvider.notifier);

    if (state.isIdle) {
      return StartButton(
        categories: categories,
        onStart: (categoryId) => notifier.start(categoryId),
      );
    }

    final canMini = ref.watch(capabilityProvider(Capability.miniWindowIPC));
    final platform = ref.watch(currentPlatformProvider);

    return Wrap(
      alignment: WrapAlignment.center,
      children: [
        ControlBtn(
          icon: state.isRunning ? Icons.pause : Icons.play_arrow,
          label: state.isRunning ? '일시정지' : '재개',
          color: Colors.orange,
          onTap: state.isRunning ? notifier.pause : notifier.resume,
        ),
        const SizedBox(width: 12),
        ControlBtn(
          icon: Icons.stop,
          label: '정지',
          color: Colors.red.shade400,
          onTap: () async {
            final sessionId = state.activeSessionId;
            await notifier.stop();
            if (context.mounted && sessionId != null) {
              await _showMemoDialog(context, ref, sessionId);
            }
          },
        ),
        if (canMini) ...[
          const SizedBox(width: 12),
          ControlBtn(
            icon: Icons.picture_in_picture_alt_rounded,
            label: '미니창',
            color: Theme.of(context)
                .colorScheme
                .onSurface
                .withValues(alpha: 0.5),
            onTap: () async {
              final existing = ref.read(miniWindowIdProvider);
              if (existing != null) {
                try {
                  await WindowController.fromWindowId(existing).show();
                } catch (_) {
                  ref.read(miniWindowIdProvider.notifier).state = null;
                }
                return;
              }
              // 미니 창에 platform을 args로 전달 (sub-process는 ProviderScope 미공유)
              final args = jsonEncode({
                'kind': 'mini',
                'platform': platform.name,
              });
              final controller =
                  await DesktopMultiWindow.createWindow(args);
              await controller.show();
              ref.read(miniWindowIdProvider.notifier).state =
                  controller.windowId;
            },
          ),
        ],
      ],
    );
  }
}

Future<void> _showMemoDialog(
  BuildContext context,
  WidgetRef ref,
  int sessionId,
) async {
  final controller = TextEditingController();
  final repo = TimerRepository(ref.read(appDatabaseProvider));

  await showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('세션 메모'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '이번 세션에 대한 메모를 남겨보세요.',
            style: Theme.of(ctx).textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: controller,
            maxLines: 3,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: '예) 3화 초안 완성, 2,000자 작성...',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('건너뛰기'),
        ),
        ElevatedButton(
          onPressed: () async {
            final memo = controller.text.trim();
            if (memo.isNotEmpty) {
              await repo.updateSessionMemo(sessionId, memo);
            }
            if (ctx.mounted) Navigator.pop(ctx);
          },
          child: const Text('저장'),
        ),
      ],
    ),
  );
  controller.dispose();
}
