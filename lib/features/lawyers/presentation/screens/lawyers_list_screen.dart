import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:aqd_ionbit/core/localization/generated/app_localizations.dart';
import 'package:aqd_ionbit/core/routing/route_paths.dart';
import 'package:aqd_ionbit/core/theme/app_spacing.dart';
import 'package:aqd_ionbit/core/widgets/app_bottom_sheet.dart';
import 'package:aqd_ionbit/core/widgets/app_button.dart';
import 'package:aqd_ionbit/core/widgets/app_chip.dart';
import 'package:aqd_ionbit/core/widgets/empty_state.dart';
import 'package:aqd_ionbit/core/widgets/error_view.dart';
import 'package:aqd_ionbit/core/widgets/loading_view.dart';
import 'package:aqd_ionbit/features/lawyers/domain/entities/lawyer_profile.dart';
import 'package:aqd_ionbit/features/lawyers/domain/entities/lawyer_specialty.dart';
import 'package:aqd_ionbit/features/lawyers/presentation/providers/lawyers_controller.dart';
import 'package:aqd_ionbit/features/lawyers/presentation/widgets/lawyer_availability_x.dart';
import 'package:aqd_ionbit/features/lawyers/presentation/widgets/lawyer_card.dart';
import 'package:aqd_ionbit/features/lawyers/presentation/widgets/lawyer_specialty_x.dart';

/// Mounted under both the client and company shells — companies also
/// browse/book lawyers, so [routeBase] picks which role's details/booking
/// routes tapping a card should push (defaults to the client base so every
/// existing call site keeps behaving exactly as before).
class LawyersListScreen extends ConsumerStatefulWidget {
  const LawyersListScreen({super.key, this.routeBase = RoutePaths.clientBase});

  final String routeBase;

  @override
  ConsumerState<LawyersListScreen> createState() => _LawyersListScreenState();
}

