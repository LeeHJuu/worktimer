import 'package:flutter/material.dart';

const double kHomePanelWidth = 380;

class HomePanel extends StatelessWidget {
  const HomePanel({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: kHomePanelWidth, child: child);
  }
}
