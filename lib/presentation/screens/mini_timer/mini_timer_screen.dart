import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';
import '../../providers/category_provider.dart';
import '../../providers/window_provider.dart';
import '../../../domain/services/timer_service.dart';

/// 작업 중 화면에 띄워두는 소형 플로팅 타이머 창
class MiniTimerScreen extends ConsumerWidget {
  const MiniTimerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerState = ref.watch(timerServiceProvider);
    final timerNotifier = ref.read(timerServiceProvider.notifier);
    final categoriesAsync = ref.watch(categoriesProvider);
    final colorScheme = Theme.of(context).colorScheme;

    // 활성 카테고리명 조회
    final categoryName = categoriesAsync.maybeWhen(
      data: (cats) {
        if (timerState.activeCategoryId == null) return null;
        try {
          return cats
              .firstWhere((c) => c.id == timerState.activeCategoryId)
              .name;
        } catch (_) {
          return null;
        }
      },
      orElse: () => null,
    );

    // 경과 시간 포맷 (HH:MM:SS)
    final elapsed = timerState.elapsedSeconds;
    final hh = (elapsed ~/ 3600).toString().padLeft(2, '0');
    final mm = ((elapsed % 3600) ~/ 60).toString().padLeft(2, '0');
    final ss = (elapsed % 60).toString().padLeft(2, '0');
    final elapsedText = '$hh:$mm:$ss';

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: GestureDetector(
        // 창 드래그 이동
        onPanStart: (_) => windowManager.startDragging(),
        child: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                // 카테고리 색상 인디케이터
                _CategoryDot(
                  categoriesAsync: categoriesAsync,
                  activeCategoryId: timerState.activeCategoryId,
                ),
                const SizedBox(width: 8),
                // 카테고리명 + 경과시간
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (categoryName != null)
                        Text(
                          categoryName,
                          style: TextStyle(
                            fontSize: 11,
                            color: colorScheme.onSurface.withValues(alpha: 0.6),
                            height: 1.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      Text(
                        timerState.isIdle ? '타이머 대기 중' : elapsedText,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          fontFeatures: const [FontFeature.tabularFigures()],
                          color: timerState.isRunning
                              ? colorScheme.primary
                              : colorScheme.onSurface.withValues(alpha: 0.5),
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
                // 컨트롤 버튼 영역
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!timerState.isIdle) ...[
                      // 일시정지/재개
                      _MiniIconBtn(
                        icon: timerState.isRunning
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        color: colorScheme.primary,
                        tooltip: timerState.isRunning ? '일시정지' : '재개',
                        onTap: () {
                          if (timerState.isRunning) {
                            timerNotifier.pause();
                          } else {
                            timerNotifier.resume();
                          }
                        },
                      ),
                      const SizedBox(width: 4),
                      // 정지
                      _MiniIconBtn(
                        icon: Icons.stop_rounded,
                        color: Colors.red.shade400,
                        tooltip: '정지',
                        onTap: () async {
                          await timerNotifier.stop();
                        },
                      ),
                      const SizedBox(width: 4),
                    ],
                    // 원래 창으로 복귀
                    _MiniIconBtn(
                      icon: Icons.open_in_full_rounded,
                      color: colorScheme.onSurface.withValues(alpha: 0.5),
                      tooltip: '창 확장',
                      onTap: () => _exitMiniMode(ref),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _exitMiniMode(WidgetRef ref) async {
    await windowManager.setAlwaysOnTop(false);
    await windowManager.setResizable(true);
    await windowManager.setSize(const Size(1280, 720));
    await windowManager.setMinimumSize(const Size(480, 400));
    await windowManager.center();
    ref.read(miniModeProvider.notifier).state = false;
  }
}

// ── 카테고리 색상 점 ────────────────────────────

class _CategoryDot extends StatelessWidget {
  const _CategoryDot({
    required this.categoriesAsync,
    required this.activeCategoryId,
  });

  final AsyncValue<dynamic> categoriesAsync;
  final int? activeCategoryId;

  @override
  Widget build(BuildContext context) {
    Color dotColor = Theme.of(context).colorScheme.primary.withValues(alpha: 0.4);

    categoriesAsync.whenData((cats) {
      if (activeCategoryId != null) {
        try {
          final cat =
              (cats as List).firstWhere((c) => c.id == activeCategoryId);
          final hex = (cat.color as String).replaceAll('#', '');
          dotColor = Color(int.parse('FF$hex', radix: 16));
        } catch (_) {}
      }
    });

    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: dotColor,
        shape: BoxShape.circle,
      ),
    );
  }
}

// ── 미니 아이콘 버튼 ──────────────────────────────

class _MiniIconBtn extends StatelessWidget {
  const _MiniIconBtn({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Icon(icon, size: 20, color: color),
        ),
      ),
    );
  }
}
