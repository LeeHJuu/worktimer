import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/time_utils.dart';
import '../../../../data/database/app_database.dart';
import '../../../providers/category_provider.dart';
import '../../../providers/timer_provider.dart';

/// 오늘 세션 기록 카드 (메모 포함)
class SessionMemoCard extends ConsumerWidget {
  const SessionMemoCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsAsync = ref.watch(_todaySessionsDescProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.notes_outlined,
                    size: 18, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  '오늘 세션 기록',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 14),
            sessionsAsync.when(
              data: (sessions) {
                if (sessions.isEmpty) {
                  return Text(
                    '오늘 기록된 세션이 없습니다.',
                    style: Theme.of(context).textTheme.bodySmall,
                  );
                }
                final cats = categoriesAsync.valueOrNull ?? [];
                return Column(
                  children: sessions
                      .map((s) => _SessionRow(session: s, categories: cats))
                      .toList(),
                );
              },
              loading: () => const LinearProgressIndicator(),
              error: (e, _) =>
                  Text('오류: $e', style: const TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ),
    );
  }
}

// 오늘 세션 역순 스트림
final _todaySessionsDescProvider = StreamProvider<List<TimerSession>>((ref) {
  return ref.watch(timerRepositoryProvider).watchTodaySessionsDesc();
});

class _SessionRow extends StatelessWidget {
  const _SessionRow({required this.session, required this.categories});

  final TimerSession session;
  final List<Category> categories;

  @override
  Widget build(BuildContext context) {
    final cat = categories.where((c) => c.id == session.categoryId).firstOrNull;
    final catColor = cat != null ? _parseColor(cat.color) : Colors.grey;
    final colorScheme = Theme.of(context).colorScheme;

    final startTime = DateTime.fromMillisecondsSinceEpoch(
        session.startedAt * 1000);
    final timeStr =
        '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}';

    final duration = session.durationSec != null
        ? TimeUtils.formatSecondsToHuman(session.durationSec!)
        : '진행 중';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 시작 시각
          SizedBox(
            width: 40,
            child: Text(
              timeStr,
              style: TextStyle(
                fontSize: 11,
                color: colorScheme.onSurface.withValues(alpha: 0.45),
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
          const SizedBox(width: 8),
          // 카테고리 색상 점
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Container(
              width: 8,
              height: 8,
              decoration:
                  BoxDecoration(color: catColor, shape: BoxShape.circle),
            ),
          ),
          const SizedBox(width: 8),
          // 카테고리명 + 메모
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        cat?.name ?? '알 수 없음',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: colorScheme.onSurface
                              .withValues(alpha: 0.85),
                        ),
                      ),
                    ),
                    Text(
                      duration,
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
                if (session.memo != null && session.memo!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: Text(
                      session.memo!,
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _parseColor(String hex) {
    try {
      final h = hex.replaceAll('#', '');
      return Color(int.parse('FF$h', radix: 16));
    } catch (_) {
      return Colors.blueAccent;
    }
  }
}
