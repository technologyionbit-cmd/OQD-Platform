import 'package:flutter/material.dart';

import 'package:aqd_admin/core/localization/generated/app_localizations.dart';
import 'package:aqd_admin/core/widgets/state_views.dart';

/// One column of an [AdminDataTable].
class AdminColumn<T> {
  const AdminColumn({
    required this.label,
    required this.cell,
    this.sortKey,
    this.numeric = false,
  });

  final String label;
  final Widget Function(T row) cell;

  /// Sent to the server as `sort=`. Null means the column is not sortable.
  final String? sortKey;
  final bool numeric;
}

/// A server-driven table: the server pages, sorts and filters, the table
/// shows one page and reports what the admin asked for.
///
/// It owns the loading / empty / error states, the pager, the optional row
/// selection with a bulk-actions bar, and a [filters] slot above the rows.
class AdminDataTable<T> extends StatelessWidget {
  const AdminDataTable({
    required this.columns,
    required this.rows,
    required this.page,
    required this.limit,
    required this.total,
    required this.onPageChanged,
    required this.onLimitChanged,
    super.key,
    this.isLoading = false,
    this.error,
    this.onRetry,
    this.sortKey,
    this.ascending = false,
    this.onSort,
    this.filters,
    this.idOf,
    this.selectedIds = const {},
    this.onSelectionChanged,
    this.bulkActions = const [],
    this.onRowTap,
    this.limitOptions = const [10, 20, 50, 100],
  });

  final List<AdminColumn<T>> columns;
  final List<T> rows;
  final int page;
  final int limit;
  final int total;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<int> onLimitChanged;

  final bool isLoading;
  final Object? error;
  final VoidCallback? onRetry;

  final String? sortKey;
  final bool ascending;
  final void Function(String sortKey, {required bool ascending})? onSort;

  final Widget? filters;

  /// Row identity. Selection is enabled when this and [onSelectionChanged]
  /// are both given.
  final String Function(T row)? idOf;
  final Set<String> selectedIds;
  final ValueChanged<Set<String>>? onSelectionChanged;

  /// Shown instead of the filters while rows are selected.
  final List<Widget> bulkActions;

  final ValueChanged<T>? onRowTap;
  final List<int> limitOptions;

  bool get _selectable => idOf != null && onSelectionChanged != null;
  int get _totalPages => total == 0 ? 1 : (total / limit).ceil();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (selectedIds.isNotEmpty && _selectable)
            _BulkBar(count: selectedIds.length, actions: bulkActions, onClear: () => onSelectionChanged!(const {}))
          else if (filters != null)
            Padding(padding: const EdgeInsets.all(16), child: filters),
          const Divider(),
          _body(context, l10n),
          const Divider(),
          _Pager(
            page: page,
            totalPages: _totalPages,
            total: total,
            limit: limit,
            limitOptions: limitOptions,
            onPageChanged: onPageChanged,
            onLimitChanged: onLimitChanged,
          ),
        ],
      ),
    );
  }

  Widget _body(BuildContext context, AppLocalizations l10n) {
    if (error != null && rows.isEmpty) {
      return SizedBox(height: 260, child: ErrorView(error: error!, onRetry: onRetry));
    }
    if (isLoading && rows.isEmpty) return const SizedBox(height: 260, child: LoadingView());
    if (rows.isEmpty) return const SizedBox(height: 260, child: EmptyView());

    final sortIndex = columns.indexWhere((c) => c.sortKey != null && c.sortKey == sortKey);
    final allSelected = _selectable && rows.every((r) => selectedIds.contains(idOf!(r)));

    return Stack(
      children: [
        LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: constraints.maxWidth),
              child: DataTable(
                showCheckboxColumn: _selectable,
                sortColumnIndex: sortIndex < 0 ? null : sortIndex,
                sortAscending: ascending,
                onSelectAll: _selectable
                    ? (checked) => onSelectionChanged!(
                          checked ?? !allSelected ? {...selectedIds, for (final r in rows) idOf!(r)} : {...selectedIds}..removeAll(rows.map(idOf!)),
                        )
                    : null,
                columns: [
                  for (final column in columns)
                    DataColumn(
                      label: Text(column.label),
                      numeric: column.numeric,
                      onSort: column.sortKey == null || onSort == null
                          ? null
                          : (_, asc) => onSort!(column.sortKey!, ascending: asc),
                    ),
                ],
                rows: [
                  for (final row in rows)
                    DataRow(
                      selected: _selectable && selectedIds.contains(idOf!(row)),
                      onSelectChanged: _selectable
                          ? (checked) {
                              final id = idOf!(row);
                              final next = {...selectedIds};
                              (checked ?? false) ? next.add(id) : next.remove(id);
                              onSelectionChanged!(next);
                            }
                          : null,
                      onLongPress: onRowTap == null ? null : () => onRowTap!(row),
                      cells: [
                        for (final column in columns)
                          DataCell(column.cell(row), onTap: onRowTap == null ? null : () => onRowTap!(row)),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
        if (isLoading) const Positioned(left: 0, right: 0, top: 0, child: LinearProgressIndicator(minHeight: 2)),
      ],
    );
  }
}

class _BulkBar extends StatelessWidget {
  const _BulkBar({required this.count, required this.actions, required this.onClear});

  final int count;
  final List<Widget> actions;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Container(
      color: scheme.primary.withValues(alpha: 0.08),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Text(l10n.selectedCount(count), style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(width: 16),
          Expanded(child: Wrap(spacing: 8, runSpacing: 8, children: actions)),
          TextButton(onPressed: onClear, child: Text(l10n.clearSelection)),
        ],
      ),
    );
  }
}

class _Pager extends StatelessWidget {
  const _Pager({
    required this.page,
    required this.totalPages,
    required this.total,
    required this.limit,
    required this.limitOptions,
    required this.onPageChanged,
    required this.onLimitChanged,
  });

  final int page;
  final int totalPages;
  final int total;
  final int limit;
  final List<int> limitOptions;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<int> onLimitChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        alignment: WrapAlignment.spaceBetween,
        spacing: 16,
        runSpacing: 4,
        children: [
          Text(l10n.totalRows(total)),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.rowsPerPage),
              const SizedBox(width: 8),
              DropdownButton<int>(
                value: limitOptions.contains(limit) ? limit : null,
                underline: const SizedBox.shrink(),
                items: [for (final o in limitOptions) DropdownMenuItem(value: o, child: Text('$o'))],
                onChanged: (value) {
                  if (value != null) onLimitChanged(value);
                },
              ),
              const SizedBox(width: 16),
              IconButton(
                tooltip: l10n.previousPage,
                onPressed: page > 1 ? () => onPageChanged(page - 1) : null,
                icon: const Icon(Icons.chevron_left),
              ),
              Text(l10n.pageOfTotal(page, totalPages)),
              IconButton(
                tooltip: l10n.nextPage,
                onPressed: page < totalPages ? () => onPageChanged(page + 1) : null,
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
