import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/platform/capability.dart';
import '../../core/platform/capability_registry.dart';

/// 현재 실행 플랫폼 — 단일 진입점.
final currentPlatformProvider = Provider<PlatformId>(
  (_) => currentPlatform(),
);

/// 한 번에 여러 capability를 조회할 때 사용.
class Capabilities {
  const Capabilities(this.platform);
  final PlatformId platform;
  bool has(Capability c) => supports(c, platform);
}

final capabilitiesProvider = Provider<Capabilities>(
  (ref) => Capabilities(ref.watch(currentPlatformProvider)),
);

/// 단일 capability를 위젯 build에서 watch할 때 사용.
final capabilityProvider = Provider.family<bool, Capability>(
  (ref, c) => ref.watch(capabilitiesProvider).has(c),
);
