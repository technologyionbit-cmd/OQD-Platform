import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aqd_admin/core/localization/generated/app_localizations.dart';
import 'package:aqd_admin/core/utils/formatters.dart';
import 'package:aqd_admin/core/widgets/admin_data_table.dart';
import 'package:aqd_admin/core/widgets/filter_widgets.dart';
import 'package:aqd_admin/core/widgets/page_header.dart';
import 'package:aqd_admin/core/widgets/status_chip.dart';
import 'package:aqd_admin/features/audit/domain/audit_entry.dart';
import 'package:aqd_admin/features/audit/presentation/providers/audit_providers.dart';
import 'package:aqd_admin/features/audit/presentation/widgets/audit_detail_dialog.dart';

/// Entity types the admin API records today; more appear as modules land.
const _entityTypes = ['user', 'lawyerProfile'];

class AuditScreen extends ConsumerWidget {
  const AuditScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final query = ref.watch(auditQueryProvider);
    final controller = ref.read(auditQueryProvider.notifier);
    final page = ref.watch(auditPageProvider);

    final filters = Wrap(
      spacing: 12,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        SizedBox(
          width: 320,
          child: DebouncedSearchField(
            key: ValueKey('audit-search-${query.hasFilters}-${query.search.isEmpty}'),
            initialValue: query.search,
            hint: l10n.auditSearchHint,
            onChanged: controller.setSearch,
          ),
        ),
        SizedBox(
          width: 220,
          child: DebouncedSearchField(
            key: ValueKey('audit-action-${query.hasFilters}-${query.action.isEmpty}'),
            initialValue: query.action,
            hint: l10n.filterAction,
            onChanged: controller.setAction,
          ),
        ),
        FilterDropdown<String>(
          label: l10n.filterEntityType,
          value: query.entityType,
          options: {for (final type in _entityTypes) type: type},
          onChanged: controller.setEntityType,
        ),
        FilterDropdown<String>(
          label: l10n.filterOutcome,
          value: query.outcome,
          options: {'success': l10n.outcomeSuccess, 'failure': l10n.outcomeFailure},
          onChanged: controller.setOutcome,
        ),
        DateFilterButton(label: l10n.dateFrom, value: query.from, onChanged: controller.setFrom),
        DateFilterButton(label: l10n.dateTo, value: query.to, onChanged: controller.setTo),
        if (query.hasFilters) TextButton.icon(onPressed: controller.clearFilters, icon: const Icon(Icons.filter_alt_off_outlined, size: 18), label: Text(l10n.clearFilters)),
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PageHeader(title: l10n.navAudit, subtitle: l10n.auditSubtitle),
        Expanded(
          child: SingleChildScrollView(
            child: AdminDataTable<AuditEntry>(
              columns: [
                AdminColumn(label: l10n.colWhen, sortKey: 'createdAt', cell: (e) => Text(formatDateTime(context, e.createdAt))),
                AdminColumn(label: l10n.colActor, cell: (e) => Text(e.actor?.fullName ?? '-')),
                AdminColumn(label: l10n.colAction, cell: (e) => Text(e.action, textDirection: TextDirection.ltr)),
                AdminColumn(
                  label: l10n.colEntity,
                  cell: (e) => Text(
                    [e.entityType, if (e.entityId != null) e.entityId!.substring(0, e.entityId!.length < 8 ? e.entityId!.length : 8)].whereType<String>().join(' · '),
                    textDirection: TextDirection.ltr,
                  ),
                ),
                AdminColumn(
                  label: l10n.colOutcome,
                  cell: (e) => StatusChip(label: '${e.statusCode}', tone: e.succeeded ? StatusTone.success : StatusTone.error),
                ),
                AdminColumn(label: l10n.colIp, cell: (e) => Text(e.ipAddress ?? '-', textDirection: TextDirection.ltr)),
              ],
              rows: page.value?.items ?? const [],
              page: query.page,
              limit: query.limit,
              total: page.value?.total ?? 0,
              isLoading: page.isLoading,
              error: page.hasError ? page.error : null,
              onRetry: () => ref.invalidate(auditPageProvider),
              sortKey: 'createdAt',
              ascending: query.ascending,
              onSort: (_, {required ascending}) => controller.setOldestFirst(ascending: ascending),
              onPageChanged: controller.setPage,
              onLimitChanged: controller.setLimit,
              filters: filters,
              onRowTap: (e) => showAuditDetail(context, e.id),
            ),
          ),
        ),
      ],
    );
  }
}
