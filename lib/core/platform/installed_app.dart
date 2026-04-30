/// 설치된 앱(또는 실행 가능한 바이너리) 한 항목.
///
/// Windows: 시작 메뉴의 .lnk → 실제 .exe 경로
/// macOS (예정): /Applications/*.app 경로
class InstalledApp {
  const InstalledApp({required this.name, required this.path});
  final String name;
  final String path;
}
