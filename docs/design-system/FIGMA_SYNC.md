# Figma Sync Contract

Figma variables are the design source of truth. Code tokens mirror them by
name, type, and semantic meaning.

- Figma collection: `Tevio / Foundations`
- Code location: `lib/shared/design_system/tokens/`
- Names use `color.*`, `space.*`, `type.*`, `radius.*`, `motion.*`.
- A token rename is a breaking design-system change and must include a
  changelog entry and updated Golden files.
- New component variants require a Catalog example and a widget test.
- Token exports are checked in CI with `dart run tool/check_design_system.dart`.

The repository intentionally does not overwrite Figma automatically. A design
review owns semantic changes; CI verifies that the code contract remains
complete after the approved sync.
