# Ownership Boundaries

`lib/shared/design_system` owns only reusable presentation foundations:

- tokens, themes, motion, typography and accessibility contracts;
- generic controls such as buttons, fields, sheets, cards and navigation;
- generic layout patterns that have no product, recall, notification or account
  vocabulary.

Each feature owns its domain composition in
`lib/features/<feature>/presentation/widgets` or `pages`:

- product-rights summaries, recall actions and registration steps;
- notification grouping and swipe actions;
- account, permission and settings flows.

Promote a feature widget only after it is used by at least two independent
features without domain-specific props. This keeps the design system stable,
prevents premature abstraction, and avoids duplicate look-and-feel code.
