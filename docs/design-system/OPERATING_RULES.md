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
