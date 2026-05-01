import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:worktimer/features/manage/data/icon_service.dart';
import 'package:worktimer/core/platform/platform_integration_provider.dart';

final iconServiceProvider = Provider<IconService>((ref) {
  return IconService(ref.watch(platformIntegrationServiceProvider));
});

/// app 타입 바로가기의 아이콘 PNG 경로를 반환하는 family provider.
/// 캐시 미스 시 PowerShell로 추출. 실패 시 null.
final appIconPathProvider =
    FutureProvider.family<String?, ({int id, String exePath})>((ref, args) {
  return ref
      .watch(iconServiceProvider)
      .resolveAppIconPath(args.id, args.exePath);
});
