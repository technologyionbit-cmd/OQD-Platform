import 'dart:convert';
import 'dart:typed_data';

import 'package:aqd_admin/core/errors/failure.dart';
import 'package:aqd_admin/core/models/paged_result.dart';
import 'package:aqd_admin/features/audit/data/audit_repository.dart';
import 'package:aqd_admin/features/audit/domain/audit_entry.dart';
import 'package:aqd_admin/features/audit/domain/audit_query.dart';
import 'package:aqd_admin/features/users/domain/managed_user.dart';
import 'package:aqd_admin/features/users/domain/users_query.dart';
import 'package:aqd_admin/features/users/domain/users_repository.dart';

ManagedUser user(String id, {String role = 'client', String status = 'active', DateTime? deletedAt, String? name}) => ManagedUser(
      id: id,
      fullName: name ?? 'User $id',
      email: '$id@x.com',
      phone: '+96279000000$id',
      role: role,
      status: status,
      createdAt: DateTime.utc(2026),
      deletedAt: deletedAt,
    );

UserDetail detailOf(
  String id, {
  String role = 'client',
  String status = 'active',
  DateTime? deletedAt,
  List<SessionInfo> sessions = const [],
}) =>
    UserDetail(
      id: id,
      fullName: 'User $id',
      email: '$id@x.com',
      phone: '+96279000000$id',
      role: role,
      status: status,
      createdAt: DateTime.utc(2026),
      deletedAt: deletedAt,
      sessions: sessions,
    );

/// A users repository that records what it was asked and answers from lists.
class FakeUsersRepository implements UsersRepository {
  FakeUsersRepository({List<ManagedUser>? users, UserDetail? detail, this.failWith}) : users = users ?? [user('1'), user('2')], detailResult = detail;

  List<ManagedUser> users;
  UserDetail? detailResult;
  Failure? failWith;

  final List<UsersQuery> queries = [];
  final List<String> calls = [];
  Map<String, Object?>? lastBulk;
  BulkResult bulkResult = const BulkResult(succeeded: [], skipped: []);

  @override
  Future<PagedResult<ManagedUser>> list(UsersQuery query) async {
    queries.add(query);
    if (failWith != null) throw failWith!;
    return PagedResult(items: users, page: query.page, limit: query.limit, total: users.length, totalPages: 1);
  }

  @override
  Future<UserDetail> detail(String id) async {
    if (failWith != null) throw failWith!;
    return detailResult!;
  }

  @override
  Future<void> suspend(String id, {required String reason}) async => calls.add('suspend:$id:$reason');

  @override
  Future<void> activate(String id) async => calls.add('activate:$id');

  @override
  Future<int> revokeSessions(String id) async {
    calls.add('revoke:$id');
    return 1;
  }

  @override
  Future<void> resetPassword(String id) async => calls.add('reset:$id');

  @override
  Future<void> softDelete(String id, {required String reason}) async => calls.add('delete:$id:$reason');

  @override
  Future<void> restore(String id) async => calls.add('restore:$id');

  @override
  Future<BulkResult> bulk({required String action, required List<String> ids, String? reason}) async {
    lastBulk = {'action': action, 'ids': ids, 'reason': reason};
    return bulkResult;
  }

  @override
  Future<Uint8List> exportCsv(UsersQuery query) async {
    calls.add('export');
    queries.add(query);
    return Uint8List.fromList(utf8.encode('id,name\n1,x'));
  }
}

class FakeAuditRepository implements AuditRepository {
  FakeAuditRepository({List<AuditEntry>? entries, AuditDetail? detail}) : entries = entries ?? [], detailResult = detail;

  List<AuditEntry> entries;
  AuditDetail? detailResult;
  final List<AuditQuery> queries = [];

  @override
  Future<PagedResult<AuditEntry>> list(AuditQuery query) async {
    queries.add(query);
    return PagedResult(items: entries, page: query.page, limit: query.limit, total: entries.length, totalPages: 1);
  }

  @override
  Future<AuditDetail> detail(String id) async => detailResult!;
}
