import 'dart:convert';

import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import '../../../core/platform/capability.dart';
import '../../../core/platform/capability_registry.dart';

/// 미니 타이머 — 별도 플로팅 서브윈도우로 실행되는 화면.
///
/// 타이머 상태는 메인 창에서 `desktop_multi_window` IPC 로 수신.
/// 제어 버튼 → 메인 창으로 명령 전송 (`mini_command`).
///
/// [platform]은 메인 창이 [DesktopMultiWindow.createWindow] 호출 시
/// JSON args로 전달한 값을 [PlatformId]로 복원해 주입한다 — 서브 프로세스는
/// `ProviderScope`를 공유하지 않으므로 capability 판정에 필요하다.
class MiniTimerScreen extends StatefulWidget {
  const MiniTimerScreen({super.key, required this.platform});

  final PlatformId platform;

  @override
  State<MiniTimerScreen> createState() => _MiniTimerScreenState();
}

class _MiniTimerScreenState extends State<MiniTimerScreen> {
  // IPC 로 수신한 타이머 스냅샷
  String _status = 'idle'; // 'idle' | 'running' | 'paused'
  int _elapsed = 0;
  String? _categoryName;
  String _categoryColor = '#6C63FF';

  @override
  void initState() {
    super.initState();
    if (supports(Capability.miniWindowIPC, widget.platform)) {
      _setupIpcHandler();
    }
  }

  void _setupIpcHandler() {
    DesktopMultiWindow.setMethodHandler((call, fromWindowId) async {
      if (call.method == 'timer_update' && mounted) {
        final data =
            jsonDecode(call.arguments as String) as Map<String, dynamic>;
        setState(() {
          _status = (data['status'] as String?) ?? 'idle';
          _elapsed = (data['elapsed'] as int?) ?? 0;
          _categoryName = data['categoryName'] as String?;
          _categoryColor =
              (data['categoryColor'] as String?) ?? '#6C63FF';
        });
      }
      return '';
    });
  }

  /// 메인 창(windowId=0)으로 명령 전송
  Future<void> _sendCommand(String cmd) async {
    try {
      await DesktopMultiWindow.invokeMethod(
        0,
        'mini_command',
        jsonEncode({'cmd': cmd}),
      );
    } catch (_) {}
  }

  Future<void> _closeWindow() async {
    await _sendCommand('mini_closed');
    await windowManager.close();
  }

  Color _parseColor(String hex) {
    try {
      final h = hex.replaceAll('#', '');
      return Color(int.parse('FF$h', radix: 16));
    } catch (_) {
      return const Color(0xFF6C63FF);
    }
  }

  String get _elapsedText {
    final hh = (_elapsed ~/ 3600).toString().padLeft(2, '0');
    final mm = ((_elapsed % 3600) ~/ 60).toString().padLeft(2, '0');
    final ss = (_elapsed % 60).toString().padLeft(2, '0');
    return '$hh:$mm:$ss';
  }

  @override
  Widget build(BuildContext context) {
    final isIdle = _status == 'idle';
    final isRunning = _status == 'running';
    final catColor = _parseColor(_categoryColor);

    // 미니 창 전용 반투명 다크 배경
    const bgColor = Color(0xEE1E1E2E);
    const onBg = Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      body: GestureDetector(
        // 창 드래그 이동
        onPanStart: (_) => windowManager.startDragging(),
        child: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                // 카테고리 색상 인디케이터
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isIdle
                        ? onBg.withValues(alpha: 0.25)
                        : catColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),

                // 카테고리명 + 경과 시간
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_categoryName != null)
                        Text(
                          _categoryName!,
                          style: TextStyle(
                            fontSize: 11,
                            color: onBg.withValues(alpha: 0.5),
                            height: 1.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      Text(
                        isIdle ? '타이머 대기 중' : _elapsedText,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          fontFeatures: const [FontFeature.tabularFigures()],
                          color: isRunning
                              ? catColor
                              : onBg.withValues(alpha: 0.40),
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),

                // 컨트롤 버튼
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!isIdle) ...[
                      _MiniIconBtn(
                        icon: isRunning
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        color: catColor,
                        tooltip: isRunning ? '일시정지' : '재개',
                        onTap: () =>
                            _sendCommand(isRunning ? 'pause' : 'resume'),
                      ),
                      const SizedBox(width: 4),
                      _MiniIconBtn(
                        icon: Icons.stop_rounded,
                        color: Colors.red.shade400,
                        tooltip: '정지',
                        onTap: () => _sendCommand('stop'),
                      ),
                      const SizedBox(width: 4),
                    ],
                    // 닫기
                    _MiniIconBtn(
                      icon: Icons.close_rounded,
                      color: onBg.withValues(alpha: 0.40),
                      tooltip: '미니 창 닫기',
                      onTap: _closeWindow,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── 미니 아이콘 버튼 ───────────────────────────────

class _MiniIconBtn extends StatelessWidget {
  const _MiniIconBtn({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Icon(icon, size: 20, color: color),
        ),
      ),
    );
  }
}
