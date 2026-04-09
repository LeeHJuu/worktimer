import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';
import '../../../../core/utils/time_utils.dart';
import '../../../../data/database/app_database.dart';
import '../../../../data/repositories/timer_repository.dart';
import '../../../providers/category_provider.dart';
import '../../../providers/database_provider.dart';
import '../../../providers/timer_provider.dart';
import '../../../providers/window_provider.dart';

class TimerCard extends ConsumerWidget {
  const TimerCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerState = ref.watch(timerServiceProvider);
    final categoriesAsync = ref.watch(categoriesProvider);

    final activeCategory = categoriesAsync.valueOrNull
        ?.where((c) => c.id == timerState.activeCategoryId)
        .firstOrNull;

    final color =
        activeCategory != null ? _parseColor(activeCategory.color) : null;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _CategoryLabel(
              category: activeCategory,
              color: color,
              timerState: timerState,
            ),
            const SizedBox(height: 20),
            _ElapsedTimeDisplay(
              seconds: timerState.elapsedSeconds,
              color: color,
              status: timerState.status,
            ),
            const SizedBox(height: 28),
            _TimerControls(
              state: timerState,
              color: color,
              categories: categoriesAsync.valueOrNull ?? [],
            ),
          ],
        ),
      ),
    );
  }

  Color? _parseColor(String hex) {
    try {
      final h = hex.replaceAll('#', '');
      return Color(int.parse('FF$h', radix: 16));
    } catch (_) {
      return null;
    }
  }
}

// ── 카테고리 라벨 ─────────────────────────────

class _CategoryLabel extends StatelessWidget {
  const _CategoryLabel({
    required this.category,
    required this.color,
    required this.timerState,
  });

  final Category? category;
  final Color? color;
  final TimerState timerState;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (category == null) {
      return Text(
        '카테고리를 선택하여 타이머를 시작하세요',
        style: TextStyle(
          color: colorScheme.onSurface.withValues(alpha: 0.38),
          fontSize: 14,
        ),
        textAlign: TextAlign.center,
      );
    }

    final effectiveColor = color ?? Colors.blueAccent;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration:
              BoxDecoration(color: effectiveColor, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            category!.name,
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: effectiveColor),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (timerState.isPaused) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text('일시정지',
                style: TextStyle(
                    fontSize: 11,
                    color: Colors.orange,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ],
    );
  }
}

// ── 경과 시간 표시 ─────────────────────────────

class _ElapsedTimeDisplay extends StatelessWidget {
  const _ElapsedTimeDisplay({
    required this.seconds,
    required this.color,
    required this.status,
  });

  final int seconds;
  final Color? color;
  final TimerStatus status;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final displayColor = status == TimerStatus.idle
        ? colorScheme.onSurface.withValues(alpha: 0.12)
        : status == TimerStatus.paused
            ? Colors.orange.withValues(alpha: 0.7)
            : (color ?? Colors.blueAccent);

    return Text(
      TimeUtils.formatSeconds(seconds),
      style: TextStyle(
        fontSize: 56,
        fontWeight: FontWeight.w200,
        color: displayColor,
        fontFeatures: const [FontFeature.tabularFigures()],
        letterSpacing: 2,
      ),
    );
  }
}

// ── 컨트롤 버튼 ───────────────────────────────

class _TimerControls extends ConsumerWidget {
  const _TimerControls({
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
      return _StartButton(
        categories: categories,
        onStart: (categoryId) => notifier.start(categoryId),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _ControlBtn(
          icon: state.isRunning ? Icons.pause : Icons.play_arrow,
          label: state.isRunning ? '일시정지' : '재개',
          color: Colors.orange,
          onTap: state.isRunning ? notifier.pause : notifier.resume,
        ),
        const SizedBox(width: 12),
        _ControlBtn(
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
        const SizedBox(width: 12),
        // 미니 타이머 창 진입
        _ControlBtn(
          icon: Icons.picture_in_picture_alt_rounded,
          label: '미니창',
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
          onTap: () async {
            ref.read(miniModeProvider.notifier).state = true;
            await windowManager.setResizable(false);
            await windowManager.setSize(const Size(360, 96));
            await windowManager.setAlwaysOnTop(true);
          },
        ),
      ],
    );
  }
}

/// 세션 종료 후 메모 입력 다이얼로그
Future<void> _showMemoDialog(
    BuildContext context, WidgetRef ref, int sessionId) async {
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

// ── 시작 버튼 ─────────────────────────────────

class _StartButton extends StatefulWidget {
  const _StartButton({
    required this.categories,
    required this.onStart,
  });

  final List<Category> categories;
  final ValueChanged<int> onStart;

  @override
  State<_StartButton> createState() => _StartButtonState();
}

class _StartButtonState extends State<_StartButton> {
  int? _selectedId;

  @override
  void didUpdateWidget(_StartButton old) {
    super.didUpdateWidget(old);
    if (_selectedId != null &&
        !widget.categories.any((c) => c.id == _selectedId)) {
      _selectedId = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (widget.categories.isEmpty) {
      return Text(
        '관리 탭에서 카테고리를 추가하세요',
        style: TextStyle(
          color: colorScheme.onSurface.withValues(alpha: 0.38),
          fontSize: 13,
        ),
      );
    }

    return Column(
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 300),
          child: DropdownButtonFormField<int>(
            initialValue: _selectedId,
            hint: const Text('카테고리 선택'),
            decoration: const InputDecoration(
              isDense: true,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border: OutlineInputBorder(),
            ),
            isExpanded: true,
            items: widget.categories
                .map((c) => DropdownMenuItem(
                      value: c.id,
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _parseColor(c.color),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              c.name,
                              style: const TextStyle(fontSize: 13),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ))
                .toList(),
            onChanged: (v) => setState(() => _selectedId = v),
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed:
              _selectedId != null ? () => widget.onStart(_selectedId!) : null,
          icon: const Icon(Icons.play_arrow),
          label: const Text('시작'),
          style: ElevatedButton.styleFrom(
            padding:
                const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
          ),
        ),
      ],
    );
  }

  Color _parseColor(String hex) {
    try {
      final h = hex.replaceAll('#', '');
      return Color(int.parse('FF$h', radix: 16));
    } catch (_) {
      return Colors.blueAccent;
    }
  }
}

// ── 공통 컨트롤 버튼 ──────────────────────────

class _ControlBtn extends StatelessWidget {
  const _ControlBtn({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18, color: color),
      label: Text(label, style: TextStyle(color: color)),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: color.withValues(alpha: 0.5)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
    );
  }
}
