import 'package:flutter/material.dart';

import 'package:aqd_ionbit/core/localization/generated/app_localizations.dart';
import 'package:aqd_ionbit/core/theme/app_spacing.dart';
import 'package:aqd_ionbit/core/widgets/app_button.dart';

/// Full-page error state with a retry action. Callers pass an
/// already-localized message — this widget never sees a [Failure] or raw
/// exception directly (see core/errors + failure_localizer once screens
/// need it), keeping it reusable outside the auth/network context too.
class ErrorView extends StatelessWidget {
  const ErrorView({super.key, required this.message, this.onRetry, this.retryLabel});

  final String message;
  final VoidCallback? onRetry;

  /// Defaults to the localized "Retry" — override only for a
  /// context-specific verb (e.g. "Reload"). Every current call site relies
  /// on this default rather than passing its own, which is exactly why it
  /// must be localized here and not a hardcoded literal.
  final String? retryLabel;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 40, color: Theme.of(context).colorScheme.error),
            const SizedBox(height: AppSpacing.md),
            Text(message, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium),
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.lg),
              AppButton(
                label: retryLabel ?? AppLocalizations.of(context)!.commonRetry,
                onPressed: onRetry,
                variant: AppButtonVariant.outlined,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
