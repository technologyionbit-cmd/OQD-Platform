import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:aqd_ionbit/core/localization/generated/app_localizations.dart';
import 'package:aqd_ionbit/core/routing/route_paths.dart';
import 'package:aqd_ionbit/core/theme/app_colors.dart';
import 'package:aqd_ionbit/core/theme/app_spacing.dart';
import 'package:aqd_ionbit/core/widgets/app_button.dart';
import 'package:aqd_ionbit/core/widgets/app_card.dart';
import 'package:aqd_ionbit/core/widgets/empty_state.dart';
import 'package:aqd_ionbit/core/widgets/error_view.dart';
import 'package:aqd_ionbit/core/widgets/home_greeting_header.dart';
import 'package:aqd_ionbit/core/widgets/loading_view.dart';
import 'package:aqd_ionbit/core/widgets/section_header.dart';
import 'package:aqd_ionbit/features/auth/presentation/providers/auth_controller.dart';
import 'package:aqd_ionbit/features/contracts/presentation/providers/contracts_controller.dart';
import 'package:aqd_ionbit/features/contracts/presentation/widgets/contract_card.dart';

/// The client's landing tab: quick action, recent contracts, and the
/// legal-services grid. Contract analysis (`AI`-phase work) and Find a
/// Lawyer (the lawyers tab, not yet built out) are represented here as
/// real navigation entries per the brief, without their own business
/// logic — see `RoutePaths.clientContractsAnalyze` and `clientLawyers`.
class ClientHomeScreen extends ConsumerWidget {
  const ClientHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final user = ref.watch(authControllerProvider).value;
    final contractsState = ref.watch(contractsControllerProvider);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => ref.read(contractsControllerProvider.notifier).refresh(),
        child: ListView(
          children: [
            HomeGreetingHeader(
              greeting: user != null ? l10n.homeWelcome(user.fullName) : l10n.navHome,
              icon: Icons.waving_hand_outlined,
              trailing: IconButton(
                icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                tooltip: l10n.clientNotificationsTitle,
                onPressed: () => context.push(RoutePaths.clientNotifications),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppButton(
                    label: l10n.clientHomeCreateContract,
                    icon: Icons.add,
                    onPressed: () => context.push(RoutePaths.clientContractsNew),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  SectionHeader(
                    title: l10n.clientHomeMyContracts,
                    actionLabel: l10n.commonViewAll,
                    onActionTap: () => context.push(RoutePaths.clientContracts),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  switch (contractsState) {
                    AsyncData(value: final contracts) when contracts.isEmpty => EmptyState(
                      icon: Icons.description_outlined,
                      title: l10n.clientHomeNoContractsTitle,
                      message: l10n.clientHomeNoContractsMessage,
                    ),
                    AsyncData(value: final contracts) => Column(
                      children: [
                        for (final contract in contracts.take(3)) ...[
                          ContractCard(
                            contract: contract,
                            onTap: () => context.push(RoutePaths.clientContractDetails(contract.id)),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                        ],
                      ],
                    ),
                    AsyncError() => ErrorView(
                      message: l10n.errorGeneric,
                      onRetry: () => ref.read(contractsControllerProvider.notifier).refresh(),
                    ),
                    _ => const LoadingView(),
                  },
                  const SizedBox(height: AppSpacing.xl),
                  SectionHeader(title: l10n.clientHomeServicesTitle),
                  const SizedBox(height: AppSpacing.sm),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: AppSpacing.sm,
                    crossAxisSpacing: AppSpacing.sm,
                    childAspectRatio: 1.05,
                    children: [
                      _ServiceCard(
                        icon: Icons.add_circle_outline,
                        label: l10n.serviceCreateContract,
                        onTap: () => context.push(RoutePaths.clientContractsNew),
                      ),
                      _ServiceCard(
                        icon: Icons.search_outlined,
                        label: l10n.serviceAnalyzeContract,
                        onTap: () => context.push(RoutePaths.clientContractsAnalyze),
                      ),
                      _ServiceCard(
                        icon: Icons.gavel_outlined,
                        label: l10n.serviceFindLawyer,
                        onTap: () => context.go(RoutePaths.clientLawyers),
                      ),
                      _ServiceCard(
                        icon: Icons.folder_outlined,
                        label: l10n.navDocuments,
                        onTap: () => context.go(RoutePaths.clientDocuments),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({required this.icon, required this.label, required this.onTap});

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
          Icon(icon, color: AppColors.primary, size: 24),
          const SizedBox(height: AppSpacing.xxs),
          Flexible(
            child: Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ),
        ],
      ),
    );
  }
}
