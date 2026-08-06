# Design System Changelog

## 0.6.0

- Completed shared control contracts for enabled, selected, disabled, loading,
  error and progress states across search, select, check, radio, date,
  document, permission and confirmation components.
- Added clear-search callbacks, date clearing, retryable document errors and
  dismissal controls for sheets so feature screens do not reimplement them.
- Expanded the component catalog with searchable input, form selection,
  progress, skeleton and navigable-list examples.

## 0.5.0

- Expanded action, input, selection, navigation and list contracts with clear
  touch targets, semantic state and compact variants.
- Unified product and rights cards on the operational action pattern.
- Improved dark-mode input states, notification hierarchy, completion states
  and catalog interaction coverage.

## 0.4.0

- Added operational action cards, list rows and secondary text actions.
- Applied the patterns to Home, Notifications and My so navigation affordance,
  status and next actions use one interaction contract.
- Limited motion to the processing-status marker instead of decorative surfaces.

## 0.3.0

- Added date, remote-image, document, permission and confirmation adapters.
- Standardized feature sheets on `TevioSheet` and `TevioConfirmSheet`.
- Added adapter Catalog coverage, visual contracts and explicit confirmation
  behavior tests.

## 0.2.0

- Added semantic color roles and interaction dimensions.
- Added controls, feedback, overlay and product pattern components.
- Added accessibility labels and motion rules to shared interactions.
- Added dark theme foundation.

## 0.1.0

- Established Tevio colors, typography, spacing, radius and motion tokens.
- Added initial button, card, status, navigation and state components.
