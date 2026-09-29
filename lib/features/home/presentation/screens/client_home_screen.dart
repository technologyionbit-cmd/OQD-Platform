import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:aqd_ionbit/core/localization/generated/app_localizations.dart';
import 'package:aqd_ionbit/core/routing/route_paths.dart';
import 'package:aqd_ionbit/core/theme/app_colors.dart';
import 'package:aqd_ionbit/core/theme/app_gradients.dart';
import 'package:aqd_ionbit/core/theme/app_radii.dart';
import 'package:aqd_ionbit/core/theme/app_spacing.dart';
import 'package:aqd_ionbit/core/widgets/app_card.dart';
import 'package:aqd_ionbit/core/widgets/empty_state.dart';
import 'package:aqd_ionbit/core/widgets/error_view.dart';
import 'package:aqd_ionbit/core/widgets/loading_view.dart';
import 'package:aqd_ionbit/core/widgets/section_header.dart';
import 'package:aqd_ionbit/features/auth/presentation/providers/auth_controller.dart';
import 'package:aqd_ionbit/features/contracts/domain/entities/contract.dart';
import 'package:aqd_ionbit/features/contracts/presentation/providers/contracts_controller.dart';
import 'package:aqd_ionbit/features/contracts/presentation/widgets/contract_card.dart';
import 'package:aqd_ionbit/features/lawyers/domain/entities/lawyer_profile.dart';
import 'package:aqd_ionbit/features/lawyers/presentation/providers/lawyers_controller.dart';
import 'package:aqd_ionbit/features/lawyers/presentation/widgets/lawyer_card.dart';

/// One tile in the "your legal services" grid — [gradientColors] stands in
/// for the reference's photography (no bundled image assets in this repo),
/// giving each card the same visual weight/hierarchy without fabricating
/// stock photos.
class _ServiceTile {
  const _ServiceTile({required this.icon, required this.title, required this.subtitle, required this.gradientColors, required this.route});

  final IconData icon;
  final String title;
  final String subtitle;
  final Gradient gradientColors;
  final String route;
}

/// The client's landing tab — rebuilt to match the reference screenshots'
/// structure: hero greeting + search + quick actions on the navy header,
/// then the services grid, the digital-vault banner, and a recent-activity
/// feed (sourced from the same contracts data the old "My Contracts"
/// section used — same underlying functionality, reference-matching
/// framing). Recommended Lawyers isn't part of the reference flow but is
/// kept as a trailing bonus section rather than dropped, since it's
/// existing working navigation into the lawyers marketplace.
class ClientHomeScreen extends ConsumerStatefulWidget {
  const ClientHomeScreen({super.key});

  @override
  ConsumerState<ClientHomeScreen> createState() => _ClientHomeScreenState();
}

