import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../data/database/app_database.dart';
import '../../../../providers/timer_provider.dart';

class StartStopButton extends ConsumerWidget {
  const StartStopButton({
    super.key,
    required this.category,
    required this.isActive,
    required this.timerStatus,
    required this.color,
  });

  final Category category;
  final bool isActive;
  final TimerStatus timerStatus;
  final Color color;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerNotifier = ref.read(timerServiceProvider.notifier);

    if (isActive && timerStatus == TimerStatus.running) {
      return _btn(
        color: Colors.redAccent,
        bg: Colors.red,
        icon: Icons.stop_rounded,
        label: '정지',
        onTap: () async => timerNotifier.stop(),
      );
    }
    if (isActive && timerStatus == TimerStatus.paused) {
      return _btn(
        color: Colors.orange,
        bg: Colors.orange,
        icon: Icons.play_arrow_rounded,
        label: '재개',
        onTap: () => timerNotifier.resume(),
      );
    }
    return _btn(
      color: color,
      bg: color,
      icon: Icons.play_arrow_rounded,
      label: '시작',
      onTap: () async {
        if (timerStatus != TimerStatus.idle && !isActive) {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('카테고리 전환'),
              content: Text(
                  '현재 타이머를 종료하고\n"${category.name}"으로 전환하시겠습니까?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('취소'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('전환'),
                ),
              ],
            ),
          );
          if (confirm == true) await timerNotifier.switchCategory(category.id);
        } else {
          await timerNotifier.start(category.id);
        }
      },
    );
  }

  Widget _btn({
    required Color color,
    required Color bg,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
          decoration: BoxDecoration(
            color: bg.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 13, color: color),
              const SizedBox(width: 3),
              Text(label, style: TextStyle(fontSize: 11, color: color)),
            ],
          ),
        ),
      ),
    );
  }
}
