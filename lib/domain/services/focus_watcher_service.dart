import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';

/// 전경 창(활성 창)의 실행 파일 경로를 주기적으로 관찰.
///
/// 변경이 있을 때만 [foregroundExePath] 스트림에 새 값을 발행.
/// null = 알 수 없음 / 조회 실패.
class FocusWatcherService {
  FocusWatcherService({this.pollInterval = const Duration(seconds: 1)});

  final Duration pollInterval;

  final _controller = StreamController<String?>.broadcast();
  Timer? _timer;
  String? _lastPath;
  bool _started = false;

  Stream<String?> get foregroundExePath => _controller.stream;

  String? get currentPath => _lastPath;

  void start() {
    if (_started) return;
    if (!Platform.isWindows) return;
    _started = true;
    _timer = Timer.periodic(pollInterval, (_) => _tick());
    _tick();
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    _started = false;
  }

  Future<void> dispose() async {
    stop();
    await _controller.close();
  }

  void _tick() {
    final path = _readForegroundExe();
    if (path != _lastPath) {
      _lastPath = path;
      _controller.add(path);
    }
  }

  String? _readForegroundExe() {
    final hwnd = GetForegroundWindow();
    if (hwnd == 0) return null;

    final pidPtr = calloc<Uint32>();
    try {
      GetWindowThreadProcessId(hwnd, pidPtr);
      final pid = pidPtr.value;
      if (pid == 0) return null;

      const accessRights = PROCESS_QUERY_LIMITED_INFORMATION;
      final hProc = OpenProcess(accessRights, FALSE, pid);
      if (hProc == 0) return null;

      try {
        final bufLen = calloc<Uint32>()..value = 1024;
        final buf = wsalloc(1024);
        try {
          final ok = QueryFullProcessImageName(hProc, 0, buf, bufLen);
          if (ok == 0) return null;
          return buf.toDartString();
        } finally {
          free(buf);
          calloc.free(bufLen);
        }
      } finally {
        CloseHandle(hProc);
      }
    } finally {
      calloc.free(pidPtr);
    }
  }
}
