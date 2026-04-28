import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/platform/capability.dart';
import '../../domain/services/platform/noop_integration_service.dart';
import '../../domain/services/platform/platform_integration_service.dart';
import '../../domain/services/platform/windows_integration_service.dart';
import 'capability_provider.dart';

/// 현재 플랫폼에 맞는 [PlatformIntegrationService] 구현체를 제공.
final platformIntegrationServiceProvider =
    Provider<PlatformIntegrationService>((ref) {
  final platform = ref.watch(currentPlatformProvider);
  late final PlatformIntegrationService impl;
  switch (platform) {
    case PlatformId.windows:
      impl = WindowsIntegrationService();
      break;
    case PlatformId.macos:
    case PlatformId.linux:
    case PlatformId.android:
    case PlatformId.ios:
    case PlatformId.web:
      impl = NoopIntegrationService();
      break;
  }
  ref.onDispose(impl.disposeForegroundWatch);
  return impl;
});

/// 데스크톱 통합 토글(바탕화면 바로가기 / 시작 시 자동 실행) 상태.
class PlatformIntegrationState {
  const PlatformIntegrationState({
    this.desktopShortcut = false,
    this.startup = false,
    this.loading = true,
  });

  final bool desktopShortcut;
  final bool startup;
  final bool loading;

  PlatformIntegrationState copyWith({
    bool? desktopShortcut,
    bool? startup,
    bool? loading,
  }) =>
      PlatformIntegrationState(
        desktopShortcut: desktopShortcut ?? this.desktopShortcut,
        startup: startup ?? this.startup,
        loading: loading ?? this.loading,
      );
}

class PlatformIntegrationNotifier
    extends StateNotifier<PlatformIntegrationState> {
  PlatformIntegrationNotifier(this._service, this._caps)
      : super(const PlatformIntegrationState()) {
    _load();
  }

  final PlatformIntegrationService _service;
  final Capabilities _caps;

  Future<void> _load() async {
    final hasAny = _caps.has(Capability.desktopShortcut) ||
        _caps.has(Capability.startupAutorun);
    if (!hasAny) {
      // 비지원 플랫폼: 즉시 종료해 UI가 무한 로딩에 빠지지 않도록.
      state = const PlatformIntegrationState(loading: false);
      return;
    }
    final desktop = _caps.has(Capability.desktopShortcut)
        ? await _service.hasDesktopShortcut()
        : false;
    final startup = _caps.has(Capability.startupAutorun)
        ? await _service.isStartupEnabled()
        : false;
    state = PlatformIntegrationState(
      desktopShortcut: desktop,
      startup: startup,
      loading: false,
    );
  }

  Future<void> setDesktopShortcut(bool enabled) async {
    await _service.setDesktopShortcut(enabled);
    state = state.copyWith(desktopShortcut: enabled);
  }

  Future<void> setStartup(bool enabled) async {
    await _service.setStartup(enabled);
    state = state.copyWith(startup: enabled);
  }
}

final platformIntegrationProvider = StateNotifierProvider<
    PlatformIntegrationNotifier, PlatformIntegrationState>(
  (ref) => PlatformIntegrationNotifier(
    ref.read(platformIntegrationServiceProvider),
    ref.read(capabilitiesProvider),
  ),
);
