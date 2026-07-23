# TEVIO Mobile

TEVIO(테비오)는 구매 이후 전자제품의 리콜, 보증, A/S 준비 상태를 관리하는 Flutter 모바일 앱입니다.

## Sprint 0 Scope

- Flutter iOS/Android 단일 앱 기반
- Dart null safety
- development, staging, production 환경 구분
- Riverpod 앱 환경 Provider
- go_router 기반 홈/제품 등록/공개 리콜 조회/설정 화면
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

## Troubleshooting

iOS 시뮬레이터가 없으면 Xcode에서 iOS Simulator runtime을 설치합니다.

```sh
xcodebuild -downloadPlatform iOS
xcrun simctl list devices available
```

Android 기기가 없으면 Android Studio 또는 `emulator` 명령으로 에뮬레이터를 먼저 실행합니다.
