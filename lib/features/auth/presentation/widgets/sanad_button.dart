import 'package:flutter/material.dart';

import 'package:aqd_ionbit/core/theme/app_colors.dart';

enum SanadButtonStyle { filled, outlined, dark }

/// Full-width 56px button with the tight 8px corners used on the auth screens.
class SanadButton extends StatelessWidget {
  const SanadButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.style = SanadButtonStyle.filled,
    this.icon,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final SanadButtonStyle style;
  final IconData? icon;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    const shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(8)),
    );
    const size = Size.fromHeight(56);
    final text = Text(
      label,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    );
    final child =
        isLoading
            ? const SizedBox(
              height: 22,
              width: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: AppColors.onPrimary,
              ),
            )
            : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 22),
                  const SizedBox(width: 10),
                ],
                Flexible(child: text),
              ],
            );
    final enabled = isLoading ? null : onPressed;

    if (style == SanadButtonStyle.outlined) {
      return OutlinedButton(
        onPressed: enabled,
        style: OutlinedButton.styleFrom(
          minimumSize: size,
          shape: shape,
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 1.2),
        ),
        child: child,
      );
    }
    return ElevatedButton(
      onPressed: enabled,
      style: ElevatedButton.styleFrom(
        minimumSize: size,
        shape: shape,
        elevation: 0,
        backgroundColor:
            style == SanadButtonStyle.dark
                ? const Color(0xFF454545)
                : AppColors.primary,
        foregroundColor: AppColors.onPrimary,
      ),
      child: child,
    );
  }
}
