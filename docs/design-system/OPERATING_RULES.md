# Tevio Design System Operating Rules

## Ownership

Design tokens and shared components are owned by the app foundation layer. Feature teams compose them into patterns but do not fork visual primitives.

## Change Process

1. Add or change a token first.
2. Update the component contract and preview.
3. Add widget coverage for default, selected, disabled, loading and error states.
4. Add a golden image for layout-sensitive changes.
5. Apply the component to feature screens.
6. Record the change in `docs/design-system/CHANGELOG.md`.

## Figma Sync

Figma variables use the same semantic names as `TevioSemanticColors`, `TevioDimensions`, `TevioSpacing`, `TevioRadius` and `TevioMotion`. Raw hex values are allowed only in the foundation token source. Component variants must use semantic variables rather than raw colors.

## Release Rules

- Breaking component API changes require a version increment and migration note.
- Visual changes that affect more than one feature require a catalog update.
- A feature may not introduce a duplicate button, card, status badge or input primitive.
- Platform-specific behavior belongs inside the shared component, not in page code.
# Tevio visual grammar

## Product character

Tevio 화면은 일반적인 흰색 카드 모음이 아니라 사용자가 현재 권리를 판단하고 행동하는 운영 화면으로 구성한다.

- 파랑 세로 레일은 현재 판단과 진행 흐름에만 사용한다.
- 민트 점은 확인됨, 읽지 않음, 완료처럼 작은 상태 신호에 사용한다.
- 빨강은 실제 안전 문제와 중단이 필요한 상태에만 사용한다.
- 평면 목록은 탐색과 설정, 강조 surface는 한 가지 결정, 타임라인은 사건 기록에 사용한다.
- 화면 오른쪽의 빈 공간을 장식 아이콘이나 일러스트로 채우지 않는다.

## Screen differentiation

- 홈은 결정 패널과 처리 트래커를 사용하며 제품 목록을 반복하지 않는다.
- 제품은 모노그램, 식별 정보, 한 줄 상태 신호로 빠르게 비교한다.
- 제품 상세는 제품 아이덴티티, 권리 레일, 증빙 보관함 순서로 읽힌다.
- 등록은 선택 행, 스캔 프레임, 입력, 후보 판단, 처리 트래커로 이어지는 집중 작업이다.
- 활동은 카드가 아닌 사건 점과 세로 연결선을 사용하는 기록이다.
- 마이는 고정 슬롯 목록을 사용하며 업무 상태를 노출하지 않는다.

## Interaction states

- pressed 상태는 짧은 scale 또는 surface 변화 중 하나만 사용한다.
- selected 상태는 파랑 surface와 민트 완료 신호를 함께 사용할 수 있다.
- disabled 상태는 색상뿐 아니라 semantics의 enabled 상태를 함께 전달한다.
- loading은 작업 위치에서 표시하고 화면 전체를 불필요하게 차단하지 않는다.
- error는 원인과 다음 행동을 같은 영역에서 제공한다.
- completed는 지속 애니메이션 없이 결과와 다음 이동을 보여준다.

## Forms, keyboard, and sheets

- 페이지 폼은 `TevioPageScrollView`, 작업 하단 버튼은 `TevioTaskActionBar`가 소유한다.
- `TevioTaskActionBar`는 작은 화면이나 큰 글자에서 보조·대표 행동을 세로로 전환한다.
- 키보드가 열리면 단계 이동 전에 focus를 해제하고 페이지 스크롤은 drag로 키보드를 닫을 수 있어야 한다.
- `TevioSheet`는 keyboard inset, safe area, 본문 스크롤과 고정 footer를 단독으로 소유한다.
- 시트 feature는 내부에 `SingleChildScrollView`, 중복 keyboard padding 또는 중복 `SafeArea`를 추가하지 않는다.
- 구매일은 등록과 수정 모두 `TevioDateField`를 사용하며 iOS와 Android의 플랫폼 날짜 선택기를 유지한다.
