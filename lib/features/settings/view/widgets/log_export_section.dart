import 'dart:io';

import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:worktimer/core/logging/app_logger.dart';

/// 진단 로그 파일을 모아 OS 공유 시트로 전달.
class LogExportSection extends StatefulWidget {
  const LogExportSection({super.key});

  @override
  State<LogExportSection> createState() => _LogExportSectionState();
}

class _LogExportSectionState extends State<LogExportSection> {
  bool _busy = false;

  Future<void> _exportAndShare() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final dir = AppLog.logsDir;
      if (dir == null || !dir.existsSync()) {
        _showSnack('로그 디렉토리를 찾을 수 없습니다.');
        return;
      }
      final files = dir
          .listSync()
          .whereType<File>()
          .where((f) {
            final name = p.basename(f.path);
            return name.startsWith('worktimer-') && name.endsWith('.log');
          })
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));

      if (files.isEmpty) {
        _showSnack('기록된 로그가 없습니다.');
        return;
      }

      final now = DateTime.now();
      String two(int n) => n.toString().padLeft(2, '0');
      final stamp =
          '${now.year}${two(now.month)}${two(now.day)}-${two(now.hour)}${two(now.minute)}${two(now.second)}';

      final tempDir = await getTemporaryDirectory();
      final outFile =
          File(p.join(tempDir.path, 'worktimer-logs-$stamp.txt'));
      final sink = outFile.openWrite();
      try {
        // 헤더 메타정보
        final pkg = await PackageInfo.fromPlatform();
        sink.writeln('===== WorkTimer 진단 로그 =====');
        sink.writeln('생성 시각: ${now.toIso8601String()}');
        sink.writeln('앱 버전: ${pkg.version}+${pkg.buildNumber}');
        sink.writeln('OS: ${Platform.operatingSystem} ${Platform.operatingSystemVersion}');
        sink.writeln('Dart: ${Platform.version}');
        sink.writeln('포함 파일 수: ${files.length}');
        sink.writeln('===============================\n');

        for (final f in files) {
          sink.writeln('----- ${p.basename(f.path)} -----');
          try {
            sink.writeln(await f.readAsString());
          } catch (e) {
            sink.writeln('(파일 읽기 실패: $e)');
          }
          sink.writeln();
        }
      } finally {
        await sink.flush();
        await sink.close();
      }

      AppLog.i('log export ready: ${outFile.path} (${files.length} files)');

      final subject =
          '[WorkTimer] 로그 파일 (${now.year}-${two(now.month)}-${two(now.day)} ${two(now.hour)}:${two(now.minute)})';
      try {
        await Share.shareXFiles(
          [XFile(outFile.path, mimeType: 'text/plain')],
          subject: subject,
          text: '오류가 발생한 시점과 상황을 함께 알려주시면 도움이 됩니다.',
        );
      } catch (e, st) {
        AppLog.e('share failed, falling back to folder open', e, st);
        _showSnack('공유에 실패했습니다. 폴더를 엽니다 — 파일을 직접 첨부해주세요.');
        await _openLogsFolder();
      }
    } catch (e, st) {
      AppLog.e('log export failed', e, st);
      _showSnack('로그 추출에 실패했습니다: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _openLogsFolder() async {
    final dir = AppLog.logsDir;
    if (dir == null) {
      _showSnack('로그 디렉토리를 찾을 수 없습니다.');
      return;
    }
    final uri = Uri.file(dir.path);
    if (!await launchUrl(uri)) {
      _showSnack('폴더를 열 수 없습니다: ${dir.path}');
    }
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '오류 진단을 위한 로그 파일을 개발자에게 전송할 수 있어요. 최근 7일치 기록이 포함됩니다.',
              style: TextStyle(
                fontSize: 13,
                color: colorScheme.onSurface.withValues(alpha: 0.65),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _busy ? null : _exportAndShare,
                  icon: _busy
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.outgoing_mail, size: 16),
                  label: const Text('로그 파일로 보내기'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                  ),
                ),
                const SizedBox(width: 10),
                TextButton.icon(
                  onPressed: _busy ? null : _openLogsFolder,
                  icon: const Icon(Icons.folder_open, size: 16),
                  label: const Text('폴더 열기'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
