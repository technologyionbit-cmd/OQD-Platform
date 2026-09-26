import 'package:flutter/material.dart';

/// Type scale structure — sizes/weights follow Material 3 conventions as a
/// sane default. `fontFamily` is intentionally left null (platform default,
/// which already covers Arabic via system fallback fonts) until the brand
/// typeface is known from the screenshots/brand guide and bundled as an
/// asset; swapping it in later only touches this file.
class AppTypography {
  const AppTypography._();

  static const String? fontFamily = null;

  static TextTheme textTheme({required Color primaryColor, required Color secondaryColor}) {
    return TextTheme(
      displayLarge: _style(36, FontWeight.w700, primaryColor),
      displayMedium: _style(32, FontWeight.w700, primaryColor),
      displaySmall: _style(28, FontWeight.w700, primaryColor),
      headlineLarge: _style(26, FontWeight.w700, primaryColor),
      headlineMedium: _style(22, FontWeight.w600, primaryColor),
      headlineSmall: _style(20, FontWeight.w600, primaryColor),
      titleLarge: _style(18, FontWeight.w600, primaryColor),
      titleMedium: _style(16, FontWeight.w600, primaryColor),
      titleSmall: _style(14, FontWeight.w600, primaryColor),
      bodyLarge: _style(16, FontWeight.w400, primaryColor),
      bodyMedium: _style(14, FontWeight.w400, primaryColor),
      bodySmall: _style(12, FontWeight.w400, secondaryColor),
      labelLarge: _style(14, FontWeight.w600, primaryColor),
      labelMedium: _style(12, FontWeight.w600, secondaryColor),
      labelSmall: _style(11, FontWeight.w500, secondaryColor),
    );
  }

  static TextStyle _style(double size, FontWeight weight, Color color) {
    return TextStyle(fontSize: size, fontWeight: weight, color: color, height: 1.4);
  }
}
