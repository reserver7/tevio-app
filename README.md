# TEVIO Mobile

TEVIO(테비오)는 구매 이후 전자제품의 리콜, 보증, A/S 준비 상태를 관리하는 Flutter 모바일 앱입니다.

## Standards

- 기본 브랜치: `main`
- Git 작성자: `reserver7 <reserver7@users.noreply.github.com>`
- 커밋 메시지: `feat: 한글 설명`, `fix: 한글 설명`, `chore: 한글 설명`
- 앱 문구 기준: `테비오`, `Tevio`, `구매 이후`

세부 규격은 문서에서 관리합니다.

- [Project Standards](docs/project-standards.md)
- [Design System](docs/design-system.md)

## Sprint 0

- Flutter iOS/Android 단일 앱 기반
- Dart null safety
- development, staging, production 환경 구분
- Riverpod 앱 환경 Provider
- go_router 기반 홈/내 제품/등록/마이 화면과 알림 진입 흐름
- Dio 공통 클라이언트 기반
- 주요 런타임 패키지와 lockfile 고정
- 기본 lint/test/CI 구성

## Run

```sh
make setup
make ios
```

Android:

```sh
make android
```

환경 변경:

```sh
make ios ENV=staging
make android ENV=production
```

기본 iOS 시뮬레이터는 `iPhone 17`입니다. 다른 시뮬레이터를 쓰려면:

```sh
make ios IOS_SIMULATOR="iPhone 17 Pro"
```

## Verify

```sh
make check
```

## Design System

공통 UI는 `lib/shared/design_system`에서 관리합니다.

- `tokens`: color, typography, spacing, radius
- `components`: logo, app bar, button, card, badge, rights card, state views
- `models`: 권리 상태 모델

기능 전용 위젯은 각 feature 내부에 두고, 두 화면 이상에서 반복될 때만 design system으로 승격합니다.

화면에서는 `tevio_design_system.dart`를 통해 토큰과 컴포넌트를 사용합니다.

## Troubleshooting

iOS 시뮬레이터가 없으면 Xcode에서 iOS Simulator runtime을 설치합니다.

```sh
xcodebuild -downloadPlatform iOS
xcrun simctl list devices available
```

Android 기기가 없으면 Android Studio 또는 `emulator` 명령으로 에뮬레이터를 먼저 실행합니다.