class _LawyersListScreenState extends ConsumerState<LawyersListScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  LawyerSpecialty? _specialtyFilter;
  double? _minRatingFilter;
  LawyerAvailabilityWindow? _availabilityFilter;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  int get _activeFilterCount => [_minRatingFilter, _availabilityFilter].where((f) => f != null).length;

  List<LawyerProfile> _applyFilters(List<LawyerProfile> lawyers) {
    return lawyers.where((lawyer) {
      final matchesQuery = _query.isEmpty || lawyer.fullName.toLowerCase().contains(_query.toLowerCase());
      final matchesSpecialty = _specialtyFilter == null || lawyer.specialties.contains(_specialtyFilter);
      final matchesRating = _minRatingFilter == null || lawyer.rating >= _minRatingFilter!;
      final matchesAvailability = _availabilityFilter == null || lawyer.availabilityWindow == _availabilityFilter;
      return matchesQuery && matchesSpecialty && matchesRating && matchesAvailability;
    }).toList();
  }

  Future<void> _openFilters() async {
    final l10n = AppLocalizations.of(context)!;
    var minRating = _minRatingFilter;
    var availability = _availabilityFilter;

    await showAppBottomSheet<void>(
      context,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.lawyersFilterTitle, style: Theme.of(sheetContext).textTheme.titleMedium),
                const SizedBox(height: AppSpacing.md),
                Text(l10n.lawyersFilterRating, style: Theme.of(sheetContext).textTheme.labelLarge),
                const SizedBox(height: AppSpacing.xs),
                Wrap(
                  spacing: AppSpacing.xxs,
                  children: [
                    AppChip(label: l10n.contractsFilterAll, selected: minRating == null, onTap: () => setSheetState(() => minRating = null)),
                    AppChip(label: '4.5+', selected: minRating == 4.5, onTap: () => setSheetState(() => minRating = 4.5)),
                    AppChip(label: '4.0+', selected: minRating == 4.0, onTap: () => setSheetState(() => minRating = 4.0)),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Text(l10n.lawyersFilterAvailability, style: Theme.of(sheetContext).textTheme.labelLarge),
                const SizedBox(height: AppSpacing.xs),
                Wrap(
                  spacing: AppSpacing.xxs,
                  children: [
                    AppChip(
                      label: l10n.contractsFilterAll,
                      selected: availability == null,
                      onTap: () => setSheetState(() => availability = null),
                    ),
                    for (final window in LawyerAvailabilityWindow.values)
                      AppChip(
                        label: window.label(l10n),
                        selected: availability == window,
                        onTap: () => setSheetState(() => availability = window),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        label: l10n.commonReset,
                        variant: AppButtonVariant.outlined,
                        onPressed: () => setSheetState(() {
                          minRating = null;
                          availability = null;
                        }),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: AppButton(
                        label: l10n.lawyersFilterApply,
                        onPressed: () {
                          setState(() {
                            _minRatingFilter = minRating;
                            _availabilityFilter = availability;
                          });
                          Navigator.of(sheetContext).pop();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final lawyersState = ref.watch(lawyersControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navLawyers),
        actions: [
          IconButton(
            icon: Badge(
              isLabelVisible: _activeFilterCount > 0,
              label: Text('$_activeFilterCount'),
              child: const Icon(Icons.tune),
            ),
            tooltip: l10n.lawyersFilterTitle,
            onPressed: _openFilters,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.md, AppSpacing.xl, AppSpacing.sm),
              child: TextField(
                controller: _searchController,
                onChanged: (value) => setState(() => _query = value),
                decoration: InputDecoration(hintText: l10n.lawyersSearchHint, prefixIcon: const Icon(Icons.search)),
              ),
            ),
            // Specialty chips sit directly below search, matching the
            // reference — unlike rating/availability, which stay in the
            // filter sheet behind the tune icon.
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(AppSpacing.xl, 0, AppSpacing.xl, AppSpacing.sm),
              child: Row(
                children: [
                  AppChip(
                    label: l10n.contractsFilterAll,
                    selected: _specialtyFilter == null,
                    onTap: () => setState(() => _specialtyFilter = null),
                  ),
                  for (final specialty in LawyerSpecialty.values) ...[
                    const SizedBox(width: AppSpacing.xs),
                    AppChip(
                      label: specialty.label(l10n),
                      selected: _specialtyFilter == specialty,
                      onTap: () => setState(() => _specialtyFilter = specialty),
                    ),
                  ],
                ],
              ),
            ),
            Expanded(
              child: switch (lawyersState) {
                AsyncData(value: final lawyers) => Builder(
                  builder: (context) {
                    final filtered = _applyFilters(lawyers);
                    final isFiltering = _query.isNotEmpty || _activeFilterCount > 0 || _specialtyFilter != null;
                    if (filtered.isEmpty) {
                      return EmptyState(
                        icon: Icons.search_off_outlined,
                        title: isFiltering ? l10n.lawyersSearchEmptyTitle : l10n.lawyersEmptyTitle,
                        message: isFiltering ? l10n.lawyersSearchEmptyMessage : l10n.lawyersEmptyMessage,
                      );
                    }
                    return RefreshIndicator(
                      onRefresh: () => ref.read(lawyersControllerProvider.notifier).refresh(),
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(AppSpacing.xl, 0, AppSpacing.xl, AppSpacing.xl),
                        itemCount: filtered.length,
                        separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.sm),
                        itemBuilder: (context, index) {
                          final lawyer = filtered[index];
                          return LawyerCard(
                            lawyer: lawyer,
                            onTap: () => context.push(RoutePaths.lawyerDetailsFor(widget.routeBase, lawyer.id)),
                          );
                        },
                      ),
                    );
                  },
                ),
                AsyncError() => ErrorView(message: l10n.errorGeneric, onRetry: () => ref.read(lawyersControllerProvider.notifier).refresh()),
                _ => const LoadingView(),
              },
            ),
          ],
        ),
      ),
    );
  }
}
