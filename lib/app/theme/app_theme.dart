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
        surfaceTintColor: TevioColors.transparent,
        elevation: 0,
        titleTextStyle: TevioTypography.titleMedium,
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
        constraints: const BoxConstraints(
          minHeight: TevioDimensions.inputHeight,
        ),
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
        errorBorder: OutlineInputBorder(
          borderRadius: TevioRadius.mediumBorder,
          borderSide: const BorderSide(color: TevioColors.danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: TevioRadius.mediumBorder,
          borderSide: const BorderSide(color: TevioColors.danger, width: 1.4),
        ),
        helperStyle: TevioTypography.label.copyWith(
          color: TevioColors.textSecondary,
        ),
        errorStyle: TevioTypography.label.copyWith(color: TevioColors.danger),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(TevioDimensions.buttonHeight),
          backgroundColor: TevioColors.primary,
          foregroundColor: TevioColors.white,
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
          minimumSize: const Size.fromHeight(TevioDimensions.buttonHeight),
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
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TevioColors.white;
          }
          return TevioColors.textTertiary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TevioColors.primary;
          }
          return TevioColors.divider;
        }),
      ),
    );
  }

  static ThemeData dark() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: TevioColors.primary,
      brightness: Brightness.dark,
      primary: TevioColors.primary,
      secondary: TevioColors.mint,
      error: TevioColors.danger,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: TevioColors.darkBackground,
      textTheme: TevioTypography.textTheme().apply(
        bodyColor: TevioColors.white,
        displayColor: TevioColors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: TevioColors.darkBackground,
        foregroundColor: TevioColors.white,
        surfaceTintColor: TevioColors.transparent,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: TevioColors.darkSurface,
        constraints: const BoxConstraints(
          minHeight: TevioDimensions.inputHeight,
        ),
        border: OutlineInputBorder(
          borderRadius: TevioRadius.mediumBorder,
          borderSide: BorderSide(color: TevioColors.darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: TevioRadius.mediumBorder,
          borderSide: BorderSide(color: TevioColors.darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: TevioRadius.mediumBorder,
          borderSide: const BorderSide(color: TevioColors.primary, width: 1.4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: TevioRadius.mediumBorder,
          borderSide: const BorderSide(color: TevioColors.danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: TevioRadius.mediumBorder,
          borderSide: const BorderSide(color: TevioColors.danger, width: 1.4),
        ),
        helperStyle: TevioTypography.label.copyWith(
          color: TevioColors.textTertiary,
        ),
        errorStyle: TevioTypography.label.copyWith(color: TevioColors.danger),
      ),
    );
  }
}
