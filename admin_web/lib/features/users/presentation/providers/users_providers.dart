import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aqd_admin/core/models/paged_result.dart';
import 'package:aqd_admin/core/providers/core_providers.dart';
import 'package:aqd_admin/features/users/data/users_repository_impl.dart';
import 'package:aqd_admin/features/users/domain/managed_user.dart';
import 'package:aqd_admin/features/users/domain/users_query.dart';
import 'package:aqd_admin/features/users/domain/users_repository.dart';

final usersRepositoryProvider = Provider<UsersRepository>(
  (ref) => UsersRepositoryImpl(ref.watch(apiClientProvider).dio),
);

/// Rows ticked in the table (ids), across the current page only.
class SelectedUsers extends Notifier<Set<String>> {
  @override
  Set<String> build() => const {};

  // ignore: use_setters_to_change_properties
  void set(Set<String> ids) => state = ids;

  void clear() => state = const {};
}

final selectedUsersProvider = NotifierProvider<SelectedUsers, Set<String>>(SelectedUsers.new);

/// The admin's current search, filters, sort and page. Any change other
/// than paging goes back to page 1, and ticked rows are dropped, since
/// they may not be in the new result.
class UsersQueryController extends Notifier<UsersQuery> {
  @override
  UsersQuery build() => const UsersQuery();

  void _filter(UsersQuery next) {
    ref.read(selectedUsersProvider.notifier).clear();
    state = next.copyWith(page: 1);
  }

  void setSearch(String value) => _filter(state.copyWith(search: value));
  void setRole(String? value) => _filter(state.copyWith(role: () => value));
  void setStatus(String? value) => _filter(state.copyWith(status: () => value));
  void setDeleted(String value) => _filter(state.copyWith(deleted: value));
  void setFrom(DateTime? value) => _filter(state.copyWith(createdFrom: () => value));
  void setTo(DateTime? value) => _filter(state.copyWith(createdTo: () => value));
  void setLimit(int value) => _filter(state.copyWith(limit: value));
  void sortBy(String key, {required bool ascending}) => _filter(state.copyWith(sort: key, ascending: ascending));
  void clearFilters() => _filter(UsersQuery(limit: state.limit, sort: state.sort, ascending: state.ascending));

  void setPage(int page) {
    ref.read(selectedUsersProvider.notifier).clear();
    state = state.copyWith(page: page);
  }
}

final usersQueryProvider = NotifierProvider<UsersQueryController, UsersQuery>(UsersQueryController.new);

final usersPageProvider = FutureProvider.autoDispose<PagedResult<ManagedUser>>(
  (ref) => ref.watch(usersRepositoryProvider).list(ref.watch(usersQueryProvider)),
);

final userDetailProvider = FutureProvider.autoDispose.family<UserDetail, String>(
  (ref, id) => ref.watch(usersRepositoryProvider).detail(id),
);
