import 'package:flutter/material.dart';

import 'package:aqd_ionbit/core/theme/app_colors.dart';

/// Semantic status colors (success/warning/info) that don't have a slot in
/// Flutter's [ColorScheme]. Access via `Theme.of(context).extension<AppStatusColors>()`
/// rather than importing [AppColors] directly from feature widgets — this
/// is what makes light/dark and future re-theming a one-file change.
@immutable
class AppStatusColors extends ThemeExtension<AppStatusColors> {
  const AppStatusColors({required this.success, required this.warning, required this.error, required this.info});

  final Color success;
  final Color warning;
  final Color error;
  final Color info;

  static const light = AppStatusColors(
    success: AppColors.success,
    warning: AppColors.warning,
    error: AppColors.error,
    info: AppColors.info,
  );

  static const dark = AppStatusColors(
    success: AppColors.success,
    warning: AppColors.warning,
    error: AppColors.error,
    info: AppColors.info,
  );

  @override
  AppStatusColors copyWith({Color? success, Color? warning, Color? error, Color? info}) {
    return AppStatusColors(
      success: success ?? this.success,
      warning: warning ?? this.warning,
      error: error ?? this.error,
      info: info ?? this.info,
    );
  }

  @override
  AppStatusColors lerp(ThemeExtension<AppStatusColors>? other, double t) {
    if (other is! AppStatusColors) return this;
    return AppStatusColors(
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      error: Color.lerp(error, other.error, t)!,
      info: Color.lerp(info, other.info, t)!,
    );
  }
}

extension AppStatusColorsX on BuildContext {
  AppStatusColors get statusColors => Theme.of(this).extension<AppStatusColors>()!;
}
