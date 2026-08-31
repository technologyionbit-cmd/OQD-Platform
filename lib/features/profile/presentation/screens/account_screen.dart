import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aqd_ionbit/core/localization/generated/app_localizations.dart';
import 'package:aqd_ionbit/core/localization/locale_controller.dart';
import 'package:aqd_ionbit/core/theme/app_colors.dart';
import 'package:aqd_ionbit/core/theme/app_spacing.dart';
import 'package:aqd_ionbit/core/widgets/app_card.dart';
import 'package:aqd_ionbit/core/widgets/confirmation_dialog.dart';
import 'package:aqd_ionbit/core/widgets/icon_badge.dart';
import 'package:aqd_ionbit/features/auth/domain/entities/user_role.dart';
import 'package:aqd_ionbit/features/auth/presentation/providers/auth_controller.dart';

/// Shared across all three roles (client/lawyer/company both label this
/// destination differently — "حسابي" vs "ملفي" — but the screen itself is
/// identical: identity, language, logout). The full settings list from the
/// screenshots (subscriptions, payment methods, saved signature, ...) is
/// real feature work for a later phase; this is deliberately just the
/// genuinely-functional part of it.
class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref, AppLocalizations l10n) async {
    final confirmed = await showConfirmationDialog(
      context,
      title: l10n.confirmLogoutTitle,
      message: l10n.confirmLogoutMessage,
      confirmLabel: l10n.commonLogout,
      cancelLabel: l10n.commonCancel,
      isDestructive: true,
    );
    if (confirmed) {
      await ref.read(authControllerProvider.notifier).logout();
    }
  }

  String _roleLabel(UserRole role, AppLocalizations l10n) {
    return switch (role) {
      UserRole.client => l10n.accountRoleClient,
      UserRole.lawyer => l10n.accountRoleLawyer,
      UserRole.company => l10n.accountRoleCompany,
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final user = ref.watch(authControllerProvider).value;
    final locale = ref.watch(localeControllerProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.navAccount)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          children: [
            if (user != null)
              AppCard(
                child: Row(
                  children: [
                    const IconBadge(icon: Icons.person_outline),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(user.fullName, style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: AppSpacing.xxs),
                          Text(
                            user.email,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: AppSpacing.xxs),
                          Text(
                            _roleLabel(user.role, l10n),
                            style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppColors.primary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: AppSpacing.lg),
            AppCard(
              padding: EdgeInsets.zero,
              child: ListTile(
                leading: const Icon(Icons.language_outlined),
                title: Text(l10n.accountLanguage),
                trailing: Text(locale.languageCode == 'ar' ? 'العربية' : 'English'),
                onTap: () {
                  final next = locale.languageCode == 'ar' ? const Locale('en') : const Locale('ar');
                  ref.read(localeControllerProvider.notifier).setLocale(next);
                },
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            AppCard(
              padding: EdgeInsets.zero,
              child: ListTile(
                leading: Icon(Icons.logout, color: Theme.of(context).colorScheme.error),
                title: Text(l10n.commonLogout, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                onTap: () => _confirmLogout(context, ref, l10n),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
