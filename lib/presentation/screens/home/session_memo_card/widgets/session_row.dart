import 'package:flutter/material.dart';
import '../../../../../core/utils/color_utils.dart';
import '../../../../../core/utils/time_utils.dart';
import '../../../../../data/database/app_database.dart';

class SessionRow extends StatelessWidget {
  const SessionRow({
    super.key,
    required this.session,
    required this.categories,
  });

  final TimerSession session;
  final List<Category> categories;

  @override
  Widget build(BuildContext context) {
    final cat =
        categories.where((c) => c.id == session.categoryId).firstOrNull;
    final catColor = cat != null ? parseHexColor(cat.color) : Colors.grey;
    final colorScheme = Theme.of(context).colorScheme;

    final startTime =
        DateTime.fromMillisecondsSinceEpoch(session.startedAt * 1000);
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
                          color: colorScheme.onSurface.withValues(alpha: 0.85),
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
}
