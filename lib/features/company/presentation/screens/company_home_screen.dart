import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:aqd_ionbit/core/localization/generated/app_localizations.dart';
import 'package:aqd_ionbit/core/routing/route_paths.dart';
import 'package:aqd_ionbit/core/theme/app_colors.dart';
import 'package:aqd_ionbit/core/theme/app_spacing.dart';
import 'package:aqd_ionbit/core/widgets/app_card.dart';
import 'package:aqd_ionbit/core/widgets/home_greeting_header.dart';
import 'package:aqd_ionbit/core/widgets/section_header.dart';
import 'package:aqd_ionbit/features/auth/presentation/providers/auth_controller.dart';
import 'package:aqd_ionbit/features/consultations/domain/entities/consultation_status.dart';
import 'package:aqd_ionbit/features/consultations/presentation/providers/consultations_controller.dart';
import 'package:aqd_ionbit/features/contracts/domain/entities/contract_status.dart';
import 'package:aqd_ionbit/features/contracts/presentation/providers/contracts_controller.dart';
import 'package:aqd_ionbit/features/documents/presentation/providers/documents_controller.dart';
import 'package:aqd_ionbit/features/notifications/presentation/providers/notifications_controller.dart';
import 'package:aqd_ionbit/features/team/presentation/providers/team_controller.dart';

class CompanyHomeScreen extends ConsumerWidget {
  const CompanyHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final user = ref.watch(authControllerProvider).value;
    final unreadCount = ref.watch(unreadNotificationsCountProvider);
    final contracts = ref.watch(contractsControllerProvider).value ?? const [];
    final documents = ref.watch(documentsControllerProvider).value ?? const [];
    final team = ref.watch(teamControllerProvider).value ?? const [];
    final consultations = ref.watch(consultationsControllerProvider).value ?? const [];
    final activeConsultations = consultations.where((c) => c.status == ConsultationStatus.confirmed).length;

    return Scaffold(
      body: ListView(
        children: [
          HomeGreetingHeader(
            greeting: user != null ? l10n.homeWelcome(user.fullName) : l10n.navHome,
            icon: Icons.apartment_outlined,
            trailing: Badge(
              isLabelVisible: unreadCount > 0,
              label: Text('$unreadCount'),
              child: IconButton(
                icon: const Icon(Icons.notifications_outlined, color: AppColors.onPrimary),
                onPressed: () => context.push(RoutePaths.companyNotifications),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: AppSpacing.sm,
                  crossAxisSpacing: AppSpacing.sm,
                  childAspectRatio: 1.6,
                  children: [
                    _SummaryCard(
                      icon: Icons.description_outlined,
                      label: l10n.navContracts,
                      value: '${contracts.length}',
                      onTap: () => context.go(RoutePaths.companyContracts),
                    ),
                    _SummaryCard(
                      icon: Icons.folder_outlined,
                      label: l10n.navDocuments,
                      value: '${documents.length}',
                      onTap: () => context.go(RoutePaths.companyDocuments),
                    ),
                    _SummaryCard(
                      icon: Icons.groups_outlined,
                      label: l10n.navTeam,
                      value: '${team.length}',
                      onTap: () => context.push(RoutePaths.companyTeam),
                    ),
                    _SummaryCard(
                      icon: Icons.event_note_outlined,
                      label: l10n.companyActiveConsultations,
                      value: '$activeConsultations',
                      onTap: () => context.push(RoutePaths.companyConsultations),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                SectionHeader(title: l10n.dashboardQuickActions),
                const SizedBox(height: AppSpacing.sm),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 3,
                  mainAxisSpacing: AppSpacing.sm,
                  crossAxisSpacing: AppSpacing.sm,
                  childAspectRatio: 1.05,
                  children: [
                    _QuickAction(
                      icon: Icons.add_circle_outline,
                      label: l10n.serviceCreateContract,
                      onTap: () => context.push(RoutePaths.companyContractsNew),
                    ),
                    _QuickAction(icon: Icons.gavel_outlined, label: l10n.serviceFindLawyer, onTap: () => context.go(RoutePaths.companyLawyers)),
                    _QuickAction(icon: Icons.person_add_outlined, label: l10n.teamAddMemberAction, onTap: () => context.push(RoutePaths.companyTeam)),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                SectionHeader(
                  title: l10n.clientHomeMyContracts,
                  actionLabel: l10n.commonViewAll,
                  onActionTap: () => context.go(RoutePaths.companyContracts),
                ),
                const SizedBox(height: AppSpacing.sm),
                if (contracts.isEmpty)
                  Text(l10n.clientHomeNoContractsMessage, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary))
                else
                  Column(
                    children: [
                      for (final contract in contracts.take(3))
                        Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                          child: AppCard(
                            onTap: () => context.push(RoutePaths.companyContractDetails(contract.id)),
                            child: Row(
                              children: [
                                Icon(
                                  contract.status == ContractStatus.completed ? Icons.check_circle_outline : Icons.pending_outlined,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Expanded(
                                  child: Text(contract.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodyMedium),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.icon, required this.label, required this.value, required this.onTap});

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 28),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.titleLarge),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.primary, size: 22),
          const SizedBox(height: AppSpacing.xxs),
          Flexible(
            child: Text(label, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.labelSmall),
          ),
        ],
      ),
    );
  }
}
