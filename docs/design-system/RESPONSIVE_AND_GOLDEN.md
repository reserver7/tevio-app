# Responsive and Golden Rules

## Responsive contract

- All interactive controls use at least `TevioDimensions.minTouchTarget` (44dp).
- Pages are built inside `SafeArea` and scroll when content exceeds the viewport.
- Text must remain readable at a 1.3 text scale on a 320dp-wide viewport.
- Bottom navigation and sheets must respect the platform safe area.
- Use `flutter test test/design_system_responsive_test.dart` for the baseline contract.

## Golden workflow

Golden images are owned by the component or feature that renders them. Keep the
viewport and text scale explicit in the test, then update only the intended
golden files with:

```sh
flutter test --update-goldens test/goldens/
```

Review golden changes as visual API changes. Do not update them as part of a
dependency upgrade without a screen-by-screen review.
