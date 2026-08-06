# Tevio Design System

테비오 디자인 시스템은 `foundation`, `core`, `pattern`, `screen` 계층으로 운영합니다.

## 계층

- `tokens`: 색상, semantic color, typography, spacing, radius, dimensions, motion
- `components`: 버튼, 입력, 선택, 상태, 카드, 탐색, 피드백, 오버레이
- `patterns`: 단일 행동 카드, 목록 행, 보조 행동, 제품 카드, 권리 상태,
  알림 사건, 등록 단계, 필터, 폼 섹션
- `screens`: 화면은 위 컴포넌트와 패턴을 조합하며 직접 스타일 값을 최소화합니다.

## 컴포넌트 계약

- `TevioSearchField`, `TevioSelectField`, `TevioTextField`: 입력·검색·선택의
  label, helper, error, focus, disabled 계약을 제공합니다.
- `TevioCheckControl`, `TevioRadioControl`, `TevioSwitch`,
  `TevioSegmentedControl`, `TevioTabs`: 선택 상태와 접근성 그룹 정보를 함께
  제공합니다.
- `TevioProgress`, `TevioSkeleton`, `TevioStateViews`: 로딩과 진행 상태를
  화면 간 일관되게 표현합니다. skeleton은 `animate: false`로 정적인 검토
  상태도 지원합니다.
- `TevioDateField`, `TevioDocumentPreview`, `TevioPermissionRequest`: 외부
  기능의 disabled, loading, error, retry, fallback 행동을 공통으로 감쌉니다.
- `TevioSheet`, `TevioDialog`, `TevioConfirmSheet`: 취소, destructive,
  disabled confirmation, dismiss policy를 명시적으로 다룹니다.

## 상태 규칙

모든 interactive component는 다음 상태를 고려합니다.

- default
- pressed
- focused
- disabled
- loading
- error
- selected
- success
- warning
- destructive

상태 색상은 원시 색상 대신 `TevioSemanticColors`와 `RightsStatus`를 사용합니다.

## 운영 UX 규격

- 한 surface는 하나의 주된 의사결정만 담습니다. 정보 요약과 동일한 행동을
  다른 카드에 반복하지 않습니다.
- 제품·권리·알림 사건은 상태, 맥락, 설명, 다음 행동 순서로 읽힙니다.
- 이동 가능한 행은 화살표를 표시하고, 단순 정보 행은 값만 표시합니다.
- `처리 중`은 상태가 전환될 때만 짧게 움직이며, 그 외 상태에는 지속 모션을
  사용하지 않습니다.
- 읽음 처리된 알림은 대비를 낮추되, 삭제나 중요한 상태를 숨기지 않습니다.

## 사용 규칙

- 주요 행동은 한 화면에 하나만 둡니다.
- 터치 영역은 최소 44pt, 주요 버튼은 52pt를 사용합니다.
- 페이지의 섹션 간격은 `TevioSpacing`을 사용합니다.
- 카드·버튼·배지는 직접 `BoxDecoration`을 만들지 않고 공통 컴포넌트를 우선 사용합니다.
- 상태는 색상만으로 전달하지 않고 텍스트와 아이콘을 함께 제공합니다.
- 사용자가 결정할 수 있는 사건은 `TevioActionCard`로, 설정·이동 항목은
  `TevioListRow`로 구성합니다. 같은 내용을 요약 카드와 행동 카드에
  반복하지 않습니다.
- 화살표는 실제로 이동하거나 상세를 여는 행에만 표시합니다.
- 로딩·오류·빈 상태는 `TevioStateViews` 또는 `TevioFeedbackBanner`를 사용합니다.
- 삭제·초기화처럼 되돌리기 어려운 행동은 `TevioDialog` 또는 확인 sheet를 사용합니다.
- 반복되는 snackbar는 `TevioSnackbar`를 통해 표시합니다.

## 금지 규칙

- 화면에서 원시 색상, 임의 여백, 임의 radius를 추가하지 않습니다.
- 같은 의미의 CTA를 한 화면에 중복 배치하지 않습니다.
- 아이콘만으로 중요한 상태를 표현하지 않습니다.
- 전체 배경 애니메이션과 목적 없는 장식 모션을 사용하지 않습니다.
- 화면은 버튼, 입력, 선택, 상태, 시트, 카드 같은 사용자 상호작용을
  Tevio 컴포넌트로 사용합니다. `Scaffold`, `Navigator`, `Material` 등 플랫폼
  호스트 구현은 공통 컴포넌트 내부 또는 앱 셸에서만 직접 사용합니다.
- feature에서는 `TextButton`, `IconButton`, `TextField`, `Radio`, `Switch`,
  `SnackBar`, `PopupMenuButton`, `showModalBottomSheet`를 직접 사용하지
  않습니다. 새 사용 사례는 먼저 Tevio 공통 계약에 추가하거나, 한 화면에만
  필요한 경우 해당 feature의 화면 전용 pattern으로 구성합니다.

## 접근성

- 모든 icon-only action에는 tooltip과 Semantics label을 제공합니다.
- 상태·오류·로딩 변경은 live region semantics를 고려합니다.
- Dynamic Type에서 텍스트가 잘리지 않도록 고정 높이 텍스트 영역을 피합니다.
- 키보드와 safe area를 고려해 bottom action을 배치합니다.

## 모션

- `fast`: pressed, icon, selection feedback
- `normal`: card and status transition
- `slow`: processing and completion feedback
- `pulse`: processing indicator only

`처리 중` 상태만 작은 상태 마커를 회전시킵니다. 긴급·주의·정상 상태는
고정 표시하여 의미 없는 움직임으로 주의를 분산시키지 않습니다.

모션은 정보 변화가 있을 때만 사용하고, 사용자의 주의를 빼앗는 배경 애니메이션은 사용하지 않습니다.
