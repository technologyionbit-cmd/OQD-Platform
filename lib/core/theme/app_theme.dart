import 'package:flutter/material.dart';

import 'package:aqd_ionbit/core/theme/app_colors.dart';
import 'package:aqd_ionbit/core/theme/app_radii.dart';
import 'package:aqd_ionbit/core/theme/app_spacing.dart';
import 'package:aqd_ionbit/core/theme/app_status_colors.dart';
import 'package:aqd_ionbit/core/theme/app_typography.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData get light {
    const colorScheme = ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      onSecondary: AppColors.onPrimary,
      onSurface: AppColors.textPrimary,
      onSurfaceVariant: AppColors.textSecondary,
      surfaceContainerHighest: AppColors.surfaceVariant,
      outlineVariant: AppColors.border,
      error: AppColors.error,
    );

    return _build(
      colorScheme: colorScheme,
      scaffoldBackground: AppColors.background,
      textTheme: AppTypography.textTheme(primaryColor: AppColors.textPrimary, secondaryColor: AppColors.textSecondary),
      statusColors: AppStatusColors.light,
    );
  }

  static ThemeData get dark {
    const colorScheme = ColorScheme.dark(
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      secondary: AppColors.secondary,
      onSecondary: AppColors.textPrimary,
      surface: AppColors.surfaceDark,
      onSurface: AppColors.textPrimaryDark,
      onSurfaceVariant: AppColors.textSecondaryDark,
      surfaceContainerHighest: AppColors.surfaceVariantDark,
      outlineVariant: AppColors.borderDark,
      error: AppColors.error,
      onError: AppColors.onPrimary,
    );

    return _build(
      colorScheme: colorScheme,
      scaffoldBackground: AppColors.backgroundDark,
      textTheme: AppTypography.textTheme(primaryColor: AppColors.textPrimaryDark, secondaryColor: AppColors.textSecondaryDark),
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
      fontFamily: AppTypography.fontFamily,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: scaffoldBackground,
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
        shape: RoundedRectangleBorder(borderRadius: AppRadii.mdRadius, side: BorderSide(color: colorScheme.outlineVariant)),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          shadowColor: Colors.transparent,
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          disabledBackgroundColor: colorScheme.surfaceContainerHighest,
          disabledForegroundColor: AppColors.textDisabled,
          minimumSize: const Size.fromHeight(48),
          shape: const RoundedRectangleBorder(borderRadius: AppRadii.mdRadius),
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          side: BorderSide(color: colorScheme.primary),
          minimumSize: const Size.fromHeight(48),
          shape: const RoundedRectangleBorder(borderRadius: AppRadii.mdRadius),
          textStyle: textTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: colorScheme.primary, textStyle: textTheme.labelLarge)),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
        border: OutlineInputBorder(borderRadius: AppRadii.mdRadius, borderSide: BorderSide(color: colorScheme.outlineVariant)),
        enabledBorder: OutlineInputBorder(borderRadius: AppRadii.mdRadius, borderSide: BorderSide(color: colorScheme.outlineVariant)),
        focusedBorder: OutlineInputBorder(borderRadius: AppRadii.mdRadius, borderSide: BorderSide(color: colorScheme.primary)),
        errorBorder: const OutlineInputBorder(borderRadius: AppRadii.mdRadius, borderSide: BorderSide(color: AppColors.error)),
        labelStyle: textTheme.bodyMedium,
        hintStyle: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
      ),
      dividerTheme: DividerThemeData(color: colorScheme.outlineVariant, thickness: 1, space: 1),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        indicatorColor: Colors.transparent,
        elevation: 0,
        height: 64,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(color: states.contains(WidgetState.selected) ? colorScheme.primary : colorScheme.onSurfaceVariant),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => textTheme.labelSmall?.copyWith(
            color: states.contains(WidgetState.selected) ? colorScheme.primary : colorScheme.onSurfaceVariant,
            fontWeight: states.contains(WidgetState.selected) ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: colorScheme.surface,
        indicatorColor: Colors.transparent,
        elevation: 0,
        selectedIconTheme: IconThemeData(color: colorScheme.primary),
        unselectedIconTheme: IconThemeData(color: colorScheme.onSurfaceVariant),
        selectedLabelTextStyle: textTheme.labelSmall?.copyWith(color: colorScheme.primary, fontWeight: FontWeight.w700),
        unselectedLabelTextStyle: textTheme.labelSmall?.copyWith(color: colorScheme.onSurfaceVariant),
      ),
      extensions: [statusColors],
    );
  }
}
