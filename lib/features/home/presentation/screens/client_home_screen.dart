import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:aqd_ionbit/core/config/feature_flags.dart';
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
import 'package:aqd_ionbit/features/notifications/presentation/providers/notifications_controller.dart';

/// One tile in the "your legal services" grid — [gradientColors] stands in
/// for the reference's photography (no bundled image assets in this repo),
/// giving each card the same visual weight/hierarchy without fabricating
/// stock photos.
class _ServiceTile {
  const _ServiceTile({required this.icon, required this.title, required this.subtitle, required this.route, required this.accent});

  final IconData icon;
  final String title;
  final String subtitle;
  final String route;
  final Color accent;
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

  List<_ServiceTile> _services(AppLocalizations l10n, {required bool showPreview}) => [
    if (showPreview)
      _ServiceTile(
        icon: Icons.search_outlined,
        title: l10n.serviceAnalyzeContract,
        subtitle: l10n.serviceAnalyzeContractDesc,
        route: RoutePaths.clientContractsAnalyze,
        accent: AppColors.steelBlue,
      ),
    _ServiceTile(
      icon: Icons.description_outlined,
      title: l10n.serviceSmartContracts,
      subtitle: l10n.serviceSmartContractsDesc,
      route: RoutePaths.clientContractsNew,
      accent: AppColors.primary,
    ),
    _ServiceTile(
      icon: Icons.gavel_outlined,
      title: l10n.serviceBookLawyer,
      subtitle: l10n.serviceBookLawyerDesc,
      route: RoutePaths.clientLawyers,
      accent: AppColors.secondary,
    ),
    _ServiceTile(
      icon: Icons.account_balance_outlined,
      title: l10n.serviceGovDocuments,
      subtitle: l10n.serviceGovDocumentsDesc,
      route: RoutePaths.clientGovDocuments,
      accent: AppColors.success,
    ),
  ];

