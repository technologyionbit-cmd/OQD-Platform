import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:aqd_ionbit/core/localization/generated/app_localizations.dart';
import 'package:aqd_ionbit/core/routing/route_paths.dart';
import 'package:aqd_ionbit/core/theme/app_spacing.dart';
import 'package:aqd_ionbit/core/widgets/app_chip.dart';
import 'package:aqd_ionbit/core/widgets/empty_state.dart';
import 'package:aqd_ionbit/core/widgets/error_view.dart';
import 'package:aqd_ionbit/core/widgets/loading_view.dart';
import 'package:aqd_ionbit/features/contracts/domain/entities/contract.dart';
import 'package:aqd_ionbit/features/contracts/domain/entities/contract_status.dart';
import 'package:aqd_ionbit/features/contracts/presentation/providers/contracts_controller.dart';
import 'package:aqd_ionbit/features/contracts/presentation/widgets/contract_card.dart';
import 'package:aqd_ionbit/features/contracts/presentation/widgets/contract_status_x.dart';

class ContractsListScreen extends ConsumerStatefulWidget {
  const ContractsListScreen({super.key});

  @override
  ConsumerState<ContractsListScreen> createState() => _ContractsListScreenState();
}

class _ContractsListScreenState extends ConsumerState<ContractsListScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  ContractStatus? _statusFilter;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Contract> _applyFilters(List<Contract> contracts, AppLocalizations l10n) {
    return contracts.where((contract) {
      final matchesStatus = _statusFilter == null || contract.status == _statusFilter;
      final matchesQuery = _query.isEmpty || contract.title.toLowerCase().contains(_query.toLowerCase());
      return matchesStatus && matchesQuery;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final contractsState = ref.watch(contractsControllerProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.clientHomeMyContracts)),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(RoutePaths.clientContractsNew),
        child: const Icon(Icons.add),
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
                decoration: InputDecoration(hintText: l10n.contractsSearchHint, prefixIcon: const Icon(Icons.search)),
              ),
            ),
            SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                children: [
                  Padding(
                    padding: const EdgeInsetsDirectional.only(end: AppSpacing.xs),
                    child: AppChip(label: l10n.contractsFilterAll, selected: _statusFilter == null, onTap: () => setState(() => _statusFilter = null)),
                  ),
                  for (final status in ContractStatus.values)
                    Padding(
                      padding: const EdgeInsetsDirectional.only(end: AppSpacing.xs),
                      child: AppChip(
                        label: status.label(l10n),
                        selected: _statusFilter == status,
                        onTap: () => setState(() => _statusFilter = status),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Expanded(
              child: switch (contractsState) {
                AsyncData(value: final contracts) => Builder(
                  builder: (context) {
                    final filtered = _applyFilters(contracts, l10n);
                    final isFiltering = _query.isNotEmpty || _statusFilter != null;
                    if (filtered.isEmpty && isFiltering) {
                      return EmptyState(
                        icon: Icons.search_off_outlined,
                        title: l10n.contractsSearchEmptyTitle,
                        message: l10n.contractsSearchEmptyMessage,
                      );
                    }
                    if (filtered.isEmpty) {
                      return EmptyState(
                        icon: Icons.description_outlined,
                        title: l10n.clientHomeNoContractsTitle,
                        message: l10n.clientHomeNoContractsMessage,
                      );
                    }
                    return RefreshIndicator(
                      onRefresh: () => ref.read(contractsControllerProvider.notifier).refresh(),
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(AppSpacing.xl, 0, AppSpacing.xl, AppSpacing.xl),
                        itemCount: filtered.length,
                        separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.sm),
                        itemBuilder: (context, index) {
                          final contract = filtered[index];
                          return ContractCard(
                            contract: contract,
                            onTap: () => context.push(RoutePaths.clientContractDetails(contract.id)),
                          );
                        },
                      ),
                    );
                  },
                ),
                AsyncError() => ErrorView(
                  message: l10n.errorGeneric,
                  onRetry: () => ref.read(contractsControllerProvider.notifier).refresh(),
                ),
                _ => const LoadingView(),
              },
            ),
          ],
        ),
      ),
    );
  }
}
