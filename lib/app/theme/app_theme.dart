import 'package:flutter/material.dart';

import '../../shared/design_system/tevio_design_system.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: TevioColors.primary,
      brightness: Brightness.light,
      primary: TevioColors.primary,
      secondary: TevioColors.mint,
      error: TevioColors.danger,
      surface: TevioColors.surface,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: TevioColors.background,
      textTheme: TevioTypography.textTheme(),
      dividerTheme: const DividerThemeData(
        color: TevioColors.divider,
        thickness: 1,
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        backgroundColor: TevioColors.background,
        foregroundColor: TevioColors.textPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: TevioColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: TevioRadius.largeBorder,
          side: const BorderSide(color: TevioColors.border),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: TevioColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: TevioSpacing.md,
          vertical: TevioSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: TevioRadius.mediumBorder,
          borderSide: const BorderSide(color: TevioColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: TevioRadius.mediumBorder,
          borderSide: const BorderSide(color: TevioColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: TevioRadius.mediumBorder,
          borderSide: const BorderSide(color: TevioColors.primary, width: 1.4),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
          backgroundColor: TevioColors.primary,
          foregroundColor: Colors.white,
          shape: const RoundedRectangleBorder(
            borderRadius: TevioRadius.mediumBorder,
          ),
          textStyle: TevioTypography.bodyLarge.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
          foregroundColor: TevioColors.primary,
          side: const BorderSide(color: TevioColors.border),
          shape: const RoundedRectangleBorder(
            borderRadius: TevioRadius.mediumBorder,
          ),
          textStyle: TevioTypography.bodyLarge.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
