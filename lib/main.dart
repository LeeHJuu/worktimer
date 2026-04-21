import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';
import 'core/constants.dart';
import 'core/theme.dart';
import 'domain/services/timer_service.dart';
import 'presentation/providers/auto_timer_provider.dart';
import 'presentation/providers/database_provider.dart';
import 'presentation/providers/settings_provider.dart';
import 'presentation/providers/theme_provider.dart';
import 'presentation/providers/window_provider.dart';
import 'presentation/screens/mini_timer/mini_timer_screen.dart';
import 'presentation/screens/shared/app_shell.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── 서브윈도우 (미니 타이머) 진입점 ────────────────
  if (args.firstOrNull == 'multi_window') {
    await _runMiniWindow();
    return;
  }

  // ── 메인 창 ────────────────────────────────────────
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

/// 미니 타이머 서브윈도우 초기화
Future<void> _runMiniWindow() async {
  await windowManager.ensureInitialized();
  await windowManager.waitUntilReadyToShow(
    const WindowOptions(
      size: Size(380, 100),
      alwaysOnTop: true,
      skipTaskbar: true,
      titleBarStyle: TitleBarStyle.hidden,
      windowButtonVisibility: false,
    ),
    () async {
      await windowManager.show();
    },
  );
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      // 미니 창은 별도 프로세스이므로 ProviderScope 없이 동작
      // 타이머 상태는 IPC(desktop_multi_window)로 메인 창에서 수신
      home: MiniTimerScreen(),
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

    // 자동 타이머 설정 로드 후 provider 에 반영 → AutoTimerController 인스턴스화
    final settingsRepo = ref.read(settingsRepositoryProvider);
    final autoTimerValue = await settingsRepo.get(
      AppConstants.keyAutoTimerEnabled,
      defaultValue: 'false',
    );
    ref.read(autoTimerEnabledProvider.notifier).state =
        autoTimerValue == '1';

    // 컨트롤러를 eager하게 생성 (listen이 fireImmediately: true 로 자동 enable/disable)
    ref.read(autoTimerControllerProvider);

    // 미니 타이머 IPC 브릿지 활성화
    ref.read(miniWindowBridgeProvider);

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
