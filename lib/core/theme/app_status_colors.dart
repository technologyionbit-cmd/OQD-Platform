import 'package:flutter/material.dart';

import 'package:aqd_ionbit/core/theme/app_colors.dart';

/// A foreground/background pair for one semantic tone (e.g. the green text
/// on pale-green background used for a "completed" badge).
@immutable
class StatusTone {
  const StatusTone({required this.foreground, required this.background});

  final Color foreground;
  final Color background;

  static StatusTone lerp(StatusTone a, StatusTone b, double t) {
    return StatusTone(
      foreground: Color.lerp(a.foreground, b.foreground, t)!,
      background: Color.lerp(a.background, b.background, t)!,
    );
  }
}

/// Semantic status colors that don't have a slot in Flutter's [ColorScheme]
/// — the five tones observed across status badges (completed/pending/draft),
/// analysis-risk alerts, and callout banners. Access via
/// `Theme.of(context).extension<AppStatusColors>()` (or the `context.statusColors`
/// shortcut below) rather than importing [AppColors] directly from feature
/// widgets — this is what makes re-theming a one-file change.
@immutable
class AppStatusColors extends ThemeExtension<AppStatusColors> {
  const AppStatusColors({
    required this.success,
    required this.warning,
    required this.error,
    required this.info,
    required this.neutral,
  });

  final StatusTone success;
  final StatusTone warning;
  final StatusTone error;
  final StatusTone info;
  final StatusTone neutral;

  static const light = AppStatusColors(
    success: StatusTone(foreground: AppColors.success, background: AppColors.successBackground),
    warning: StatusTone(foreground: AppColors.warning, background: AppColors.warningBackground),
    error: StatusTone(foreground: AppColors.error, background: AppColors.errorBackground),
    info: StatusTone(foreground: AppColors.info, background: AppColors.infoBackground),
    neutral: StatusTone(foreground: AppColors.neutral, background: AppColors.neutralBackground),
  );

  static const dark = light;

  @override
  AppStatusColors copyWith({StatusTone? success, StatusTone? warning, StatusTone? error, StatusTone? info, StatusTone? neutral}) {
    return AppStatusColors(
      success: success ?? this.success,
      warning: warning ?? this.warning,
      error: error ?? this.error,
      info: info ?? this.info,
      neutral: neutral ?? this.neutral,
    );
  }

  @override
  AppStatusColors lerp(ThemeExtension<AppStatusColors>? other, double t) {
    if (other is! AppStatusColors) return this;
    return AppStatusColors(
      success: StatusTone.lerp(success, other.success, t),
      warning: StatusTone.lerp(warning, other.warning, t),
      error: StatusTone.lerp(error, other.error, t),
      info: StatusTone.lerp(info, other.info, t),
      neutral: StatusTone.lerp(neutral, other.neutral, t),
    );
  }
}

extension AppStatusColorsX on BuildContext {
  AppStatusColors get statusColors => Theme.of(this).extension<AppStatusColors>()!;
}
