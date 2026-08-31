import 'package:flutter/material.dart';

enum AppButtonVariant { primary, outlined, text }

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
            children: [
              if (icon != null) ...[Icon(icon, size: 18), const SizedBox(width: 8)],
              Text(label),
            ],
          );

    return switch (variant) {
      AppButtonVariant.primary => ElevatedButton(onPressed: isDisabled ? null : onPressed, child: child),
      AppButtonVariant.outlined => OutlinedButton(onPressed: isDisabled ? null : onPressed, child: child),
      AppButtonVariant.text => TextButton(onPressed: isDisabled ? null : onPressed, child: child),
    };
  }

  Color _spinnerColor(BuildContext context) {
    return switch (variant) {
      AppButtonVariant.primary => Theme.of(context).colorScheme.onPrimary,
      AppButtonVariant.outlined || AppButtonVariant.text => Theme.of(context).colorScheme.primary,
    };
  }
}
