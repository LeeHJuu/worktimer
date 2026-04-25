import 'package:flutter/material.dart';

class AutoTimerSection extends StatelessWidget {
  const AutoTimerSection({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.center_focus_strong_outlined,
                size: 18, color: colorScheme.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '등록된 바로가기 프로그램/브라우저에 포커스된 동안에만 타이머가 동작합니다.\n'
                '타이머가 꺼진 상태에서는 포커스 변화로 타이머가 시작되지 않습니다.',
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
