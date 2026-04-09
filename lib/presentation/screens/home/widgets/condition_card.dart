import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/condition_provider.dart';

/// 컨디션 선택 카드 (하루 1회, 5단계)
class ConditionCard extends ConsumerWidget {
  const ConditionCard({super.key});

  static const _emojis = ['😩', '😕', '😐', '🙂', '😄'];
  static const _labels = ['매우 나쁨', '나쁨', '보통', '좋음', '매우 좋음'];
  static const _colors = [
    Color(0xFFEF5350),
    Color(0xFFFF8A65),
    Color(0xFFFFCA28),
    Color(0xFF66BB6A),
    Color(0xFF42A5F5),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conditionAsync = ref.watch(todayConditionProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.mood_outlined, size: 18, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  '오늘 컨디션',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 14),
            conditionAsync.when(
              data: (log) => _ConditionSelector(
                currentLevel: log?.level,
                onSelect: (level) async {
                  final today = _todayString();
                  await ref
                      .read(conditionRepositoryProvider)
                      .saveCondition(date: today, level: level);
                  ref.invalidate(todayConditionProvider);
                },
              ),
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text('오류: $e',
                  style: const TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ),
    );
  }

  static String _todayString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }
}

class _ConditionSelector extends StatelessWidget {
  const _ConditionSelector({
    required this.currentLevel,
    required this.onSelect,
  });

  final int? currentLevel;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 이모지 선택 버튼들
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(5, (i) {
            final level = i + 1;
            final isSelected = currentLevel == level;
            final color = ConditionCard._colors[i];

            return MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => onSelect(level),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? color.withValues(alpha: 0.2)
                        : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? color
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      ConditionCard._emojis[i],
                      style: TextStyle(
                        fontSize: isSelected ? 26 : 22,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
        // 선택된 컨디션 레이블
        if (currentLevel != null) ...[
          const SizedBox(height: 10),
          Center(
            child: Text(
              ConditionCard._labels[currentLevel! - 1],
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: ConditionCard._colors[currentLevel! - 1],
              ),
            ),
          ),
        ],
      ],
    );
  }
}
