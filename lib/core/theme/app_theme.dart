import 'package:flutter/material.dart';

import 'package:aqd_ionbit/core/theme/app_colors.dart';
import 'package:aqd_ionbit/core/theme/app_radii.dart';
import 'package:aqd_ionbit/core/theme/app_spacing.dart';
import 'package:aqd_ionbit/core/theme/app_status_colors.dart';
import 'package:aqd_ionbit/core/theme/app_typography.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData get light {
    final colorScheme = const ColorScheme.light(
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      secondary: AppColors.secondary,
      onSecondary: AppColors.onPrimary,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      error: AppColors.error,
      onError: AppColors.onPrimary,
    );

    return _build(
      colorScheme: colorScheme,
      scaffoldBackground: AppColors.background,
      textTheme: AppTypography.textTheme(primaryColor: AppColors.textPrimary, secondaryColor: AppColors.textSecondary),
      statusColors: AppStatusColors.light,
    );
  }

  static ThemeData get dark {
    final colorScheme = const ColorScheme.dark(
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      secondary: AppColors.secondary,
      onSecondary: AppColors.textPrimary,
      surface: AppColors.surfaceDark,
      onSurface: AppColors.textPrimaryDark,
      error: AppColors.error,
      onError: AppColors.onPrimary,
    );

    return _build(
      colorScheme: colorScheme,
      scaffoldBackground: AppColors.backgroundDark,
      textTheme: AppTypography.textTheme(
        primaryColor: AppColors.textPrimaryDark,
        secondaryColor: AppColors.textSecondaryDark,
      ),
      statusColors: AppStatusColors.dark,
    );
  }

  static ThemeData _build({
    required ColorScheme colorScheme,
    required Color scaffoldBackground,
    required TextTheme textTheme,
    required AppStatusColors statusColors,
  }) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: scaffoldBackground,
      fontFamily: AppTypography.fontFamily,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: scaffoldBackground,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: textTheme.titleLarge,
      ),
      cardTheme: CardThemeData(
        color: colorScheme.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: AppRadii.mdRadius, side: BorderSide(color: AppColors.border)),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          disabledBackgroundColor: AppColors.textDisabled,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: AppRadii.mdRadius),
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          side: BorderSide(color: colorScheme.primary),
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: AppRadii.mdRadius),
          textStyle: textTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: colorScheme.primary, textStyle: textTheme.labelLarge),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
        border: OutlineInputBorder(borderRadius: AppRadii.mdRadius, borderSide: const BorderSide(color: AppColors.border)),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadii.mdRadius,
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(borderRadius: AppRadii.mdRadius, borderSide: BorderSide(color: colorScheme.primary)),
        errorBorder: OutlineInputBorder(borderRadius: AppRadii.mdRadius, borderSide: const BorderSide(color: AppColors.error)),
        labelStyle: textTheme.bodyMedium,
        hintStyle: textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
      ),
      dividerTheme: const DividerThemeData(color: AppColors.divider, thickness: 1, space: 1),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        indicatorColor: Colors.transparent,
        elevation: 0,
        height: 64,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(color: states.contains(WidgetState.selected) ? colorScheme.primary : AppColors.textSecondary),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => textTheme.labelSmall?.copyWith(
            color: states.contains(WidgetState.selected) ? colorScheme.primary : AppColors.textSecondary,
            fontWeight: states.contains(WidgetState.selected) ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: colorScheme.surface,
        indicatorColor: Colors.transparent,
        elevation: 0,
        selectedIconTheme: IconThemeData(color: colorScheme.primary),
        unselectedIconTheme: const IconThemeData(color: AppColors.textSecondary),
        selectedLabelTextStyle: textTheme.labelSmall?.copyWith(color: colorScheme.primary, fontWeight: FontWeight.w700),
        unselectedLabelTextStyle: textTheme.labelSmall?.copyWith(color: AppColors.textSecondary),
      ),
      extensions: [statusColors],
    );
  }
}
