import 'package:flutter/material.dart';

import 'package:aqd_ionbit/core/theme/app_colors.dart';
import 'package:aqd_ionbit/core/theme/app_radii.dart';

enum AppButtonVariant {
  primary,
  outlined,
  text,

  /// The green CTA reserved for e-signature confirm/sign actions — a
  /// deliberate, recurring color distinct from the primary action blue in
  /// the reference screenshots, not a one-off override.
  success,

  /// Outlined-but-red treatment for a destructive action's trigger button
  /// (e.g. "Delete") — kept visually distinct from [outlined]'s primary-blue
  /// so a destructive action never looks identical to a neutral one, even
  /// before the confirmation dialog appears.
  destructive,
}

/// Wraps Elevated/Outlined/Text button with a built-in loading state so no
/// screen hand-rolls "disable + spinner while submitting" itself.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool isLoading;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final isDisabled = isLoading || onPressed == null;
    final child = isLoading
        ? SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(strokeWidth: 2.5, color: _spinnerColor(context)),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[Icon(icon, size: 18), const SizedBox(width: 8)],
              // Flexible + ellipsis so a longer label truncates instead of
              // overflowing if this button ever ends up in a narrower
              // context than the full-width usage it has today.
              Flexible(child: Text(label, overflow: TextOverflow.ellipsis, maxLines: 1)),
            ],
          );

    return switch (variant) {
      AppButtonVariant.primary => ElevatedButton(onPressed: isDisabled ? null : onPressed, child: child),
      AppButtonVariant.outlined => OutlinedButton(onPressed: isDisabled ? null : onPressed, child: child),
      AppButtonVariant.text => TextButton(onPressed: isDisabled ? null : onPressed, child: child),
      AppButtonVariant.destructive => OutlinedButton(
        onPressed: isDisabled ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.error,
          side: const BorderSide(color: AppColors.error),
          minimumSize: const Size.fromHeight(52),
          shape: const RoundedRectangleBorder(borderRadius: AppRadii.mdRadius),
        ),
        child: child,
      ),
      AppButtonVariant.success => ElevatedButton(
        onPressed: isDisabled ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.success,
          foregroundColor: AppColors.onPrimary,
          disabledBackgroundColor: AppColors.textDisabled,
          minimumSize: const Size.fromHeight(52),
          shape: const RoundedRectangleBorder(borderRadius: AppRadii.mdRadius),
        ),
        child: child,
      ),
    };
  }

  Color _spinnerColor(BuildContext context) {
    return switch (variant) {
      AppButtonVariant.primary || AppButtonVariant.success => Theme.of(context).colorScheme.onPrimary,
      AppButtonVariant.outlined || AppButtonVariant.text => Theme.of(context).colorScheme.primary,
      AppButtonVariant.destructive => AppColors.error,
    };
  }
}