class _ClientHomeScreenState extends ConsumerState<ClientHomeScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<_ServiceTile> _services(AppLocalizations l10n) => [
    _ServiceTile(
      icon: Icons.search_outlined,
      title: l10n.serviceAnalyzeContract,
      subtitle: l10n.serviceAnalyzeContractDesc,
      gradientColors: AppGradients.serviceTileAnalyze,
      route: RoutePaths.clientContractsAnalyze,
    ),
    _ServiceTile(
      icon: Icons.description_outlined,
      title: l10n.serviceSmartContracts,
      subtitle: l10n.serviceSmartContractsDesc,
      gradientColors: AppGradients.serviceTileContracts,
      route: RoutePaths.clientContractsNew,
    ),
    _ServiceTile(
      icon: Icons.gavel_outlined,
      title: l10n.serviceBookLawyer,
      subtitle: l10n.serviceBookLawyerDesc,
      gradientColors: AppGradients.serviceTileLawyer,
      route: RoutePaths.clientLawyers,
    ),
    _ServiceTile(
      icon: Icons.account_balance_outlined,
      title: l10n.serviceGovDocuments,
      subtitle: l10n.serviceGovDocumentsDesc,
      gradientColors: AppGradients.serviceTileGovDocuments,
      route: RoutePaths.clientGovDocuments,
    ),
  ];

  /// Pull-to-refresh reloads every section the home shows, not just one.
  Future<void> _refresh() => Future.wait([
    ref.read(contractsControllerProvider.notifier).refresh(),
    ref.read(lawyersControllerProvider.notifier).refresh(),
  ]);

  void _openService(_ServiceTile tile) {
    if (tile.route == RoutePaths.clientLawyers) {
      context.go(tile.route);
    } else {
      context.push(tile.route);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final user = ref.watch(authControllerProvider).value;
    final contractsState = ref.watch(contractsControllerProvider);
    final lawyersState = ref.watch(lawyersControllerProvider);
    final services = _services(l10n);
    final isSearching = _query.trim().isNotEmpty;
    final filteredServices = isSearching
        ? services.where((s) => s.title.toLowerCase().contains(_query.trim().toLowerCase())).toList()
        : const <_ServiceTile>[];

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          children: [
            _ClientHomeHeader(
              greetingName: user?.fullName,
              // Notifications are still mock data, so real accounts would see a
              // made-up count. The badge comes back (watching
              // unreadNotificationsCountProvider) with the notifications backend.
              unreadCount: 0,
              searchController: _searchController,
              onSearchChanged: (value) => setState(() => _query = value),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: isSearching
                    ? _buildSearchResults(context, l10n, filteredServices)
                    : _buildDefaultContent(context, l10n, services, contractsState, lawyersState),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildSearchResults(BuildContext context, AppLocalizations l10n, List<_ServiceTile> results) {
    if (results.isEmpty) {
      return [EmptyState(icon: Icons.search_off_outlined, title: l10n.clientHomeSearchEmptyTitle, message: l10n.clientHomeSearchEmptyMessage)];
    }
    return [
      for (final tile in results) ...[
        AppCard(
          onTap: () => _openService(tile),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: tile.gradientColors,
                  borderRadius: AppRadii.mdRadius,
                ),
                child: Icon(tile.icon, color: AppColors.onPrimary, size: 22),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(tile.title, style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      tile.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
      ],
    ];
  }

  List<Widget> _buildDefaultContent(
    BuildContext context,
    AppLocalizations l10n,
    List<_ServiceTile> services,
    AsyncValue<List<Contract>> contractsState,
    AsyncValue<List<LawyerProfile>> lawyersState,
  ) {
    return [
      SectionHeader(title: l10n.clientHomeServicesTitle),
      const SizedBox(height: AppSpacing.sm),
      GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        mainAxisSpacing: AppSpacing.sm,
        crossAxisSpacing: AppSpacing.sm,
        childAspectRatio: 1.2,
        children: [for (final tile in services) _ServiceGridCard(tile: tile, onTap: () => _openService(tile))],
      ),
      const SizedBox(height: AppSpacing.xl),
      _VaultBanner(onTap: () => context.go(RoutePaths.clientDocuments)),
      const SizedBox(height: AppSpacing.xl),
      SectionHeader(
        title: l10n.clientHomeRecentActivity,
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
            for (final contract in contracts.take(4)) ...[
              ContractCard(contract: contract, onTap: () => context.push(RoutePaths.clientContractDetails(contract.id))),
              const SizedBox(height: AppSpacing.sm),
            ],
          ],
        ),
        AsyncError() => ErrorView(message: l10n.errorGeneric, onRetry: () => ref.read(contractsControllerProvider.notifier).refresh()),
        _ => const LoadingView(),
      },
      Builder(
        builder: (context) {
          final lawyers = lawyersState.value ?? const [];
          if (lawyers.isEmpty) return const SizedBox.shrink();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.xl),
              SectionHeader(
                title: l10n.clientHomeRecommendedLawyers,
                actionLabel: l10n.commonViewAll,
                onActionTap: () => context.go(RoutePaths.clientLawyers),
              ),
              const SizedBox(height: AppSpacing.sm),
              for (final lawyer in lawyers.take(2)) ...[
                LawyerCard(lawyer: lawyer, onTap: () => context.push(RoutePaths.clientLawyerDetails(lawyer.id))),
                const SizedBox(height: AppSpacing.sm),
              ],
            ],
          );
        },
      ),
    ];
  }
}

/// Navy hero: greeting + notification bell, a large "how can I help"
/// headline, the search field, and the three quick-action pills — all on
/// the gradient, matching the reference's header composition (distinct
/// from [HomeGreetingHeader], which the lawyer/company homes still use,
/// since only the client home carries search + quick actions).
class _ClientHomeHeader extends StatelessWidget {
  const _ClientHomeHeader({required this.greetingName, required this.unreadCount, required this.searchController, required this.onSearchChanged});

