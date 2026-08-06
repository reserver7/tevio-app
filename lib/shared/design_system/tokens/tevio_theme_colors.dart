import 'package:flutter/material.dart';

import 'tevio_colors.dart';

/// Resolves semantic UI colors from the active app theme.
/// Brand and status colors remain stable; surfaces and text adapt to light/dark.
abstract final class TevioThemeColors {
  static Color surface(BuildContext context) =>
      Theme.of(context).colorScheme.surface;

  static Color background(BuildContext context) =>
      Theme.of(context).scaffoldBackgroundColor;

  static Color primaryText(BuildContext context) =>
      Theme.of(context).colorScheme.onSurface;

  static Color secondaryText(BuildContext context) =>
      Theme.of(context).colorScheme.onSurfaceVariant;

  static Color border(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? TevioColors.darkBorder
      : TevioColors.border;

  static Color divider(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? TevioColors.darkBorder
      : TevioColors.divider;

  static Color selectedSurface(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? TevioColors.darkSurface
      : TevioColors.primaryBackground;
}
