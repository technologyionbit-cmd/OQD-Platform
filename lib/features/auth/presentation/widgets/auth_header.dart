import 'package:flutter/material.dart';

import 'package:aqd_ionbit/core/theme/app_colors.dart';
import 'package:aqd_ionbit/core/theme/app_radii.dart';
import 'package:aqd_ionbit/core/theme/app_spacing.dart';
import 'package:aqd_ionbit/core/widgets/app_logo.dart';

/// The navy hero at the top of every auth screen: a back button (and an
/// optional [trailing] action) on the first row, then either the Aqd
/// wordmark ([showLogo]) or an icon badge, and the white title/subtitle.
/// It draws no background of its own: [AuthScaffold] paints the navy
/// gradient behind it and the form sheet.
class AuthHeader extends StatelessWidget {
  const AuthHeader({
    super.key,
    this.icon,
    this.showLogo = false,
    this.title,
    this.subtitle,
    this.showBackButton = true,
    this.trailing,
  }) : assert(icon != null || showLogo, 'Pass an icon or set showLogo');

  final IconData? icon;
  final bool showLogo;
  final String? title;
  final String? subtitle;
  final bool showBackButton;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.xs,
          AppSpacing.md,
          AppSpacing.md,
        ),
        child: Column(
          children: [
            SizedBox(
              height: 44,
              child: Row(
                children: [
                  if (showBackButton)
                    const BackButton(color: AppColors.onPrimary),
                  const Spacer(),
                  if (trailing != null) trailing!,
                ],
              ),
            ),
            if (showLogo)
              const AppLogo(width: 150, onDark: true)
            else
              Container(
                width: 56,
                height: 56,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.onPrimary.withValues(alpha: 0.12),
                  borderRadius: AppRadii.mdRadius,
                ),
                child: Icon(icon, color: AppColors.onPrimary, size: 28),
              ),
            if (title != null) ...[
              const SizedBox(height: AppSpacing.md),
              Text(
                title!,
                textAlign: TextAlign.center,
                style: textTheme.headlineSmall?.copyWith(
                  color: AppColors.onPrimary,
                ),
              ),
            ],
            if (subtitle != null) ...[
              const SizedBox(height: AppSpacing.xxs),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.onPrimary.withValues(alpha: 0.75),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
