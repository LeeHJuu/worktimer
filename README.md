# worktimer

데스크톱 우선 Flutter 작업 시간 추적 앱.

- 카테고리별 집중 타이머 (시작/일시정지/재개/정지)
- 바로가기(웹/앱) 실행 + 자동 타이머 시작
- Windows 포커스 자동 타이머
- 미니 타이머 서브윈도우 (IPC)
- 통계, 컨디션 기록, 목표 과부하 경고
- 사용자 정의 테마

## 시작하기

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run -d windows
```

## 코드 구조

전체 아키텍처와 폴더 구조 설명은 [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) 참조.

요약:

```
lib/
├── main.dart
├── core/         # 공통 인프라 (DB, 테마, 플랫폼, 유틸)
└── features/
    ├── timer/      view/  data/    # ⭐ 타이머 도메인
    ├── mini_timer/ view/  data/
    ├── home/       view/  data/    # 홈 탭 + 사이드바
    ├── manage/     view/  data/    # 카테고리/바로가기 관리
    ├── stats/      view/  data/    # 통계
    └── settings/   view/  data/    # 설정 + 테마
```
