import 'package:flutter/material.dart';

import 'package:aqd_ionbit/core/theme/app_gradients.dart';
import 'package:aqd_ionbit/core/theme/app_radii.dart';
import 'package:aqd_ionbit/core/theme/app_spacing.dart';

/// The dark-navy hero used at the top of register/forgot-password/OTP
/// screens: back button, centered icon badge, white title/subtitle. Login
/// deliberately does NOT use this — it stays on a plain white background
/// with just a small icon badge, matching the reference screenshots.
class AuthHeader extends StatelessWidget {
  const AuthHeader({super.key, required this.icon, this.title, this.subtitle, this.showBackButton = true});

  final IconData icon;
  final String? title;
  final String? subtitle;
  final bool showBackButton;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(gradient: AppGradients.navyHeader),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.xs, AppSpacing.md, AppSpacing.xxl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 40,
                child: showBackButton ? const Align(alignment: AlignmentDirectional.topStart, child: BackButton(color: Colors.white)) : null,
              ),
              Container(
                width: 56,
                height: 56,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.12), borderRadius: AppRadii.mdRadius),
                child: Icon(icon, color: Colors.white, size: 28),
              ),
              if (title != null) ...[
                const SizedBox(height: AppSpacing.md),
                Text(
                  title!,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white),
                ),
              ],
              if (subtitle != null) ...[
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  subtitle!,
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.white.withValues(alpha: 0.75)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
