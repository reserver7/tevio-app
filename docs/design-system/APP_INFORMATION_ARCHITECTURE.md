# Tevio App Information Architecture

## Product promise

Tevio turns post-purchase product rights into the next action a customer can
understand and complete.

## Primary navigation

The app uses three primary destinations:

| Destination | Responsibility | Must not contain |
| --- | --- | --- |
| Home | The most important decision or action now, plus minimal aggregate status | Product browsing, notification history |
| Products | Search, filter, register, and manage owned products | Duplicated home alerts |
| My | Notification policy, appearance, public tools, and account state | Non-functional placeholder menus |

Registration is a task launched from Rights or Products, not a permanent tab.
Activity is a secondary event ledger opened from the Home notification action.
Public recall lookup is an independent utility opened from My.

## Screen contracts

- Home is a decision queue. It contains one highest-priority decision, minimal
  management counts, and active processing. It does not render product tools,
  a product inventory, or a chronological activity feed.
- Products is the product library. Its first job is finding and managing a
  product through search, status filters, and sorting. Product rights are
  summarized only enough to choose a product, then handled in detail.
- Product detail is the rights workspace for one product. It owns the current
  decision, evidence, rights periods, and completion actions.
- Activity is the event ledger. It owns when an external change or processing
  result happened, whether it has been read, and where it leads.
- My owns account and policy settings. It does not repeat product status or
  current actions from Rights.

The home and product library intentionally use different visual grammars:
home uses a compact status summary, one priority surface, and a processing
list, while Products uses an inventory header, search, view controls, and
scan-friendly rows. Detailed product state belongs to Products and detailed
events belong to Activity.

## Page frame contract

Feature pages use `TevioPageScrollView` for the standard safe area, scroll
storage key, and page insets. A page must not add a second page-level
`SafeArea` or another outer horizontal padding layer. A screen may override the
inset only when its workflow needs a full-bleed surface or a keyboard-aware
form, and that exception belongs to the screen pattern rather than the shared
component.

Rows use a fixed four-slot geometry: 32dp leading icon, flexible content, a
112dp value slot when a value exists, and a 44dp trailing slot for interactive
navigation. Static rows release the trailing slot so values align with the page
edge. Only interactive rows render the chevron inside that slot.

## Presentation ownership

- Shared design-system components own visual and interaction contracts.
- Feature patterns own business prioritization and user-flow decisions.
- Repositories own mock data and remain replaceable by remote implementations.
- Screens do not present mock implementation details to customers.

## State language

- `urgent`: stop and verify before continued use.
- `actionRequired`: a customer decision is due soon.
- `processing`: Tevio or the customer has started a process.
- `safe`: no action is currently required.
- `completed`: a process has a recorded outcome.
- `unknown`: more product information or a retry is required.

Color supports these states but never replaces the state label, explanation,
and next action.

## Interaction rules

- One primary action per screen or task step.
- Product lists and activity feeds use flat, scan-friendly rows.
- Cards are reserved for a focused decision, completion, or feedback state.
- iOS back swipe and Android system back follow the route stack.
- Search remains editable when results are empty.
- Failure feedback appears in the task context when the customer must act.
## Tevio domain patterns

Tevio 심벌에서 가져온 세로 흐름과 민트 완료점을 장식이 아닌 상태 전달에만 사용한다.

- `TevioProductIdentity`: 제품명, 제조사, 모델번호와 전체 상태를 식별한다.
- `TevioDecisionPanel`: 판단 근거, 기한, 대표 행동이 모두 있을 때만 사용한다.
- `TevioRightsRail`: 리콜, 보증, 반품·교환, A/S를 하나의 권리 흐름으로 보여준다.
- `TevioProcessTracker`: 접수부터 완료까지 진행 중인 처리에만 사용한다.
- `TevioEvidenceVault`: 구매 정보와 증빙의 준비 여부를 한곳에서 관리한다.
- `TevioTimeline`: 활동과 처리 이력을 시간순 사건으로 보여준다.

위 컴포넌트는 표현과 인터랙션만 소유한다. 우선순위, 상태 판단, 문구, 완료 처리와 같은 업무 규칙은 각 feature가 결정한다.

## Surface 선택

- 결정과 대표 행동이 함께 있을 때만 큰 강조 surface를 사용한다.
- 짧은 정보는 평면 섹션이나 목록 행으로 표시한다.
- 설정과 이동은 `TevioListRow`의 고정 leading/content/value/trailing 슬롯을 사용한다.
- interactive row에만 chevron을 표시한다.
- 오른쪽 빈 공간을 아이콘이나 일러스트로 채우지 않는다.
- 한 화면에서 강조 버튼은 하나만 사용한다.

mock repository는 위 상태를 재현하지만 실제 공식 리콜 데이터, 인증, 서버 저장, 푸시 전달이 연결된 것으로 표현하지 않는다.
