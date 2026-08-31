import 'package:flutter/material.dart';

/// Placeholder palette — the real design tokens (primary/secondary/surface/
/// text/status colors, exact hex values) come from the UI/UX screenshots,
/// which have not been provided yet. Everything below is a neutral,
/// professional stand-in so the theme/component foundation is structurally
/// complete and swappable: once screenshots land, only this file changes —
/// no widget references a color literal directly.
class AppColors {
  const AppColors._();

  static const primary = Color(0xFF1B3A5C);
  static const primaryLight = Color(0xFF2E5578);
  static const primaryDark = Color(0xFF0F2740);

  static const secondary = Color(0xFFB88A2E);

  static const background = Color(0xFFF7F8FA);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceVariant = Color(0xFFEEF1F4);

  static const textPrimary = Color(0xFF1A1D1F);
  static const textSecondary = Color(0xFF6B7280);
  static const textDisabled = Color(0xFFA1A7AE);
  static const onPrimary = Color(0xFFFFFFFF);

  static const border = Color(0xFFE1E4E8);
  static const divider = Color(0xFFE1E4E8);

  static const success = Color(0xFF1E8A5F);
  static const warning = Color(0xFFC08A1E);
  static const error = Color(0xFFC0392B);
  static const info = Color(0xFF2E6FB0);

  // Dark theme placeholders
  static const backgroundDark = Color(0xFF13161A);
  static const surfaceDark = Color(0xFF1C2025);
  static const textPrimaryDark = Color(0xFFF2F3F4);
  static const textSecondaryDark = Color(0xFF9AA1A9);
}
