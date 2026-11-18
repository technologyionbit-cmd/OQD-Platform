import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:aqd_ionbit/core/localization/generated/app_localizations.dart';
import 'package:aqd_ionbit/core/routing/route_paths.dart';
import 'package:aqd_ionbit/core/theme/app_colors.dart';
import 'package:aqd_ionbit/core/theme/app_radii.dart';
import 'package:aqd_ionbit/core/theme/app_spacing.dart';

/// Popup shown when a signed-out visitor opens something that needs an
/// account. [from] is where they were headed, so login can send them back.
class LoginRequiredDialog extends StatelessWidget {
  const LoginRequiredDialog({super.key, this.from});

  final String? from;

  void _goTo(BuildContext context, String path) {
    context.pop();
    context.push(
      Uri(
        path: path,
        queryParameters: from == null ? null : {'from': from},
      ).toString(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Dialog(
      shape: const RoundedRectangleBorder(borderRadius: AppRadii.xlRadius),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.infoBackground,
              ),
              child: const Icon(
                Icons.lock_outline,
                color: AppColors.primary,
                size: 30,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              l10n.loginRequiredTitle,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              l10n.loginRequiredMessage,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
            ),
            const SizedBox(height: AppSpacing.xl),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => _goTo(context, RoutePaths.login),
                child: Text(l10n.authLoginTitle),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => _goTo(context, RoutePaths.register),
                child: Text(l10n.authRegisterTitle),
              ),
            ),
            TextButton(
              onPressed: () => context.pop(),
              child: Text(l10n.loginRequiredLater),
            ),
          ],
        ),
      ),
    );
  }
}
