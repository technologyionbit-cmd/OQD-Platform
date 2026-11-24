import 'dart:typed_data';

import 'package:aqd_admin/core/models/paged_result.dart';
import 'package:aqd_admin/features/users/domain/managed_user.dart';
import 'package:aqd_admin/features/users/domain/users_query.dart';

/// Every method throws a `Failure` on error.
abstract interface class UsersRepository {
  Future<PagedResult<ManagedUser>> list(UsersQuery query);

  Future<UserDetail> detail(String id);

  Future<void> suspend(String id, {required String reason});

  Future<void> activate(String id);

  Future<int> revokeSessions(String id);

  Future<void> resetPassword(String id);

  Future<void> softDelete(String id, {required String reason});

  Future<void> restore(String id);

  /// [action]: `suspend` | `activate` | `revokeSessions`.
  Future<BulkResult> bulk({required String action, required List<String> ids, String? reason});

  /// CSV bytes of everything matching [query] (all pages).
  Future<Uint8List> exportCsv(UsersQuery query);
}
