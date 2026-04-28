import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'capability.dart';

/// 각 [Capability]가 지원되는 [PlatformId] 셋.
///
/// 앱 전체에서 `Platform.is*` / `kIsWeb`을 직접 호출하는 곳은 이 파일로 한정한다
/// (예외: 미니 타이머 서브윈도우는 args를 통해 [PlatformId]를 주입받음).
const _support = <Capability, Set<PlatformId>>{
  Capability.timer: {
    PlatformId.windows,
    PlatformId.macos,
    PlatformId.linux,
    PlatformId.android,
    PlatformId.ios,
    PlatformId.web,
  },
  Capability.stats: {
    PlatformId.windows,
    PlatformId.macos,
    PlatformId.linux,
    PlatformId.android,
    PlatformId.ios,
    PlatformId.web,
  },
  Capability.memo: {
    PlatformId.windows,
    PlatformId.macos,
    PlatformId.linux,
    PlatformId.android,
    PlatformId.ios,
    PlatformId.web,
  },
  Capability.categories: {
    PlatformId.windows,
    PlatformId.macos,
    PlatformId.linux,
    PlatformId.android,
    PlatformId.ios,
    PlatformId.web,
  },
  Capability.settingsBasic: {
    PlatformId.windows,
    PlatformId.macos,
    PlatformId.linux,
    PlatformId.android,
    PlatformId.ios,
    PlatformId.web,
  },
  Capability.conditionLog: {
    PlatformId.windows,
    PlatformId.macos,
    PlatformId.linux,
    PlatformId.android,
    PlatformId.ios,
    PlatformId.web,
  },

  // ── 데스크톱 전용 ────────────────────────────
  // macOS 통합은 추후 PR에서 활성화
  Capability.desktopShortcut: {PlatformId.windows},
  Capability.startupAutorun: {PlatformId.windows},
  Capability.appLaunch: {PlatformId.windows},
  Capability.installedAppsPicker: {PlatformId.windows},
  Capability.focusAutoTimer: {PlatformId.windows},
  Capability.miniWindowIPC: {PlatformId.windows},
  Capability.appUpdater: {PlatformId.windows},
};

bool supports(Capability c, PlatformId p) =>
    _support[c]?.contains(p) ?? false;

/// 현재 실행 환경의 [PlatformId]를 반환.
///
/// `Platform.is*` / `kIsWeb`은 이 함수에서만 호출된다.
PlatformId currentPlatform() {
  if (kIsWeb) return PlatformId.web;
  if (Platform.isWindows) return PlatformId.windows;
  if (Platform.isMacOS) return PlatformId.macos;
  if (Platform.isLinux) return PlatformId.linux;
  if (Platform.isAndroid) return PlatformId.android;
  if (Platform.isIOS) return PlatformId.ios;
  // Fallback — 새 플랫폼이 추가되기 전까지는 가장 보수적인 값
  return PlatformId.linux;
}

/// `PlatformId`를 [Upgrader]의 `supportedOS` 형식으로 변환할 때 사용.
String platformIdName(PlatformId p) => p.name;

/// 특정 [Capability]를 지원하는 플랫폼 이름 리스트.
List<String> supportedPlatformNames(Capability c) =>
    (_support[c] ?? const <PlatformId>{})
        .map(platformIdName)
        .toList(growable: false);
