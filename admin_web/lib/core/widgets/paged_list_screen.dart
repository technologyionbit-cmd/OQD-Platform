import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aqd_admin/core/errors/failure.dart';
import 'package:aqd_admin/core/localization/generated/app_localizations.dart';
import 'package:aqd_admin/core/models/paged_result.dart';
import 'package:aqd_admin/core/providers/core_providers.dart';
import 'package:aqd_admin/core/widgets/admin_data_table.dart';
import 'package:aqd_admin/core/widgets/filter_widgets.dart';
import 'package:aqd_admin/core/widgets/page_header.dart';

/// What the admin asked of a server-paged list: page, sort, search and any
/// number of dropdown filters (sent as plain query parameters).
class ListQuery {
  const ListQuery({required this.sort, this.page = 1, this.limit = 20, this.ascending = false, this.search = '', this.filters = const {}});

  final int page;
  final int limit;
  final String sort;
  final bool ascending;
  final String search;
  final Map<String, String> filters;

  ListQuery copyWith({int? page, int? limit, String? sort, bool? ascending, String? search, Map<String, String>? filters}) => ListQuery(
        page: page ?? this.page,
        limit: limit ?? this.limit,
        sort: sort ?? this.sort,
        ascending: ascending ?? this.ascending,
        search: search ?? this.search,
        filters: filters ?? this.filters,
      );

  bool get hasFilters => search.isNotEmpty || filters.isNotEmpty;

  Map<String, dynamic> toParams() => {
        'page': page,
        'limit': limit,
        'sort': sort,
        'order': ascending ? 'asc' : 'desc',
        if (search.isNotEmpty) 'q': search,
        ...filters,
      };
}

class ListQueryController extends Notifier<ListQuery> {
  ListQueryController(this.defaultSort, {this.defaultAscending = false});

  final String defaultSort;
  final bool defaultAscending;

  @override
  ListQuery build() => ListQuery(sort: defaultSort, ascending: defaultAscending);

  void setSearch(String value) => state = state.copyWith(search: value, page: 1);

  void setFilter(String key, String? value) {
    final next = {...state.filters};
    if (value == null) {
      next.remove(key);
    } else {
      next[key] = value;
    }
    state = state.copyWith(filters: next, page: 1);
  }

  void setLimit(int value) => state = state.copyWith(limit: value, page: 1);
  void sortBy(String key, {required bool ascending}) => state = state.copyWith(sort: key, ascending: ascending, page: 1);
  void setPage(int page) => state = state.copyWith(page: page);
  void clearFilters() => state = ListQuery(sort: state.sort, ascending: state.ascending, limit: state.limit);
}

NotifierProvider<ListQueryController, ListQuery> listQueryProvider(String defaultSort) => NotifierProvider<ListQueryController, ListQuery>(() => ListQueryController(defaultSort));

/// Loads one page of `GET [path]` for whatever [query] currently says.
FutureProvider<PagedResult<T>> pagedProvider<T>(
  String path,
  T Function(Map<String, dynamic> row) parse,
  NotifierProvider<ListQueryController, ListQuery> query,
) {
  return FutureProvider.autoDispose<PagedResult<T>>((ref) async {
    final params = ref.watch(query).toParams();
    try {
      final response = await ref.watch(apiClientProvider).dio.get<Map<String, dynamic>>(path, queryParameters: params);
      return PagedResult.fromJson(response.data!, parse);
    } on DioException catch (error) {
      throw mapToFailure(error);
    }
  });
}

/// One dropdown filter above a [PagedListScreen].
class FilterSpec {
  const FilterSpec({required this.key, required this.label, required this.options});

  final String key;
  final String Function(AppLocalizations l10n) label;
  final Map<String, String> Function(AppLocalizations l10n) options;
}

/// A whole read-only list page: header, search box, filters, sortable table
/// and pager. Each module supplies only its columns and filters.
class PagedListScreen<T> extends ConsumerWidget {
  const PagedListScreen({
    required this.title,
    required this.subtitle,
    required this.searchHint,
    required this.query,
    required this.page,
    required this.columns,
    super.key,
    this.filters = const [],
    this.actions = const [],
    this.onRowTap,
  });

  final String title;
  final String subtitle;
  final String searchHint;
  final NotifierProvider<ListQueryController, ListQuery> query;
  final FutureProvider<PagedResult<T>> page;
  final List<AdminColumn<T>> columns;
  final List<FilterSpec> filters;

  /// Buttons next to the title (e.g. "New").
  final List<Widget> actions;
  final ValueChanged<T>? onRowTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final q = ref.watch(query);
    final controller = ref.read(query.notifier);
    final result = ref.watch(page);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PageHeader(title: title, subtitle: subtitle, actions: actions),
        Expanded(
          child: SingleChildScrollView(
            child: AdminDataTable<T>(
              columns: columns,
              rows: result.value?.items ?? const [],
              page: q.page,
              limit: q.limit,
              total: result.value?.total ?? 0,
              isLoading: result.isLoading,
              error: result.hasError ? result.error : null,
              onRetry: () => ref.invalidate(page),
              sortKey: q.sort,
              ascending: q.ascending,
              onSort: controller.sortBy,
              onPageChanged: controller.setPage,
              onLimitChanged: controller.setLimit,
              onRowTap: onRowTap,
              filters: Wrap(
                spacing: 12,
                runSpacing: 12,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  SizedBox(
                    width: 340,
                    child: DebouncedSearchField(
                      key: ValueKey('search-${q.hasFilters}-${q.search.isEmpty}'),
                      initialValue: q.search,
                      hint: searchHint,
                      onChanged: controller.setSearch,
                    ),
                  ),
                  for (final f in filters)
                    FilterDropdown<String>(
                      label: f.label(l10n),
                      value: q.filters[f.key],
                      options: f.options(l10n),
                      onChanged: (v) => controller.setFilter(f.key, v),
                    ),
                  if (q.hasFilters)
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
