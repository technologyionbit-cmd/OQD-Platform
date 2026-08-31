import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aqd_ionbit/core/localization/generated/app_localizations.dart';
import 'package:aqd_ionbit/core/localization/locale_controller.dart';
import 'package:aqd_ionbit/core/providers/core_providers.dart';
import 'package:aqd_ionbit/core/theme/app_radii.dart';
import 'package:aqd_ionbit/core/theme/app_spacing.dart';
import 'package:aqd_ionbit/core/theme/app_status_colors.dart';
import 'package:aqd_ionbit/features/auth/presentation/providers/auth_controller.dart';

/// Placeholder authenticated landing screen. This is foundation-phase
/// scaffolding to prove the auth/theme/l10n/routing stack end-to-end — the
/// real role-based home screens (client/lawyer/company) are built once the
/// screenshots are available.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final authState = ref.watch(authControllerProvider);
    final envConfig = ref.watch(envConfigProvider);
    final locale = ref.watch(localeControllerProvider);
    final user = authState.value;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appName),
        actions: [
          IconButton(
            icon: const Icon(Icons.translate),
            tooltip: locale.languageCode == 'ar' ? 'English' : 'العربية',
            onPressed: () {
              final next = locale.languageCode == 'ar' ? const Locale('en') : const Locale('ar');
              ref.read(localeControllerProvider.notifier).setLocale(next);
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: l10n.commonLogout,
            onPressed: () => ref.read(authControllerProvider.notifier).logout(),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                decoration: BoxDecoration(
                  color: context.statusColors.info.background,
                  borderRadius: AppRadii.smRadius,
                ),
                child: Text(
                  l10n.foundationEnvBanner(envConfig.environment.name),
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(color: context.statusColors.info.foreground),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              if (user != null) ...[
                Text(l10n.homeWelcome(user.fullName), style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: AppSpacing.xs),
                Text(user.role.name, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
