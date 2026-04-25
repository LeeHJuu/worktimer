import 'package:flutter/material.dart';

Color parseHexColor(String hex, {Color fallback = Colors.blueAccent}) {
  try {
    return Color(int.parse('FF${hex.replaceAll('#', '')}', radix: 16));
  } catch (_) {
    return fallback;
  }
}
