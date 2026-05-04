import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:upgrader/upgrader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:window_manager/window_manager.dart';
import 'package:worktimer/core/logging/app_logger.dart';
import 'package:worktimer/core/platform/capability.dart' show PlatformId;
import 'package:worktimer/core/platform/capability_registry.dart';
import 'package:worktimer/core/theme.dart';
import 'package:worktimer/features/timer/data/timer_service.dart';
import 'package:worktimer/features/timer/data/auto_timer_provider.dart';
import 'package:worktimer/core/database/database_provider.dart';
import 'package:worktimer/features/settings/data/theme_provider.dart';
import 'package:worktimer/features/mini_timer/data/mini_window_provider.dart';
import 'package:worktimer/features/mini_timer/view/mini_timer_screen.dart';
import 'package:worktimer/features/home/view/app_shell.dart';

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
  } catch (e, st) {
    AppLog.w('window prefs load failed', e, st);
    return null;
  }
}

Future<void> _saveWindowSize(Size size) async {
  try {
    final file = await _windowPrefsFile();
    await file.writeAsString(
      jsonEncode({'width': size.width, 'height': size.height}),
    );
  } catch (e, st) {
    AppLog.w('window prefs save failed', e, st);
  }
}

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppLog.init();
  AppLog.i('main entry args=$args');

  // ── 서브윈도우 (미니 타이머) 진입점 ────────────────
  if (args.firstOrNull == 'multi_window') {
    final platform = _parseMiniArgsPlatform(args);
    AppLog.i('starting mini window platform=$platform');
    await _runMiniWindow(platform);
    return;
  }

  // ── 메인 창 ────────────────────────────────────────
  await windowManager.ensureInitialized();
  final savedSize = await _loadSavedWindowSize();
  AppLog.i('main window size=${savedSize ?? _kDefaultWindowSize} (saved=${savedSize != null})');
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
  runZonedGuarded(() {
    runApp(
      const ProviderScope(
        child: WorkTimerApp(),
      ),
    );
  }, (error, stack) {
    AppLog.e('uncaught zone error', error, stack);
  });
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
  } catch (e, st) {
    AppLog.w('mini window args parse failed', e, st);
  }
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
      // 진단용 로그(앱 stdout / `flutter logs`로 확인 가능).
      // fetch HTTP 결과, installedVersion, appStoreVersion 등을 출력한다.
      debugLogging: true,
      // 새 릴리즈가 빨리 노출되도록 주기 단축(기본 3일).
      durationUntilAlertAgain: const Duration(hours: 6),
      storeController: UpgraderStoreController(
        onWindows: () => UpgraderAppcastStore(
          appcastURL: 'https://raw.githubusercontent.com/leehjuu/worktimer/main/appcast.xml',
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
      home: _AppInitializer(upgrader: _upgrader),
    );
  }
}

/// 앱 초기화 위젯 — DB 준비 후 AppShell 표시
class _AppInitializer extends ConsumerStatefulWidget {
  const _AppInitializer({required this.upgrader});

  final Upgrader upgrader;

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
    AppLog.i('app initializing');
    try {
      ref.read(appDatabaseProvider);
      await ref.read(timerServiceProvider.notifier).recoverOpenSessions();

      // 자동 타이머 컨트롤러 eager 생성 (항상 활성)
      ref.read(autoTimerControllerProvider);

      // 미니 타이머 IPC 브릿지 활성화
      ref.read(miniWindowBridgeProvider);
      AppLog.i('app initialized');
    } catch (e, st) {
      AppLog.e('app initialization failed', e, st);
      rethrow;
    }

    if (mounted) setState(() => _initialized = true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    // 초기화 완료 후 AppShell이 마운트될 때 한 번만 UpgradeAlert가 트리에 들어가도록 한다.
    // splash 단계에서 함께 마운트하면 postFrame 콜백 타이밍이 어긋나 다이얼로그가
    // 한 번도 표시되지 않는 경우가 보고됨.
    return UpgradeAlert(
      upgrader: widget.upgrader,
      child: const AppShell(),
    );
  }
}
