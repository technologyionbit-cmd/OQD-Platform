import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:aqd_ionbit/core/localization/generated/app_localizations.dart';
import 'package:aqd_ionbit/core/localization/locale_controller.dart';
import 'package:aqd_ionbit/core/routing/route_paths.dart';
import 'package:aqd_ionbit/core/theme/app_colors.dart';
import 'package:aqd_ionbit/core/theme/app_gradients.dart';
import 'package:aqd_ionbit/core/theme/app_radii.dart';
import 'package:aqd_ionbit/core/theme/app_spacing.dart';
import 'package:aqd_ionbit/core/widgets/app_card.dart';
import 'package:aqd_ionbit/core/widgets/confirmation_dialog.dart';
import 'package:aqd_ionbit/features/auth/domain/entities/user_role.dart';
import 'package:aqd_ionbit/features/auth/presentation/providers/auth_controller.dart';
import 'package:aqd_ionbit/features/billing/domain/entities/subscription_tier.dart';
import 'package:aqd_ionbit/features/billing/presentation/providers/subscription_controller.dart';
import 'package:aqd_ionbit/features/consultations/presentation/providers/consultations_controller.dart';
import 'package:aqd_ionbit/features/contracts/presentation/providers/contracts_controller.dart';
import 'package:aqd_ionbit/features/documents/presentation/providers/documents_controller.dart';
import 'package:aqd_ionbit/features/lawyers/domain/entities/lawyer_profile.dart';

