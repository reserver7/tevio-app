# Tevio Mobile

테비오(Tevio)는 구매 이후 제품의 리콜, 보증, 반품·교환, A/S 준비 상태를 한곳에서 관리하는 Flutter 모바일 앱입니다.

## Project

- 기본 브랜치: `main`
- Git 작성자: `reserver7 <reserver7@users.noreply.github.com>`
- 커밋 메시지: `feat: 한글 설명`, `fix: 한글 설명`, `chore: 한글 설명`
- 앱 문구 기준: `테비오`, `Tevio`, `구매 이후`
- 주요 스택: Flutter, Riverpod, go_router, Dio

세부 규격은 문서에서 관리합니다.

- [Project Standards](docs/project-standards.md)
- [Design System](docs/design-system.md)

## Current Scope

- Flutter iOS/Android 앱 기반
- development, staging, production 환경 분리
- 홈, 내 제품, 제품 상세, 제품 등록, 알림, 마이 화면 구성
- 테비오 브랜드 로고, 컬러, 타이포그래피, 공통 컴포넌트 적용
- 제품 목록과 제품별 활동 기록을 Riverpod 상태로 관리
- 알림 목록의 읽음, 삭제, 복원, 전체 읽음 처리
- 제품 권리 액션 완료 시 제품 상태, 최근 기록, 관련 알림 상태 동기화
- API 전환을 고려한 DTO, mapper, repository 경계 구성
- iOS 뒤로가기 버튼과 스와이프 내비게이션 흐름 정리
- lint, 아키텍처 테스트, 위젯 테스트 구성

## Run

초기 설정:

```sh
make setup
```

iOS:

```sh
make ios
```

Android:

```sh
make android
```

환경 변경은 `ENV` 값으로 실행합니다.

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
flutter analyze
flutter test
```

또는:

```sh
make check
```

## App Flow

- `홈`: 사용자가 지금 알아야 할 구매 이후 권리 상태를 요약합니다.
- `내 제품`: 등록된 제품 목록과 각 제품의 현재 권리 상태를 보여줍니다.
- `제품 상세`: 제품 정보, 권리 상태, 해야 할 액션, 최근 기록을 관리합니다.
- `등록`: 제품 정보를 입력하고 등록 결과를 제품 목록과 상세에 반영합니다.
- `알림`: 리콜, 보증, 정보 요청, 처리 상태 변화를 사건 기록처럼 보여줍니다.
- `마이`: 사용자 설정과 서비스 정보를 관리합니다.

제품 상세에서 권리 액션을 완료하면 제품 상태와 최근 기록이 갱신되고, 관련 알림도 읽음/완료 상태로 동기화됩니다.

## Design System

공통 UI는 `lib/shared/design_system`에서 관리합니다.

- `tokens`: color, typography, spacing, radius
- `components`: logo, app bar, button, card, badge, rights card, state views
- `models`: 권리 상태 모델

기능 전용 위젯은 각 feature 내부에 두고, 두 화면 이상에서 반복될 때만 design system으로 승격합니다.

화면에서는 `tevio_design_system.dart`를 통해 토큰과 컴포넌트를 사용합니다.

## Structure

```text
lib/
  app/                     앱 부트스트랩, 라우터, 테마
  features/
    home/                  홈
    notifications/         알림 DTO, mapper, 저장소, 화면 상태
    onboarding/            온보딩
    products/              제품 DTO, mapper, 저장소, 등록/상세/목록
    settings/              마이
  shared/
    design_system/         디자인 토큰과 공통 컴포넌트
    infrastructure/        앱 환경, HTTP 클라이언트
test/                      아키텍처, 디자인시스템, 위젯 테스트
```

## Troubleshooting

iOS 시뮬레이터가 없으면 Xcode에서 iOS Simulator runtime을 설치합니다.

```sh
xcodebuild -downloadPlatform iOS
xcrun simctl list devices available
```

Android 기기가 없으면 Android Studio 또는 `emulator` 명령으로 에뮬레이터를 먼저 실행합니다.
