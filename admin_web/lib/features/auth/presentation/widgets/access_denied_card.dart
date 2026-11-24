import 'package:flutter/material.dart';

import 'package:aqd_admin/core/localization/generated/app_localizations.dart';
import 'package:aqd_admin/core/theme/app_colors.dart';

/// Shown when the credentials were right but the account is not an admin.
class AccessDeniedCard extends StatelessWidget {
  const AccessDeniedCard({required this.onBack, super.key});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(Icons.gpp_bad_outlined, size: 48, color: AppColors.error),
        const SizedBox(height: 16),
        Text(l10n.accessDeniedTitle, textAlign: TextAlign.center, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Text(
          l10n.accessDeniedBody,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 24),
        OutlinedButton(onPressed: onBack, child: Text(l10n.backToSignIn)),
      ],
    );
  }
}
