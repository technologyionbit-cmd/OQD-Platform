import 'package:flutter/material.dart';

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
              AppButton(label: retryLabel ?? 'Retry', onPressed: onRetry, variant: AppButtonVariant.outlined),
            ],
          ],
        ),
      ),
    );
  }
}
