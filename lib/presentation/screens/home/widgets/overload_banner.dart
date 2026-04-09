import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/time_utils.dart';
import '../../../providers/overload_provider.dart';

/// 과부하 경고 배너
/// 주당 필요 시간이 가용 시간을 초과할 때 표시
class OverloadBanner extends ConsumerWidget {
  const OverloadBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overloadAsync = ref.watch(overloadResultProvider);

    return overloadAsync.when(
      data: (result) {
        if (result == null || !result.isOverloaded) {
          return const SizedBox.shrink();
        }

        final excess = result.excessHours;
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.red.shade900.withValues(alpha: 0.4),
            border: Border.all(
                color: Colors.red.shade700.withValues(alpha: 0.6)),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              const Icon(Icons.warning_amber_rounded,
                  color: Colors.orange, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '과부하 경고',
                      style: TextStyle(
                        color: Colors.orange,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '주당 필요 시간(${TimeUtils.formatHours(result.weeklyRequiredHours)})이 '
                      '가용 시간(${TimeUtils.formatHours(result.weeklyAvailableHours)})보다 '
                      '${TimeUtils.formatHours(excess.abs())} 초과합니다.',
                      style: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.6),
                          fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
