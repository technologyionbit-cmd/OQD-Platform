import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:aqd_ionbit/core/localization/generated/app_localizations.dart';
import 'package:aqd_ionbit/core/routing/route_paths.dart';
import 'package:aqd_ionbit/core/theme/app_colors.dart';
import 'package:aqd_ionbit/core/theme/app_spacing.dart';
import 'package:aqd_ionbit/core/widgets/app_logo.dart';
import 'package:aqd_ionbit/core/widgets/language_switch_button.dart';
import 'package:aqd_ionbit/core/widgets/weather_badge.dart';
import 'package:aqd_ionbit/features/auth/presentation/widgets/sanad_button.dart';

/// Signed-out landing: three entry points, each opening its own page.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.xs,
            AppSpacing.md,
            AppSpacing.lg,
          ),
          child: Column(
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  WeatherBadge(),
                  LanguageSwitchButton(foregroundColor: AppColors.textPrimary),
                ],
              ),
              const Spacer(flex: 3),
              const AppLogo(width: 220, onDark: false),
              const SizedBox(height: AppSpacing.xs),
              Text(
                l10n.splashTagline,
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(flex: 2),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SanadButton(
                      label: l10n.authBiometricLogin,
                      icon: Icons.fingerprint_rounded,
                      style: SanadButtonStyle.dark,
                      onPressed: () => context.push(RoutePaths.biometricLogin),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    SanadButton(
                      label: l10n.authLoginTitle,
                      onPressed: () => context.push(RoutePaths.login),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    SanadButton(
                      label: l10n.authCreateAccount,
                      style: SanadButtonStyle.outlined,
                      onPressed: () => context.push(RoutePaths.register),
                    ),
                  ],
                ),
              ),
              const Spacer(flex: 3),
            ],
          ),
        ),
      ),
    );
  }
}
