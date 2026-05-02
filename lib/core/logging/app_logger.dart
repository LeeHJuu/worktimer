import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// 앱 전역 로거.
///
/// - 콘솔 + 파일(일자별) 멀티 출력
/// - 포맷: `2026-05-02 14:23:01.123 [I] [filename.dart:51] message`
/// - 파일: `<appSupport>/logs/worktimer-YYYY-MM-DD.log`
/// - 7일 이전 로그 파일은 init 시 자동 삭제
class AppLog {
  AppLog._();

  static const _retentionDays = 7;
  static const _filePrefix = 'worktimer-';
  static const _fileSuffix = '.log';

  static Logger? _logger;
  static Directory? _logsDir;
  static IOSink? _sink;
  static String? _sinkDate;

  static bool get isInitialized => _logger != null;

  /// `<appSupport>/logs` 디렉토리. init 이후에만 유효.
  static Directory? get logsDir => _logsDir;

  static Future<void> init() async {
    if (_logger != null) return;
    try {
      final support = await getApplicationSupportDirectory();
      _logsDir = Directory(p.join(support.path, 'logs'));
      if (!_logsDir!.existsSync()) {
        _logsDir!.createSync(recursive: true);
      }
      await _purgeOldFiles();
    } catch (e) {
      // logs 디렉토리 자체를 못 만들면 콘솔 only로 폴백
      // ignore: avoid_print
      debugPrint('AppLog init failed (file output disabled): $e');
    }

    _logger = Logger(
      filter: ProductionFilter(),
      level: Level.debug,
      printer: _AppPrinter(),
      output: _MultiOutput([
        _ConsoleOutput(),
        if (_logsDir != null) _FileOutput(),
      ]),
    );

    FlutterError.onError = (details) {
      e('FlutterError caught', details.exception, details.stack);
    };
    PlatformDispatcher.instance.onError = (err, st) {
      e('PlatformDispatcher uncaught', err, st);
      return true;
    };

    i('AppLog initialized (logsDir=${_logsDir?.path})');
  }

  static void d(String message) =>
      _logger?.d(_Frame(message, StackTrace.current));
  static void i(String message) =>
      _logger?.i(_Frame(message, StackTrace.current));
  static void w(String message, [Object? error, StackTrace? stack]) =>
      _logger?.w(_Frame(message, StackTrace.current),
          error: error, stackTrace: stack);
  static void e(String message, [Object? error, StackTrace? stack]) =>
      _logger?.e(_Frame(message, StackTrace.current),
          error: error, stackTrace: stack);

  static Future<void> _purgeOldFiles() async {
    final dir = _logsDir;
    if (dir == null || !dir.existsSync()) return;
    final cutoff = DateTime.now().subtract(const Duration(days: _retentionDays));
    final cutoffDate = DateTime(cutoff.year, cutoff.month, cutoff.day);
    for (final entity in dir.listSync()) {
      if (entity is! File) continue;
      final name = p.basename(entity.path);
      if (!name.startsWith(_filePrefix) || !name.endsWith(_fileSuffix)) continue;
      final dateStr =
          name.substring(_filePrefix.length, name.length - _fileSuffix.length);
      final parts = dateStr.split('-');
      if (parts.length != 3) continue;
      final y = int.tryParse(parts[0]);
      final m = int.tryParse(parts[1]);
      final d = int.tryParse(parts[2]);
      if (y == null || m == null || d == null) continue;
      final fileDate = DateTime(y, m, d);
      if (fileDate.isBefore(cutoffDate)) {
        try {
          entity.deleteSync();
        } catch (_) {}
      }
    }
  }

  /// 현재 활성 일자 파일 sink. 자정 넘기면 새 파일로 전환.
  static IOSink? _activeSink() {
    final dir = _logsDir;
    if (dir == null) return null;
    final now = DateTime.now();
    final dateStr = '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
    if (_sink != null && _sinkDate == dateStr) return _sink;
    try {
      _sink?.flush();
      _sink?.close();
    } catch (_) {}
    final file = File(p.join(dir.path, '$_filePrefix$dateStr$_fileSuffix'));
    _sink = file.openWrite(mode: FileMode.append, encoding: utf8);
    _sinkDate = dateStr;
    return _sink;
  }
}

/// 메시지 + 호출자 stack을 함께 들고가기 위한 wrapper.
/// `_AppPrinter`가 파싱해 사용한다.
class _Frame {
  _Frame(this.message, this.callerStack);
  final String message;
  final StackTrace callerStack;
}

class _AppPrinter extends LogPrinter {
  static const _levelLabel = {
    Level.trace: 'T',
    Level.debug: 'D',
    Level.info: 'I',
    Level.warning: 'W',
    Level.error: 'E',
    Level.fatal: 'F',
  };

  @override
  List<String> log(LogEvent event) {
    final ts = _formatTime(event.time);
    final lvl = _levelLabel[event.level] ?? '?';
    final raw = event.message;
    String message;
    String location;
    if (raw is _Frame) {
      message = raw.message;
      location = _extractLocation(raw.callerStack);
    } else {
      message = raw.toString();
      location = '?:?';
    }
    final lines = <String>['$ts [$lvl] [$location] $message'];
    if (event.error != null) {
      lines.add('  ↳ error: ${event.error}');
    }
    if (event.stackTrace != null) {
      lines.add(_indentStack(event.stackTrace.toString()));
    }
    return lines;
  }

  static String _formatTime(DateTime t) {
    String two(int n) => n.toString().padLeft(2, '0');
    String three(int n) => n.toString().padLeft(3, '0');
    return '${t.year}-${two(t.month)}-${two(t.day)} '
        '${two(t.hour)}:${two(t.minute)}:${two(t.second)}.${three(t.millisecond)}';
  }

  /// stack trace에서 AppLog 자체 프레임을 건너뛰고 첫 호출자의 `파일명:라인` 추출.
  static String _extractLocation(StackTrace st) {
    final lines = st.toString().split('\n');
    for (final line in lines) {
      // skip AppLog's own frames
      if (line.contains('app_logger.dart')) continue;
      // dart vm: "#1      Foo.bar (package:.../timer_service.dart:51:5)"
      // web/JS:  different — best effort
      final match = RegExp(r'\(([^()]+):(\d+)(?::\d+)?\)').firstMatch(line);
      if (match != null) {
        final fullPath = match.group(1)!;
        final lineNo = match.group(2)!;
        final filename = fullPath.split('/').last.split('\\').last;
        return '$filename:$lineNo';
      }
    }
    return '?:?';
  }

  static String _indentStack(String st) {
    return st
        .split('\n')
        .where((l) => l.trim().isNotEmpty)
        .map((l) => '    $l')
        .join('\n');
  }
}

class _ConsoleOutput extends LogOutput {
  @override
  void output(OutputEvent event) {
    for (final line in event.lines) {
      debugPrint(line);
    }
  }
}

class _FileOutput extends LogOutput {
  @override
  void output(OutputEvent event) {
    try {
      final sink = AppLog._activeSink();
      if (sink == null) return;
      for (final line in event.lines) {
        sink.writeln(line);
      }
    } catch (_) {
      // 파일 쓰기 실패는 조용히 (콘솔에는 이미 찍힘)
    }
  }
}

class _MultiOutput extends LogOutput {
  _MultiOutput(this._outputs);
  final List<LogOutput> _outputs;

  @override
  void output(OutputEvent event) {
    for (final o in _outputs) {
      o.output(event);
    }
  }
}

