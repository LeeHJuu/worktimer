/// 바로가기 실행 결과
class ShortcutLaunchResult {
  const ShortcutLaunchResult._({required this.success, this.errorMessage});

  factory ShortcutLaunchResult.success() =>
      const ShortcutLaunchResult._(success: true);

  factory ShortcutLaunchResult.failure(String message) =>
      ShortcutLaunchResult._(success: false, errorMessage: message);

  final bool success;
  final String? errorMessage;
}