  final String? greetingName;
  final int unreadCount;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(gradient: AppGradients.navyHeader),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.md, AppSpacing.xl, AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      greetingName != null ? l10n.homeWelcome(greetingName!) : l10n.navHome,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.onPrimary.withValues(alpha: 0.7)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Badge(
                    isLabelVisible: unreadCount > 0,
                    label: Text(unreadCount > 99 ? '99+' : '$unreadCount'),
                    child: IconButton(
                      icon: const Icon(Icons.notifications_outlined, color: AppColors.onPrimary),
                      tooltip: l10n.clientNotificationsTitle,
                      onPressed: () => context.push(RoutePaths.clientNotifications),
                    ),
                  ),
                ],
              ),
              Text(
                l10n.clientHomeHeroTitle,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AppColors.onPrimary),
              ),
              const SizedBox(height: AppSpacing.lg),
              TextField(
                controller: searchController,
                onChanged: onSearchChanged,
                style: Theme.of(context).textTheme.bodyLarge,
                decoration: InputDecoration(
                  hintText: l10n.clientHomeSearchHint,
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: AppColors.onPrimary,
                  border: const OutlineInputBorder(borderRadius: AppRadii.mdRadius, borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: _QuickActionPill(
                      icon: Icons.smart_toy_outlined,
                      label: l10n.clientHomeQuickAskAi,
                      onTap: () => context.go(RoutePaths.clientAi),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _QuickActionPill(
                      icon: Icons.add_circle_outline,
                      label: l10n.clientHomeQuickCreateContract,
                      onTap: () => context.push(RoutePaths.clientContractsNew),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _QuickActionPill(
                      icon: Icons.gavel_outlined,
                      label: l10n.clientHomeQuickFindLawyer,
                      onTap: () => context.go(RoutePaths.clientLawyers),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickActionPill extends StatelessWidget {
  const _QuickActionPill({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadii.mdRadius,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm, horizontal: AppSpacing.xxs),
        decoration: BoxDecoration(
          color: AppColors.onPrimary.withValues(alpha: 0.1),
          borderRadius: AppRadii.mdRadius,
          border: Border.all(color: AppColors.onPrimary.withValues(alpha: 0.24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.onPrimary, size: 20),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.onPrimary, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

class _ServiceGridCard extends StatelessWidget {
  const _ServiceGridCard({required this.tile, required this.onTap});

  final _ServiceTile tile;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadii.lgRadius,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          gradient: tile.gradientColors,
          borderRadius: AppRadii.lgRadius,
        ),
        // mainAxisAlignment.spaceBetween + a Flexible/FittedBox text block
        // (instead of a fixed Spacer) so the card degrades gracefully —
        // scaling the title/subtitle down rather than overflowing — on the
        // narrowest phone widths the responsive audit covers (320px).
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(tile.icon, color: AppColors.onPrimary, size: 26),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: AlignmentDirectional.centerStart,
                // A fixed reference width so the subtitle still wraps onto
                // two lines like a normal card at ordinary sizes — only the
                // FittedBox's own scale factor (not the text's wrap width)
                // shrinks when the actual cell is narrower than this.
                child: SizedBox(
                  width: 120,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tile.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(color: AppColors.onPrimary, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        tile.subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.onPrimary.withValues(alpha: 0.85)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VaultBanner extends StatelessWidget {
  const _VaultBanner({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadii.lgRadius,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: const BoxDecoration(gradient: AppGradients.navyHeader, borderRadius: AppRadii.lgRadius),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: AppColors.onPrimary.withValues(alpha: 0.12), borderRadius: AppRadii.mdRadius),
              child: const Icon(Icons.lock_outline, color: AppColors.onPrimary, size: 24),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.clientHomeVaultTitle,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.onPrimary, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    l10n.clientHomeVaultSubtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.onPrimary.withValues(alpha: 0.75)),
                  ),
                ],
              ),
            ),
            Icon(
              Directionality.of(context) == TextDirection.rtl ? Icons.chevron_left : Icons.chevron_right,
              color: AppColors.onPrimary.withValues(alpha: 0.7),
            ),
          ],
        ),
      ),
    );
  }
}
