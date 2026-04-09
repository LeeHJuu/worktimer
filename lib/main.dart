import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';
import 'core/theme.dart';
import 'domain/services/timer_service.dart';
import 'presentation/providers/database_provider.dart';
import 'presentation/providers/theme_provider.dart';
import 'presentation/screens/shared/app_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  const windowOptions = WindowOptions(
    size: Size(1280, 720),
    minimumSize: Size(480, 400),
    center: true,
    title: 'WorkTimer',
  );
  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });
  runApp(
    const ProviderScope(
      child: WorkTimerApp(),
    ),
  );
}

class WorkTimerApp extends ConsumerWidget {
  const WorkTimerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeConfig = ref.watch(themeProvider);
    final themeData = AppTheme.buildTheme(themeConfig);

    return MaterialApp(
      title: 'WorkTimer',
      debugShowCheckedModeBanner: false,
      theme: themeData,
      home: const _AppInitializer(),
    );
  }
}

/// 앱 초기화 위젯 — DB 준비 후 AppShell 표시
class _AppInitializer extends ConsumerStatefulWidget {
  const _AppInitializer();

  @override
  ConsumerState<_AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends ConsumerState<_AppInitializer> {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    ref.read(appDatabaseProvider);
    await ref.read(timerServiceProvider.notifier).recoverOpenSessions();
    if (mounted) setState(() => _initialized = true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return const AppShell();
  }
}
