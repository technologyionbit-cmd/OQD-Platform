import 'package:flutter/material.dart';

import 'package:aqd_ionbit/core/theme/app_radii.dart';
import 'package:aqd_ionbit/core/theme/app_spacing.dart';
import 'package:aqd_ionbit/core/theme/app_status_colors.dart';

/// Inline, form-level error banner shared by every auth form. Renders
/// nothing when [message] is null, so callers can drop it in
/// unconditionally.
class AuthFormError extends StatelessWidget {
  const AuthFormError(this.message, {super.key});

  final String? message;

  @override
  Widget build(BuildContext context) {
    final message = this.message;
    if (message == null) return const SizedBox.shrink();

    final colors = context.statusColors.error;
    // liveRegion: screen readers announce the error as soon as it appears,
    // without the user having to find it.
    return Semantics(
      liveRegion: true,
      container: true,
      child: Container(
        margin: const EdgeInsets.only(top: AppSpacing.sm),
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(color: colors.background, borderRadius: AppRadii.mdRadius),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.error_outline, size: 18, color: colors.foreground),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Text(message, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colors.foreground)),
            ),
          ],
        ),
      ),
    );
  }
}
