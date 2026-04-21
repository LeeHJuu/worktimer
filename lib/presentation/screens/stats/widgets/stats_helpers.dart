import 'package:flutter/material.dart';

Widget statsEmptyText(BuildContext context) => Text(
      '데이터가 없습니다.',
      style: Theme.of(context).textTheme.bodySmall,
    );

String statsFormatHours(int seconds) {
  if (seconds <= 0) return '0';
  final h = seconds ~/ 3600;
  final m = (seconds % 3600) ~/ 60;
  if (h > 0) return '${h}h';
  if (m > 0) return '${m}m';
  return '${seconds}s';
}

Color statsParseColor(String hex) {
  try {
    final h = hex.replaceAll('#', '');
    return Color(int.parse('FF$h', radix: 16));
  } catch (_) {
    return Colors.blueAccent;
  }
}
