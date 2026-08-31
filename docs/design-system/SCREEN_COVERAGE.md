# Screen Coverage

The design system is the only presentation dependency for feature screens.
Each screen must cover the following states before release:

| Screen | Loading | Empty | Error/retry | Normal | Important state | Golden |
| --- | --- | --- | --- | --- | --- | --- |
| Home | yes | yes | yes | yes | urgent/processing | yes |
| Products | yes | yes | yes | yes | search/filter/sort | yes |
| Product detail | yes | missing product | yes | yes | urgent/action required | pending |
| Activity | yes | yes | yes | yes | unread/read/swipe/restore | pending |
| Registration | yes | validation | submit failure | success | processing | pending |
| Settings | no | no | no | yes | theme/notification controls | pending |
| Public recall lookup | searching | initial/query empty | error/retry | result | official notice confirmation | pending |

Golden files are added only after the corresponding state is deterministic and
does not depend on device storage, network, or clock time. Use provider
overrides in tests instead of bypassing the production UI.

## Interaction Rules

- Search surfaces keep the input visible when there are no results so the user
  can correct the query without reopening a screen.
- A lookup must expose a distinct idle, loading, result, empty, and retryable
  error state. Mock lookup behavior uses `오류` for the error path and sample
  terms such as `무선청소기`, `XYZ`, or `VC-2401` for a matching result.
- Product search is combined with the existing status filter and sort order;
  clearing the query changes only the search state and does not reset the
  selected view options.

## Domain Pattern Coverage

| Pattern | Production owner | Used on |
| --- | --- | --- |
| `TevioDecisionPanel` | Current decision, reason, deadline, primary action | Home, product detail, public recall result |
| `TevioProductIdentity` | Product identity and aggregate status | Product detail |
| `TevioRightsRail` | Recall, warranty, return/exchange, service rights | Product detail |
| `TevioProcessTracker` | Active processing stage and latest update | Home, processing product detail |
| `TevioEvidenceVault` | Receipt and purchase evidence readiness | Product detail |
| `TevioTimeline` | Chronological event history | Product detail and activity patterns |

Feature code owns the domain mapping into these patterns. Shared components do
not decide urgency, deadlines, completion, or route destinations.

## Visual differentiation coverage

| Screen | Primary visual grammar |
| --- | --- |
| Home | Decision surface, minimal metrics, processing progress |
| Products | Product monogram, compact identity, one-line status signal |
| Product detail | Identity, decision, rights rail, evidence, history |
| Registration | Method rows, scan frame, form, candidate review, progress |
| Activity | Event dot and vertical timeline rail |
| My | Fixed-slot policy and setting rows |
| Public lookup | Search-first tool with contextual state result |
