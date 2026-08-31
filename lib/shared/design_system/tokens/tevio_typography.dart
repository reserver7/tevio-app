import 'package:flutter/material.dart';

import 'tevio_colors.dart';

abstract final class TevioTypography {
  static const fontFamily = null;

  static const display = TextStyle(
    fontSize: 28,
    height: 1.3,
    fontWeight: FontWeight.w700,
    color: TevioColors.textPrimary,
  );

  static const titleLarge = TextStyle(
    fontSize: 22,
    height: 1.35,
    fontWeight: FontWeight.w700,
    color: TevioColors.textPrimary,
  );

  static const titleMedium = TextStyle(
    fontSize: 18,
    height: 1.4,
    fontWeight: FontWeight.w700,
    color: TevioColors.textPrimary,
  );

  static const titleSmall = TextStyle(
    fontSize: 16,
    height: 1.45,
    fontWeight: FontWeight.w700,
    color: TevioColors.textPrimary,
  );

  static const bodyLarge = TextStyle(
    fontSize: 16,
    height: 1.5,
    fontWeight: FontWeight.w500,
    color: TevioColors.textPrimary,
  );

  static const bodyMedium = TextStyle(
    fontSize: 14,
    height: 1.5,
    fontWeight: FontWeight.w400,
    color: TevioColors.textSecondary,
  );

  static const bodySmall = TextStyle(
    fontSize: 12,
    height: 1.5,
    fontWeight: FontWeight.w400,
    color: TevioColors.textSecondary,
  );

  static const label = TextStyle(
    fontSize: 12,
    height: 1.4,
    fontWeight: FontWeight.w600,
    color: TevioColors.textSecondary,
  );

  static TextTheme textTheme() {
    return const TextTheme(
      displaySmall: display,
      headlineSmall: titleLarge,
      titleLarge: titleLarge,
      titleMedium: titleMedium,
      titleSmall: titleSmall,
      bodyLarge: bodyLarge,
      bodyMedium: bodyMedium,
      bodySmall: bodySmall,
      labelLarge: label,
      labelMedium: label,
      labelSmall: label,
    );
  }
}
