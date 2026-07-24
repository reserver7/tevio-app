# Tevio Project Standards

이 문서는 테비오 Flutter 앱의 기본 작업 규격입니다. Sprint 0 기준에서는 앱을 빠르게 실행 가능한 상태로 유지하면서, 이후 기능 추가가 흔들리지 않도록 최소한의 실무 규칙만 고정합니다.

## Product Language

- 서비스명은 한글에서는 `테비오`, 영문에서는 `Tevio`를 사용합니다.
- 핵심 표현은 `구매 이후`입니다.
- `산 이후`, `컨슈머`, `소비자 권리관리`처럼 브랜드 톤이 좁아지거나 딱딱한 표현은 앱 문구에서 사용하지 않습니다.
- 문장은 사용자가 해야 할 행동과 테비오가 대신 챙기는 가치를 자연스럽게 말합니다.

예시:

- `테비오가 확인했어요`
- `테비오에 내 제품을 등록하세요`
- `중요한 순간은 테비오가 알려드려요`
- `구매 이후의 권리를 테비오가 챙길게요`

## Branch And Commit

- 기본 브랜치는 `main`입니다.
- 로컬 Git 작성자는 `reserver7 <reserver7@users.noreply.github.com>`를 사용합니다.
- 커밋 메시지는 Conventional Commits 형식을 사용하고, 콜론 뒤 설명은 한글로 작성합니다.

예시:

```text
feat: 테비오 제품 등록 화면 추가
fix: iOS 뒤로가기 동작 보정
chore: 실행 명령 정리
docs: 프로젝트 규격 문서 추가
```

## App Environments

앱 환경은 `APP_ENV`와 `API_BASE_URL`로 구분합니다.

- `development`: 개발용 기본 환경
- `staging`: 배포 전 검수 환경
- `production`: 실제 서비스 환경

환경값은 `lib/core/config/app_environment.dart`에서 읽고, 실행 명령은 `Makefile`에서 관리합니다.

## Directory Rules

```text
lib/
  app/                 앱 조립, 라우터, 테마, 부트스트랩
  core/                설정, 네트워크, 공통 인프라
  features/            기능 단위 화면과 상태
  shared/design_system 공통 디자인 토큰과 컴포넌트
```

- 화면은 `features/{feature}/presentation/pages`에 둡니다.
- 한 기능 안에서만 쓰는 위젯은 해당 feature 내부에 둡니다.
- 두 개 이상의 기능에서 반복되거나 브랜드 일관성이 필요한 UI만 design system으로 승격합니다.
- 앱 전역 테마는 `lib/app/theme/app_theme.dart`에서만 조립합니다.

## Routing Rules

- 라우팅은 `go_router`를 사용합니다.
- 앱 하단 탭은 `홈`, `내 제품`, `등록`, `마이` 4개를 기준으로 유지합니다.
- 알림은 하단 탭이 아니라 홈 상단 알림 아이콘에서 진입합니다.
- 현재 단계에서 전역 검색은 제공하지 않습니다.
- iOS 사용자가 기대하는 뒤로가기 제스처를 막지 않도록, 일반 화면 전환은 Flutter 기본 `Navigator`/`go_router` 흐름을 따릅니다.
- 탭 전환은 새 페이지 push가 아니라 shell branch 이동으로 처리합니다.

## Dependency Rules

- 런타임 의존성은 실제 기능 구현에 필요한 경우에만 추가합니다.
- 디자인 시스템만을 위해 무거운 UI 프레임워크를 추가하지 않습니다.
- 새 패키지를 추가하면 `pubspec.lock`을 함께 갱신합니다.

## Mock Data Rules

- 실제 API가 연결되지 않은 화면은 feature의 `data/mock_*.dart`에서 샘플 데이터를 관리합니다.
- 화면 파일에 제품, 알림, 권리 상태 샘플 데이터를 직접 길게 작성하지 않습니다.
- mock 모델은 이후 repository 또는 service 구현으로 교체하기 쉽도록 feature의 `domain/models`에 둡니다.

## Verification Policy

평소 권장 검증 명령은 아래와 같습니다.

```sh
make check
```

`test/architecture_test.dart`는 문서 규칙 중 아래 항목을 코드로 강제합니다.

- 앱과 feature는 `tevio_design_system.dart` 배럴만 import합니다.
- raw color, Material `Colors`, raw `TextStyle`, raw radius 사용은 token 파일 밖에서 금지합니다.
- 금지된 브랜드 문구는 앱 코드에 들어가지 않게 막습니다.

다만 현재 작업 흐름에서는 사용자가 요청할 때만 검증 명령을 실행합니다.
