import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aqd_admin/core/models/paged_result.dart';
import 'package:aqd_admin/core/providers/core_providers.dart';
import 'package:aqd_admin/features/lawyers/data/lawyers_repository.dart';
import 'package:aqd_admin/features/lawyers/domain/lawyer.dart';

final lawyersRepositoryProvider = Provider<LawyersRepository>((ref) => LawyersRepository(ref.watch(apiClientProvider).dio));

/// The admin's current search, filter, sort and page. Any change other
/// than paging goes back to page 1.
class LawyersQueryController extends Notifier<LawyersQuery> {
  @override
  LawyersQuery build() => const LawyersQuery();

  void _filter(LawyersQuery next) => state = next.copyWith(page: 1);

  void setSearch(String value) => _filter(state.copyWith(search: value));
  void setVerification(String? value) => _filter(state.copyWith(verification: () => value));
  void setLimit(int value) => _filter(state.copyWith(limit: value));
  void sortBy(String key, {required bool ascending}) => _filter(state.copyWith(sort: key, ascending: ascending));
  void clearFilters() => _filter(LawyersQuery(limit: state.limit, sort: state.sort, ascending: state.ascending));
  void setPage(int page) => state = state.copyWith(page: page);
}

final lawyersQueryProvider = NotifierProvider<LawyersQueryController, LawyersQuery>(LawyersQueryController.new);

final lawyersPageProvider = FutureProvider.autoDispose<PagedResult<Lawyer>>(
  (ref) => ref.watch(lawyersRepositoryProvider).list(ref.watch(lawyersQueryProvider)),
);
