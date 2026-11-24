import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aqd_admin/core/models/paged_result.dart';
import 'package:aqd_admin/core/providers/core_providers.dart';
import 'package:aqd_admin/features/audit/data/audit_repository.dart';
import 'package:aqd_admin/features/audit/domain/audit_entry.dart';
import 'package:aqd_admin/features/audit/domain/audit_query.dart';

final auditRepositoryProvider = Provider<AuditRepository>(
  (ref) => AuditRepositoryImpl(ref.watch(apiClientProvider).dio),
);

class AuditQueryController extends Notifier<AuditQuery> {
  @override
  AuditQuery build() => const AuditQuery();

  void _filter(AuditQuery next) => state = next.copyWith(page: 1);

  void setSearch(String value) => _filter(state.copyWith(search: value));
  void setAction(String value) => _filter(state.copyWith(action: value));
  void setEntityType(String? value) => _filter(state.copyWith(entityType: () => value));
  void setOutcome(String? value) => _filter(state.copyWith(outcome: () => value));
  void setFrom(DateTime? value) => _filter(state.copyWith(from: () => value));
  void setTo(DateTime? value) => _filter(state.copyWith(to: () => value));
  void setLimit(int value) => _filter(state.copyWith(limit: value));
  void setOldestFirst({required bool ascending}) => _filter(state.copyWith(ascending: ascending));
  void clearFilters() => state = AuditQuery(limit: state.limit, ascending: state.ascending);
  void setPage(int page) => state = state.copyWith(page: page);
}

final auditQueryProvider = NotifierProvider<AuditQueryController, AuditQuery>(AuditQueryController.new);

final auditPageProvider = FutureProvider.autoDispose<PagedResult<AuditEntry>>(
  (ref) => ref.watch(auditRepositoryProvider).list(ref.watch(auditQueryProvider)),
);

final auditDetailProvider = FutureProvider.autoDispose.family<AuditDetail, String>(
  (ref, id) => ref.watch(auditRepositoryProvider).detail(id),
);
