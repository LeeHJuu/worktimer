import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class FeedbackSection extends StatelessWidget {
  const FeedbackSection({super.key});

  static const _to = 'xyident124@naver.com';

  Future<void> _sendMail(BuildContext context, String subject) async {
    final uri = Uri(
      scheme: 'mailto',
      path: _to,
      queryParameters: {'subject': '[WorkTimer] $subject'},
    );
    if (!await launchUrl(uri)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('이메일 앱을 열 수 없습니다.')),
        );
      }
    }
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
              '문제가 발생했거나 개선 아이디어가 있다면 알려주세요.',
              style: TextStyle(
                fontSize: 13,
                color: colorScheme.onSurface.withValues(alpha: 0.65),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: () => _sendMail(context, '버그 신고'),
                  icon: const Icon(Icons.bug_report_outlined, size: 16),
                  label: const Text('버그 신고'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red.shade400,
                    side: BorderSide(
                        color: Colors.red.shade400.withValues(alpha: 0.5)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                  ),
                ),
                const SizedBox(width: 10),
                OutlinedButton.icon(
                  onPressed: () => _sendMail(context, '기능 제안'),
                  icon: const Icon(Icons.lightbulb_outline, size: 16),
                  label: const Text('기능 제안'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colorScheme.primary,
                    side: BorderSide(
                        color: colorScheme.primary.withValues(alpha: 0.5)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
