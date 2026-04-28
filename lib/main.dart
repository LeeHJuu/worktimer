import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:upgrader/upgrader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:window_manager/window_manager.dart';
import 'core/platform/capability.dart';
import 'core/platform/capability_registry.dart';
import 'core/theme.dart';
import 'domain/services/timer_service.dart';
import 'presentation/providers/auto_timer_provider.dart';
import 'presentation/providers/database_provider.dart';
import 'presentation/providers/theme_provider.dart';
import 'presentation/providers/window_provider.dart';
import 'presentation/screens/mini_timer/mini_timer_screen.dart';
import 'presentation/screens/shared/app_shell.dart';

const _kDefaultWindowSize = Size(1280, 720);

Future<File> _windowPrefsFile() async {
  final dir = await getApplicationSupportDirectory();
  return File('${dir.path}/window_prefs.json');
}

Future<Size?> _loadSavedWindowSize() async {
  try {
    final file = await _windowPrefsFile();
    if (!file.existsSync()) return null;
    final data = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
    return Size(
      (data['width'] as num).toDouble(),
      (data['height'] as num).toDouble(),
    );
  } catch (_) {
    return null;
  }
}

Future<void> _saveWindowSize(Size size) async {
  try {
    final file = await _windowPrefsFile();
    await file.writeAsString(
      jsonEncode({'width': size.width, 'height': size.height}),
    );
  } catch (_) {}
}

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── 서브윈도우 (미니 타이머) 진입점 ────────────────
  if (args.firstOrNull == 'multi_window') {
    final platform = _parseMiniArgsPlatform(args);
    await _runMiniWindow(platform);
    return;
  }

  // ── 메인 창 ────────────────────────────────────────
  await windowManager.ensureInitialized();
  final savedSize = await _loadSavedWindowSize();
  final windowOptions = WindowOptions(
    size: savedSize ?? _kDefaultWindowSize,
    minimumSize: const Size(480, 400),
    center: savedSize == null, // 최초 실행 시에만 중앙 배치
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

/// 미니 타이머 서브윈도우 args에서 platform 추출.
///
/// `desktop_multi_window`는 sub-process 호출 시 args를
/// `['multi_window', '<windowId>', '<userArgsJson>']` 형태로 전달한다.
/// userArgsJson은 메인 창이 createWindow에 넘긴 문자열.
PlatformId _parseMiniArgsPlatform(List<String> args) {
  if (args.length < 3) return currentPlatform();
  try {
    final raw = args[2];
    final data = jsonDecode(raw);
    if (data is Map<String, dynamic>) {
      final name = data['platform'] as String?;
      if (name != null) {
        for (final p in PlatformId.values) {
          if (p.name == name) return p;
        }
      }
    }
  } catch (_) {}
  return currentPlatform();
}

/// 미니 타이머 서브윈도우 초기화
Future<void> _runMiniWindow(PlatformId platform) async {
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
    MaterialApp(
      debugShowCheckedModeBanner: false,
      // 미니 창은 별도 프로세스이므로 ProviderScope 없이 동작
      // 타이머 상태는 IPC(desktop_multi_window)로 메인 창에서 수신
      home: MiniTimerScreen(platform: platform),
    ),
  );
}

class WorkTimerApp extends ConsumerStatefulWidget {
  const WorkTimerApp({super.key});

  @override
  ConsumerState<WorkTimerApp> createState() => _WorkTimerAppState();
}

class _WorkTimerAppState extends ConsumerState<WorkTimerApp> {
  late final Upgrader _upgrader;

  @override
  void initState() {
    super.initState();
    _upgrader = Upgrader(
      storeController: UpgraderAppcastStoreController(
        appcastConfig: AppcastConfiguration(
          url: 'https://raw.githubusercontent.com/leehjuu/worktimer/main/appcast.xml',
          supportedOS: supportedPlatformNames(Capability.appUpdater),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeConfig = ref.watch(themeProvider);
    final themeData = AppTheme.buildTheme(themeConfig);

    return MaterialApp(
      title: 'WorkTimer',
      debugShowCheckedModeBanner: false,
      theme: themeData,
      home: UpgradeAlert(
        upgrader: _upgrader,
        child: const _AppInitializer(),
      ),
    );
  }
}

/// 앱 초기화 위젯 — DB 준비 후 AppShell 표시
class _AppInitializer extends ConsumerStatefulWidget {
  const _AppInitializer();

  @override
  ConsumerState<_AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends ConsumerState<_AppInitializer>
    with WindowListener {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    _initialize();
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  void onWindowResized() async {
    final size = await windowManager.getSize();
    await _saveWindowSize(size);
  }

  Future<void> _initialize() async {
    ref.read(appDatabaseProvider);
    await ref.read(timerServiceProvider.notifier).recoverOpenSessions();

    // 자동 타이머 컨트롤러 eager 생성 (항상 활성)
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
