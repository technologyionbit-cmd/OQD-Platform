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
}
