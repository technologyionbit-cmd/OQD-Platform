import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aqd_admin/core/localization/generated/app_localizations.dart';
import 'package:aqd_admin/features/auth/presentation/providers/access.dart';
import 'package:aqd_admin/core/utils/formatters.dart';
import 'package:aqd_admin/core/widgets/admin_data_table.dart';
import 'package:aqd_admin/core/widgets/confirm_dialog.dart';
import 'package:aqd_admin/core/widgets/filter_widgets.dart';
import 'package:aqd_admin/core/widgets/page_header.dart';
import 'package:aqd_admin/core/widgets/reason_dialog.dart';
import 'package:aqd_admin/core/widgets/snacks.dart';
import 'package:aqd_admin/core/widgets/status_chip.dart';
import 'package:aqd_admin/features/companies/domain/company.dart';
import 'package:aqd_admin/features/companies/presentation/providers/companies_providers.dart';
import 'package:aqd_admin/features/users/presentation/widgets/user_labels.dart';

class CompaniesScreen extends ConsumerWidget {
  const CompaniesScreen({super.key});

  Future<void> _decide(BuildContext context, WidgetRef ref, Company company, {required bool approve}) async {
    final l10n = AppLocalizations.of(context);
    String? reason;
    if (approve) {
      final ok = await showConfirmDialog(context, title: l10n.companyApproveTitle, message: l10n.companyApproveBody(company.name), confirmLabel: l10n.verifApprove);
      if (!ok) return;
    } else {
      reason = await showReasonDialog(context, title: l10n.companyRejectTitle, message: l10n.companyRejectBody(company.name), confirmLabel: l10n.verifReject);
      if (reason == null) return;
    }
    if (!context.mounted) return;
    try {
      final repo = ref.read(companiesRepositoryProvider);
      if (approve) {
        await repo.verify(company.id);
      } else {
        await repo.reject(company.id, reason: reason!);
      }
      ref.invalidate(companiesPageProvider);
      if (context.mounted) showSuccessSnack(context, approve ? l10n.companyApprovedDone : l10n.companyRejectedDone);
    } on Object catch (error) {
      if (context.mounted) showFailureSnack(context, error);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final query = ref.watch(companiesQueryProvider);
    final controller = ref.read(companiesQueryProvider.notifier);
    final page = ref.watch(companiesPageProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PageHeader(title: l10n.navCompanies, subtitle: l10n.companiesSubtitle),
        Expanded(
          child: SingleChildScrollView(
            child: AdminDataTable<Company>(
              columns: [
                AdminColumn(
                  label: l10n.colCompany,
                  sortKey: 'name',
                  cell: (c) => ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 240),
                    child: Text(c.name, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
                AdminColumn(label: l10n.colRegistration, cell: (c) => Text(c.registrationNumber, textDirection: TextDirection.ltr)),
                AdminColumn(label: l10n.colOwner, cell: (c) => Text(c.ownerName)),
                AdminColumn(label: l10n.colEmail, cell: (c) => Text(c.ownerEmail)),
                AdminColumn(label: l10n.colPhone, cell: (c) => Text(c.ownerPhone ?? '-', textDirection: TextDirection.ltr)),
                AdminColumn(label: l10n.colMembers, numeric: true, cell: (c) => Text('${c.membersCount}')),
                AdminColumn(label: l10n.colVerification, cell: (c) => StatusChip(label: verificationLabel(l10n, c.verificationStatus), tone: verificationTone(c.verificationStatus))),
                AdminColumn(label: l10n.colCreated, sortKey: 'createdAt', cell: (c) => Text(formatDate(context, c.createdAt))),
                AdminColumn(
                  label: '',
                  cell: (c) => c.canDecide && canManage(ref, 'companies')
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              tooltip: l10n.verifApprove,
                              color: Colors.green.shade700,
                              icon: const Icon(Icons.check_circle_outline),
                              onPressed: () => _decide(context, ref, c, approve: true),
                            ),
                            IconButton(
                              tooltip: l10n.verifReject,
                              color: Theme.of(context).colorScheme.error,
                              icon: const Icon(Icons.cancel_outlined),
                              onPressed: () => _decide(context, ref, c, approve: false),
                            ),
                          ],
                        )
                      : const SizedBox.shrink(),
                ),
              ],
              rows: page.value?.items ?? const [],
              page: query.page,
              limit: query.limit,
              total: page.value?.total ?? 0,
              isLoading: page.isLoading,
              error: page.hasError ? page.error : null,
              onRetry: () => ref.invalidate(companiesPageProvider),
              sortKey: query.sort,
              ascending: query.ascending,
              onSort: controller.sortBy,
              onPageChanged: controller.setPage,
              onLimitChanged: controller.setLimit,
              filters: Wrap(
                spacing: 12,
                runSpacing: 12,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  SizedBox(
                    width: 360,
                    child: DebouncedSearchField(
                      key: ValueKey('search-${query.hasFilters}-${query.search.isEmpty}'),
                      initialValue: query.search,
                      hint: l10n.searchCompaniesHint,
                      onChanged: controller.setSearch,
                    ),
                  ),
                  FilterDropdown<String>(
                    label: l10n.colVerification,
                    value: query.verification,
                    options: {for (final s in ['unverified', 'pending', 'verified', 'rejected']) s: verificationLabel(l10n, s)},
                    onChanged: controller.setVerification,
                  ),
                  if (query.hasFilters)
                    TextButton.icon(onPressed: controller.clearFilters, icon: const Icon(Icons.filter_alt_off_outlined, size: 18), label: Text(l10n.clearFilters)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
