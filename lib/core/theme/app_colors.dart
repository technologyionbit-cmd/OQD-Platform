import 'package:flutter/material.dart';

/// Design tokens sampled from the Aqd UI/UX reference screenshots (pixel
/// color extraction, not eyeballed) — this is the real palette, not a
/// placeholder. If a new screenshot batch implies a different value, update
/// it here only; no widget or screen should ever reference a color literal
/// directly.
class AppColors {
  const AppColors._();

  // Navy — splash/auth headers, icon badges, lawyer-dashboard header. This
  // is a surface color, not the interactive "primary" — see [primary] below.
  static const navyDarkest = Color(0xFF0C1830);
  static const navy = Color(0xFF12294F);
  static const navyLight = Color(0xFF1B3A63);

  // Primary/action blue — every button, link, and active/selected state.
  // This is what ColorScheme.primary maps to, not the navy above.
  static const primary = Color(0xFF0078C0);
  static const primaryDark = Color(0xFF005E96);

  // Gold/amber — ratings, "Pro"/"most popular" badges, demo-data callouts.
  static const secondary = Color(0xFFC98A0E);
  static const secondaryBackground = Color(0xFFFCF0C0);

  // NDA/lock and similar category-icon accent seen in the template gallery.
  static const purpleAccent = Color(0xFF7C4DFF);

  static const background = Color(0xFFF7F8FA);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceVariant = Color(0xFFEEF1F4);

  static const textPrimary = Color(0xFF0F1B2B);
  static const textSecondary = Color(0xFF6B7280);
  static const textDisabled = Color(0xFFA1A7AE);
  static const onPrimary = Color(0xFFFFFFFF);

  static const border = Color(0xFFE1E4E8);
  static const divider = Color(0xFFE1E4E8);

  // Status — matches the badge colors used for contract/document/booking
  // states (completed/pending-signature/draft) and analysis-risk alerts.
  static const success = Color(0xFF188C4E);
  static const successBackground = Color(0xFFC8F0D4);
  static const warning = secondary;
  static const warningBackground = secondaryBackground;
  static const error = Color(0xFFD64545);
  static const errorBackground = Color(0xFFFCD8D8);
  static const info = primary;
  static const infoBackground = Color(0xFFE1F0FB);
  static const neutral = Color(0xFF6B7280);
  static const neutralBackground = Color(0xFFEEF1F4);

  // Dark theme — derived from the same navy family for consistency.
  static const backgroundDark = Color(0xFF0C1420);
  static const surfaceDark = Color(0xFF152238);
  static const textPrimaryDark = Color(0xFFF2F3F4);
  static const textSecondaryDark = Color(0xFF9AA1A9);
}
