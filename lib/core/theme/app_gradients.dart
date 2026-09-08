import 'package:flutter/material.dart';

import 'package:aqd_ionbit/core/theme/app_colors.dart';

/// The dark navy gradient behind splash/onboarding/auth headers and the
/// lawyer-dashboard header — sampled from the reference screenshots
/// (top-left darkest, bottom-right lighter), not an arbitrary flat fill.
class AppGradients {
  const AppGradients._();

  static const navyHeader = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.navyDarkest, AppColors.navyLight],
  );

  // Client-home "your legal services" tile gradients — one per service,
  // sampled from the reference screenshots.
  static const serviceTileAnalyze = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.navy, AppColors.steelBlue],
  );

  static const serviceTileContracts = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.primary, AppColors.cyanAccent],
  );

  static const serviceTileLawyer = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.violet, AppColors.violetLight],
  );

  static const serviceTileGovDocuments = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.secondary, AppColors.amberLight],
  );
}
