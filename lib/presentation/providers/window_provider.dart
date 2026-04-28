import 'dart:convert';

import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/platform/capability.dart';
import '../../data/database/app_database.dart';
import '../../domain/services/timer_service.dart';
import 'capability_provider.dart';
import 'category_provider.dart';
import 'timer_provider.dart';

/// 미니 타이머 서브윈도우 ID (null = 닫힘)
final miniWindowIdProvider = StateProvider<int?>((ref) => null);

/// 미니 타이머 IPC 브릿지 — 메인 창에서 eager 로드해 활성화.
///
/// 역할:
///  1. `DesktopMultiWindow.setMethodHandler` 로 미니 창 → 메인 창 명령(pause/resume/stop/mini_closed) 처리.
///  2. `timerServiceProvider` 변경 시 미니 창으로 timer_update 전송.
///  3. 미니 창이 새로 열리면(`miniWindowIdProvider` null→값) 현재 상태 즉시 전송.
///
/// 향후 미니 창에 새 기능을 도입할 때는 IPC 단일 채널이 아니라
/// "DB 중심(Drift) + IPC 보조(즉시 알림)" 모델을 따른다 — 상태 이중화 금지.
final miniWindowBridgeProvider = Provider<void>((ref) {
  if (!ref.watch(capabilityProvider(Capability.miniWindowIPC))) return;

  // ── 미니 창 → 메인 창 명령 처리 ──────────────────────
  DesktopMultiWindow.setMethodHandler((call, fromWindowId) async {
    if (call.method == 'mini_command') {
      final data =
          jsonDecode(call.arguments as String) as Map<String, dynamic>;
      final cmd = data['cmd'] as String?;
      final notifier = ref.read(timerServiceProvider.notifier);
      switch (cmd) {
        case 'pause':
          notifier.pause();
          break;
        case 'resume':
          notifier.resume();
          break;
        case 'stop':
          await notifier.stop();
          break;
        case 'mini_closed':
          ref.read(miniWindowIdProvider.notifier).state = null;
          break;
      }
    }
    return '';
  });

  // ── 타이머 상태 변경 → 미니 창 전송 ─────────────────
  ref.listen<TimerState>(timerServiceProvider, (prev, next) async {
    final windowId = ref.read(miniWindowIdProvider);
    if (windowId == null) return;
    await _pushTimerState(ref, windowId, next);
  });

  // ── 미니 창이 새로 열릴 때 현재 상태 즉시 전송 ────────
  ref.listen<int?>(miniWindowIdProvider, (prev, next) async {
    if (next == null) return;
    // 잠깐 대기 — 서브윈도우가 IPC 핸들러를 등록할 시간
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final current = ref.read(timerServiceProvider);
    await _pushTimerState(ref, next, current);
  });
});

/// 타이머 상태를 `windowId` 로 IPC 전송하는 헬퍼.
Future<void> _pushTimerState(Ref ref, int windowId, TimerState state) async {
  final cats = ref.read(categoriesProvider).valueOrNull ?? [];
  Category? cat;
  try {
    cat = cats.firstWhere((c) => c.id == state.activeCategoryId);
  } catch (_) {}

  try {
    await DesktopMultiWindow.invokeMethod(
      windowId,
      'timer_update',
      jsonEncode({
        'status': state.status.name,
        'elapsed': state.elapsedSeconds,
        'categoryId': state.activeCategoryId,
        'categoryName': cat?.name,
        'categoryColor': cat?.color ?? '#6C63FF',
      }),
    );
  } catch (_) {
    // 창이 이미 닫힌 경우 상태 초기화
    ref.read(miniWindowIdProvider.notifier).state = null;
  }
}
