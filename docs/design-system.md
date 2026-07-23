# Tevio Design System

테비오 디자인 시스템은 브랜드 토큰과 반복 UI 컴포넌트를 코드에서 일관되게 쓰기 위한 최소 단위입니다. 화면을 빠르게 만들되, 색상과 타이포그래피가 화면마다 흩어지지 않게 관리합니다.

## Source Of Truth

디자인 시스템 진입점은 아래 파일입니다.

```dart
import 'package:tevio_app/shared/design_system/tevio_design_system.dart';
```

기능 화면에서는 개별 토큰 파일을 직접 import하지 않고, 이 배럴 파일을 통해 사용합니다.

## Tokens

토큰은 `lib/shared/design_system/tokens`에서 관리합니다.

- `TevioColors`: 브랜드 색상과 semantic color
- `TevioTypography`: 앱 공통 텍스트 스타일
- `TevioSpacing`: 간격 단위
- `TevioRadius`: 모서리 반경

브랜드 기준 색상:

| Token | Hex | Usage |
| --- | --- | --- |
| `primary` | `#2563EB` | 핵심 액션, 로고 심볼 |
| `deepNavy` | `#0F1E3A` | 주요 텍스트, 브랜드 워드마크 |
| `mint` | `#20BFA9` | 보조 강조, 긍정 상태 |
| `warning` | `#FF9F1C` | 만료 임박, 주의 |
| `danger` | `#E5484D` | 리콜, 위험, 실패 |
| `background` | `#F6F8FC` | 앱 배경 |
| `surface` | `#FFFFFF` | 카드와 입력 표면 |

## Component Rules

공통 컴포넌트는 `lib/shared/design_system/components`에서 관리합니다.

- `TevioLogo`: 앱 내부 브랜드 심볼. 홈 상단에서는 한글 워드마크 없이 심볼만 사용합니다.
- `TevioAppBar`: 앱 화면 상단 구조.
- `TevioBottomNavigation`: 하단 탭. 탭 라벨은 아이콘 중심으로 단순하게 유지합니다.
- `TevioButton`: primary, secondary 액션 버튼.
- `TevioCard`: 정보 묶음용 표면.
- `TevioStatusBadge`: 보증, 리콜, 알림 상태 표시.
- `TevioRightsCard`: 구매 이후 권리 요약 카드.
- `TevioStateViews`: empty, loading, error 같은 공통 상태.

새 컴포넌트를 design system에 추가하는 기준:

- 두 개 이상의 feature에서 반복된다.
- 브랜드 표현, 상태 색상, 간격 규칙이 중요하다.
- 앱 전체에서 같은 interaction 또는 visual state가 필요하다.

## Screen Implementation Rules

- 화면에서 `Color(0x...)`를 직접 쓰지 않습니다.
- 화면에서 임의의 radius, spacing 값을 반복해서 쓰지 않습니다.
- 앱 문구는 `테비오`, `구매 이후` 표현을 기준으로 작성합니다.
- 특정 화면에서만 필요한 작은 레이아웃 위젯은 feature 내부 private widget으로 둡니다.
- design system 컴포넌트는 상태와 데이터 모델을 과하게 알지 않게 유지합니다.

## Logo And Icon Rules

- 앱 아이콘은 파란 rounded square 배경 위 흰색 `t` 심볼과 mint dot을 사용합니다.
- 앱 내부 로고는 흰 배경에서 파란 `t` 심볼과 mint dot을 사용합니다.
- 홈 또는 앱바 좌측에는 한글 `테비오` 워드마크를 붙이지 않습니다.
- iOS 홈 화면 앱 이름은 시스템 라벨이므로 `TEVIO`로 표시될 수 있습니다.

## Typography

- 한국어와 영어 모두 시스템 고딕 계열을 우선 사용합니다.
- hero급 문구가 아닌 화면 내부 제목은 `titleLarge` 이하를 사용합니다.
- 버튼과 탭처럼 좁은 UI에는 긴 설명 문장을 넣지 않습니다.

## Accessibility

- 아이콘 버튼에는 의미가 필요한 경우 tooltip 또는 semantic label을 붙입니다.
- 상태 색상만으로 의미를 전달하지 않고 텍스트를 함께 둡니다.
- 터치 타깃은 가능한 44px 이상을 유지합니다.