/// Shared across all three roles — identity header (avatar, plan badge,
/// activity stats), then the full reference menu (subscriptions, payment
/// methods, saved signature, documents, bookings, invoices, notifications,
/// language, security, help), then logout. Every row that isn't
/// role-specific business logic routes to a real screen with working mock
/// state — none of it is decorative.
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

  String _editProfileRouteFor(UserRole role) {
    return switch (role) {
      UserRole.client => RoutePaths.clientAccountEdit,
      UserRole.lawyer => RoutePaths.lawyerAccountEdit,
      UserRole.company => RoutePaths.companyAccountEdit,
    };
  }

  String _roleBase(UserRole role) => switch (role) {
    UserRole.client => RoutePaths.clientBase,
    UserRole.lawyer => RoutePaths.lawyerBase,
    UserRole.company => RoutePaths.companyBase,
  };

  String _documentsRouteFor(UserRole role) => switch (role) {
    UserRole.client => RoutePaths.clientDocuments,
    UserRole.lawyer => RoutePaths.lawyerDocuments,
    UserRole.company => RoutePaths.companyDocuments,
  };

  String _bookingsRouteFor(UserRole role) => switch (role) {
    UserRole.client => RoutePaths.clientConsultations,
    UserRole.lawyer => RoutePaths.lawyerConsultations,
    UserRole.company => RoutePaths.companyConsultations,
  };

  String _planBadgeLabel(SubscriptionTier? tier, AppLocalizations l10n) {
    return switch (tier) {
      null => l10n.subscriptionNoPlan,
      SubscriptionTier.basic => l10n.subscriptionTierBasic,
      SubscriptionTier.pro => l10n.subscriptionTierPro,
      SubscriptionTier.enterprise => l10n.subscriptionTierEnterprise,
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final user = ref.watch(authControllerProvider).value;
    final locale = ref.watch(localeControllerProvider);
    final subscription = ref.watch(subscriptionControllerProvider);
    final documentsCount = ref.watch(documentsControllerProvider).value?.length ?? 0;
    final allConsultations = ref.watch(consultationsControllerProvider).value ?? const [];
    final consultationsCount = user?.role == UserRole.lawyer
        ? allConsultations.where((c) => c.lawyerId == kDemoLawyerId).length
        : allConsultations.length;
    final contractsCount = ref.watch(contractsControllerProvider).value?.length ?? 0;
    final base = user != null ? _roleBase(user.role) : RoutePaths.clientBase;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            if (user != null) _ProfileHeader(name: user.fullName, email: user.email, planLabel: _planBadgeLabel(subscription.tier, l10n)),
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.xl, 0, AppSpacing.xl, 0),
              child: Transform.translate(
                offset: const Offset(0, -AppSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (user != null)
                      AppCard(
                        child: Row(
                          children: [
                            Expanded(child: _StatItem(value: '$documentsCount', label: l10n.accountStatDocuments)),
                            const _StatDivider(),
                            Expanded(child: _StatItem(value: '$consultationsCount', label: l10n.accountStatConsultations)),
                            const _StatDivider(),
                            Expanded(child: _StatItem(value: '$contractsCount', label: l10n.accountStatContracts)),
                          ],
                        ),
                      ),
                    const SizedBox(height: AppSpacing.lg),
                    AppCard(
                      padding: EdgeInsets.zero,
                      child: Column(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.person_outline),
                            title: Text(l10n.editProfileTitle),
                            subtitle: Text(l10n.accountEditProfileSubtitle),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => context.push(user != null ? _editProfileRouteFor(user.role) : RoutePaths.clientAccountEdit),
                          ),
                          if (user?.role == UserRole.lawyer) ...[
                            const Divider(height: 1),
                            ListTile(
                              leading: const Icon(Icons.badge_outlined),
                              title: Text(l10n.lawyerEditProfileTitle),
                              subtitle: Text(l10n.lawyerEditProfileSubtitle),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () => context.push(RoutePaths.lawyerProfileEdit),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppCard(
                      padding: EdgeInsets.zero,
                      child: Column(
                        children: [
                          _MenuRow(
                            icon: Icons.workspace_premium_outlined,
                            label: l10n.accountMenuSubscriptions,
                            onTap: () => context.push(RoutePaths.subscriptionPlansFor(base)),
                          ),
                          const Divider(height: 1),
                          _MenuRow(
                            icon: Icons.credit_card_outlined,
                            label: l10n.accountMenuPaymentMethods,
                            onTap: () => context.push(RoutePaths.paymentMethodsFor(base)),
                          ),
                          const Divider(height: 1),
                          _MenuRow(
                            icon: Icons.draw_outlined,
                            label: l10n.accountMenuSavedSignature,
                            onTap: () => context.push(RoutePaths.savedSignatureFor(base)),
                          ),
                          const Divider(height: 1),
                          _MenuRow(icon: Icons.folder_outlined, label: l10n.navDocuments, onTap: () => context.go(_documentsRouteFor(user?.role ?? UserRole.client))),
                          const Divider(height: 1),
                          _MenuRow(
                            icon: Icons.event_note_outlined,
                            label: l10n.accountMenuBookings,
                            onTap: () => context.push(_bookingsRouteFor(user?.role ?? UserRole.client)),
                          ),
                          const Divider(height: 1),
                          _MenuRow(
                            icon: Icons.receipt_long_outlined,
                            label: l10n.accountMenuInvoices,
                            onTap: () => context.push(RoutePaths.invoicesFor(base)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppCard(
                      padding: EdgeInsets.zero,
                      child: Column(
                        children: [
                          _MenuRow(
                            icon: Icons.notifications_outlined,
                            label: l10n.clientNotificationsTitle,
                            onTap: () => context.push(_notificationsRouteFor(user?.role ?? UserRole.client)),
                          ),
                          const Divider(height: 1),
                          ListTile(
                            leading: const Icon(Icons.language_outlined),
                            title: Text(l10n.accountLanguage),
                            trailing: Text(locale.languageCode == 'ar' ? 'العربية' : 'English'),
                            onTap: () {
                              final next = locale.languageCode == 'ar' ? const Locale('en') : const Locale('ar');
                              ref.read(localeControllerProvider.notifier).setLocale(next);
                            },
                          ),
                          const Divider(height: 1),
                          _MenuRow(
                            icon: Icons.shield_outlined,
                            label: l10n.accountMenuSecurity,
                            onTap: () => context.push(RoutePaths.securityPrivacyFor(base)),
                          ),
                          const Divider(height: 1),
                          _MenuRow(
                            icon: Icons.help_outline,
                            label: l10n.accountMenuHelp,
                            onTap: () => context.push(RoutePaths.helpSupportFor(base)),
                          ),
                        ],
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
                    const SizedBox(height: AppSpacing.xl),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _notificationsRouteFor(UserRole role) => switch (role) {
    UserRole.client => RoutePaths.clientNotifications,
    UserRole.lawyer => RoutePaths.lawyerNotifications,
    UserRole.company => RoutePaths.companyNotifications,
  };
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.name, required this.email, required this.planLabel});

  final String name;
  final String email;
  final String planLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.xl, AppSpacing.xl, AppSpacing.xxxl),
      decoration: const BoxDecoration(gradient: AppGradients.navyHeader),
      child: Column(
        children: [
          Container(
            width: 84,
            height: 84,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: AppColors.onPrimary.withValues(alpha: 0.12), shape: BoxShape.circle, border: Border.all(color: Colors.white24, width: 2)),
            child: const Icon(Icons.person, color: AppColors.onPrimary, size: 40),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(name, style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.onPrimary, fontWeight: FontWeight.w700)),
          const SizedBox(height: AppSpacing.xxs),
          Text(email, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.onPrimary.withValues(alpha: 0.7))),
          const SizedBox(height: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xxs),
            decoration: BoxDecoration(color: AppColors.secondary.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(AppRadii.pill)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star, color: AppColors.secondary, size: 14),
                const SizedBox(width: AppSpacing.xxs),
                Text(planLabel, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppColors.secondary, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: AppSpacing.xxs),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _StatDivider extends StatelessWidget {
  const _StatDivider();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(height: 36, child: VerticalDivider(width: AppSpacing.lg));
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(leading: Icon(icon), title: Text(label), trailing: const Icon(Icons.chevron_right), onTap: onTap);
  }
}