  /// Pull-to-refresh reloads every section the home shows, not just one.
  Future<void> _refresh() => Future.wait([
    ref.read(contractsControllerProvider.notifier).refresh(),
    ref.read(lawyersControllerProvider.notifier).refresh(),
    ref.read(notificationsControllerProvider.notifier).refresh(),
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
    final AsyncValue<List<Contract>> contractsState = user == null ? const AsyncData(<Contract>[]) : ref.watch(contractsControllerProvider);
    final lawyersState = ref.watch(lawyersControllerProvider);
    final unreadCount = ref.watch(unreadNotificationsCountProvider);
    final showPreview = ref.watch(previewFeaturesProvider);
    final services = _services(l10n, showPreview: showPreview);
    final isSearching = _query.trim().isNotEmpty;
    final filteredServices = isSearching ? services.where((s) => s.title.toLowerCase().contains(_query.trim().toLowerCase())).toList() : const <_ServiceTile>[];

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          children: [
            _ClientHomeHeader(
              showAi: showPreview,
              greetingName: user?.fullName,
              unreadCount: unreadCount,
              searchController: _searchController,
              onSearchChanged: (value) => setState(() => _query = value),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children:
                    isSearching
                        ? _buildSearchResults(context, l10n, filteredServices)
                        : _buildDefaultContent(context, l10n, services, contractsState, lawyersState, isGuest: user == null),
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
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: const BoxDecoration(color: AppColors.infoBackground, borderRadius: AppRadii.smRadius),
                child: Icon(tile.icon, color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(tile.title, style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(tile.subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodySmall),
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
    AsyncValue<List<LawyerProfile>> lawyersState, {
    required bool isGuest,
  }) {
    final showPreview = ref.read(previewFeaturesProvider);
    return [
      SectionHeader(title: l10n.clientHomeServicesTitle),
      const SizedBox(height: AppSpacing.sm),
      GridView(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: AppSpacing.sm,
          crossAxisSpacing: AppSpacing.sm,
          mainAxisExtent: 190,
        ),
        children: [for (final tile in services) _ServiceGridCard(tile: tile, onTap: () => _openService(tile))],
      ),
      const SizedBox(height: AppSpacing.xl),
      if (showPreview) ...[_VaultBanner(onTap: () => context.go(RoutePaths.clientDocuments)), const SizedBox(height: AppSpacing.xl)],
      if (isGuest)
        _GuestLoginCard(onTap: () => context.push(RoutePaths.welcome))
      else ...[
        SectionHeader(title: l10n.clientHomeRecentActivity, actionLabel: l10n.commonViewAll, onActionTap: () => context.push(RoutePaths.clientContracts)),
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
      ],
      Builder(
        builder: (context) {
          final lawyers = lawyersState.value ?? const [];
          if (lawyers.isEmpty) return const SizedBox.shrink();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.xl),
              SectionHeader(title: l10n.clientHomeRecommendedLawyers, actionLabel: l10n.commonViewAll, onActionTap: () => context.go(RoutePaths.clientLawyers)),
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
/// headline, the search field, and the three quick-action pills — on a
/// gradient with rounded bottom corners and soft decorative circles.
class _ClientHomeHeader extends StatelessWidget {
  const _ClientHomeHeader({
    required this.showAi,
    required this.greetingName,
    required this.unreadCount,
    required this.searchController,
    required this.onSearchChanged,
  });

  final bool showAi;
  final String? greetingName;
  final int unreadCount;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(
        gradient: AppGradients.navyHeader,
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(AppRadii.xl + 8), bottomRight: Radius.circular(AppRadii.xl + 8)),
      ),
      child: Stack(
        children: [
          PositionedDirectional(
            end: -50,
            top: -40,
            child: Container(width: 180, height: 180, decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.onPrimary.withValues(alpha: 0.05))),
          ),
          PositionedDirectional(
            start: -40,
            bottom: 30,
            child: Container(width: 110, height: 110, decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.primary.withValues(alpha: 0.12))),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.md, AppSpacing.xl, AppSpacing.xl + AppSpacing.xs),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          greetingName != null ? l10n.homeWelcome(greetingName!) : l10n.navHome,
                          style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.onPrimary.withValues(alpha: 0.75)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Badge(
                        isLabelVisible: unreadCount > 0,
                        label: Text(unreadCount > 99 ? '99+' : '$unreadCount'),
                        child: Container(
                          decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.onPrimary.withValues(alpha: 0.12)),
                          child: IconButton(
                            icon: const Icon(Icons.notifications_outlined, color: AppColors.onPrimary),
                            tooltip: l10n.clientNotificationsTitle,
                            onPressed: () => context.push(RoutePaths.clientNotifications),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    l10n.clientHomeHeroTitle,
                    style: theme.textTheme.headlineSmall?.copyWith(color: AppColors.onPrimary, fontWeight: FontWeight.w800, height: 1.35),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: AppRadii.lgRadius,
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.18), blurRadius: 18, offset: const Offset(0, 6))],
                    ),
                    child: TextField(
                      controller: searchController,
                      onChanged: onSearchChanged,
                      style: theme.textTheme.bodyLarge,
                      decoration: InputDecoration(
                        hintText: l10n.clientHomeSearchHint,
                        prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                        filled: true,
                        fillColor: AppColors.onPrimary,
                        border: const OutlineInputBorder(borderRadius: AppRadii.lgRadius, borderSide: BorderSide.none),
                        enabledBorder: const OutlineInputBorder(borderRadius: AppRadii.lgRadius, borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    children: [
                      if (showAi) ...[
                        Expanded(
                          child: _QuickActionPill(
                            icon: Icons.smart_toy_outlined,
                            label: l10n.clientHomeQuickAskAi,
                            onTap: () => context.go(RoutePaths.clientAi),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                      ],
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
        ],
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
    return Material(
      color: AppColors.onPrimary.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(borderRadius: AppRadii.lgRadius, side: BorderSide(color: AppColors.onPrimary.withValues(alpha: 0.2))),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.lgRadius,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md, horizontal: AppSpacing.xs),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.onPrimary.withValues(alpha: 0.14)),
                child: Icon(icon, color: AppColors.onPrimary, size: 20),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppColors.onPrimary, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

List<BoxShadow> _softShadow(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
        ? const []
        : [BoxShadow(color: AppColors.navy.withValues(alpha: 0.07), blurRadius: 16, offset: const Offset(0, 6))];

class _ServiceGridCard extends StatelessWidget {
  const _ServiceGridCard({required this.tile, required this.onTap});

  final _ServiceTile tile;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    return Container(
      decoration: BoxDecoration(borderRadius: AppRadii.xlRadius, boxShadow: _softShadow(context)),
      child: Material(
        color: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: AppRadii.xlRadius, side: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6))),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppRadii.lg),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [tile.accent, Color.lerp(tile.accent, AppColors.navy, 0.35)!],
                        ),
                        boxShadow: [BoxShadow(color: tile.accent.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4))],
                      ),
                      child: Icon(tile.icon, color: AppColors.onPrimary, size: 24),
                    ),
                    Icon(isRtl ? Icons.north_west : Icons.north_east, size: 18, color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6)),
                  ],
                ),
                const Spacer(),
                Text(tile.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: AppSpacing.xxs),
                Text(tile.subtitle, maxLines: 2, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodySmall?.copyWith(height: 1.4)),
              ],
            ),
          ),
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
    return Material(
      borderRadius: AppRadii.xlRadius,
      clipBehavior: Clip.antiAlias,
      color: Colors.transparent,
      child: Ink(
        decoration: const BoxDecoration(gradient: AppGradients.navyHeader, borderRadius: AppRadii.xlRadius),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: AppColors.onPrimary.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(AppRadii.lg)),
                  child: const Icon(Icons.lock_outline, color: AppColors.onPrimary, size: 24),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.clientHomeVaultTitle,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(color: AppColors.onPrimary, fontWeight: FontWeight.w700),
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
                  color: AppColors.onPrimary.withValues(alpha: 0.8),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Shown instead of "recent activity" to signed-out visitors.
class _GuestLoginCard extends StatelessWidget {
  const _GuestLoginCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.infoBackground,
        borderRadius: AppRadii.xlRadius,
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.clientHomeGuestTitle, style: theme.textTheme.titleMedium?.copyWith(color: AppColors.navy, fontWeight: FontWeight.w800)),
          const SizedBox(height: AppSpacing.xs),
          Text(l10n.clientHomeGuestSubtitle, style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary, height: 1.5)),
          const SizedBox(height: AppSpacing.md),
          SizedBox(width: double.infinity, child: FilledButton(onPressed: onTap, child: Text(l10n.authLoginTitle))),
        ],
      ),
    );
  }
}
