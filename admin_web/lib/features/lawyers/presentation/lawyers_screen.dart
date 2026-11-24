import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aqd_admin/core/localization/generated/app_localizations.dart';
import 'package:aqd_admin/core/utils/formatters.dart';
import 'package:aqd_admin/core/widgets/admin_data_table.dart';
import 'package:aqd_admin/core/widgets/filter_widgets.dart';
import 'package:aqd_admin/core/widgets/page_header.dart';
import 'package:aqd_admin/core/widgets/status_chip.dart';
import 'package:aqd_admin/features/lawyers/domain/lawyer.dart';
import 'package:aqd_admin/features/lawyers/presentation/lawyer_dialog.dart';
import 'package:aqd_admin/features/lawyers/presentation/providers/lawyers_providers.dart';
import 'package:aqd_admin/features/lawyers/presentation/widgets/lawyer_labels.dart';
import 'package:aqd_admin/features/users/presentation/widgets/user_labels.dart';

class LawyersScreen extends ConsumerWidget {
  const LawyersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final query = ref.watch(lawyersQueryProvider);
    final controller = ref.read(lawyersQueryProvider.notifier);
    final page = ref.watch(lawyersPageProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PageHeader(title: l10n.navLawyers, subtitle: l10n.lawyersSubtitle),
        Expanded(
          child: SingleChildScrollView(
            child: AdminDataTable<Lawyer>(
              columns: [
                AdminColumn(
                  label: l10n.colName,
                  sortKey: 'fullName',
                  cell: (l) => ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 240),
                    child: Text(l.fullName, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
                AdminColumn(label: l10n.colBarLicense, cell: (l) => Text(l.barLicenseNumber, textDirection: TextDirection.ltr)),
                AdminColumn(label: l10n.colEmail, cell: (l) => Text(l.email)),
                AdminColumn(label: l10n.colPhone, cell: (l) => Text(l.phone ?? '-', textDirection: TextDirection.ltr)),
                AdminColumn(
                  label: l10n.colSpecialties,
                  cell: (l) => ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 220),
                    child: Text(l.specialties.map((s) => specialtyLabel(l10n, s)).join('، '), overflow: TextOverflow.ellipsis),
                  ),
                ),
                AdminColumn(label: l10n.colExperience, sortKey: 'yearsOfExperience', cell: (l) => Text(l10n.yearsValue(l.yearsOfExperience))),
                AdminColumn(label: l10n.colRating, sortKey: 'rating', cell: (l) => Text(l.reviewsCount == 0 ? '-' : '${l.rating.toStringAsFixed(1)} (${l.reviewsCount})')),
                AdminColumn(label: l10n.colConsultations, numeric: true, cell: (l) => Text('${l.consultationsCount}')),
                AdminColumn(
                  label: l10n.colVerification,
                  cell: (l) => StatusChip(label: verificationLabel(l10n, l.verificationStatus), tone: verificationTone(l.verificationStatus)),
                ),
                AdminColumn(label: l10n.colCreated, sortKey: 'createdAt', cell: (l) => Text(formatDate(context, l.createdAt))),
              ],
              rows: page.value?.items ?? const [],
              page: query.page,
              limit: query.limit,
              total: page.value?.total ?? 0,
              isLoading: page.isLoading,
              error: page.hasError ? page.error : null,
              onRetry: () => ref.invalidate(lawyersPageProvider),
              sortKey: query.sort,
              ascending: query.ascending,
              onSort: controller.sortBy,
              onPageChanged: controller.setPage,
              onLimitChanged: controller.setLimit,
              onRowTap: (l) => showDialog<void>(context: context, builder: (_) => LawyerDialog(id: l.id)),
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
                      hint: l10n.searchLawyersHint,
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
