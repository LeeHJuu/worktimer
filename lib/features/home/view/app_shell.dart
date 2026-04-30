import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:worktimer/features/home/view/home_screen.dart';
import 'package:worktimer/features/manage/view/manage_screen.dart';
import 'package:worktimer/features/home/view/sidebar.dart';

class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  int _selectedIndex = 0;

  static const _screens = [
    HomeScreen(),
    ManageScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Row(
        children: [
          // 사이드바
          Sidebar(
            selectedIndex: _selectedIndex,
            onTabSelected: (index) =>
                setState(() => _selectedIndex = index),
          ),
          // 구분선
          VerticalDivider(
            width: 1,
            thickness: 1,
            color: colorScheme.outline.withValues(alpha: 0.2),
          ),
          // 콘텐츠 영역 (전환 애니메이션)
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: child,
              ),
              child: KeyedSubtree(
                key: ValueKey(_selectedIndex),
                child: _screens[_selectedIndex],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
