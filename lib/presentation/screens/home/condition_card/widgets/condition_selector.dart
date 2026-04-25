import 'package:flutter/material.dart';

class ConditionSelector extends StatelessWidget {
  const ConditionSelector({
    super.key,
    required this.currentLevel,
    required this.onSelect,
  });

  static const emojis = ['😩', '😕', '😐', '🙂', '😄'];
  static const labels = ['매우 나쁨', '나쁨', '보통', '좋음', '매우 좋음'];
  static const colors = [
    Color(0xFFEF5350),
    Color(0xFFFF8A65),
    Color(0xFFFFCA28),
    Color(0xFF66BB6A),
    Color(0xFF42A5F5),
  ];

  final int? currentLevel;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(5, (i) {
            final level = i + 1;
            final isSelected = currentLevel == level;
            final color = colors[i];

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
                      color: isSelected ? color : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      emojis[i],
                      style: TextStyle(fontSize: isSelected ? 26 : 22),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
        if (currentLevel != null) ...[
          const SizedBox(height: 10),
          Center(
            child: Text(
              labels[currentLevel! - 1],
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: colors[currentLevel! - 1],
              ),
            ),
          ),
        ],
      ],
    );
  }
}
