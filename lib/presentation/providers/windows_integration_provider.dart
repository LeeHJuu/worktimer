import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/services/windows_integration_service.dart';

final windowsIntegrationServiceProvider = Provider<WindowsIntegrationService>(
  (_) => WindowsIntegrationService(),
);

class WindowsIntegrationState {
  const WindowsIntegrationState({
    this.desktopShortcut = false,
    this.startup = false,
    this.loading = true,
  });

  final bool desktopShortcut;
  final bool startup;
  final bool loading;

  WindowsIntegrationState copyWith({
    bool? desktopShortcut,
    bool? startup,
    bool? loading,
  }) =>
      WindowsIntegrationState(
        desktopShortcut: desktopShortcut ?? this.desktopShortcut,
        startup: startup ?? this.startup,
        loading: loading ?? this.loading,
      );
}

class WindowsIntegrationNotifier
    extends StateNotifier<WindowsIntegrationState> {
  WindowsIntegrationNotifier(this._service)
      : super(const WindowsIntegrationState()) {
    _load();
  }

  final WindowsIntegrationService _service;

  Future<void> _load() async {
    final desktop = await _service.hasDesktopShortcut();
    final startup = await _service.isStartupEnabled();
    state = WindowsIntegrationState(
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

final windowsIntegrationProvider =
    StateNotifierProvider<WindowsIntegrationNotifier, WindowsIntegrationState>(
  (ref) => WindowsIntegrationNotifier(
    ref.read(windowsIntegrationServiceProvider),
  ),
);
