import 'package:dio/dio.dart';

import 'package:aqd_admin/core/errors/failure.dart';
import 'package:aqd_admin/core/models/paged_result.dart';
import 'package:aqd_admin/features/audit/domain/audit_entry.dart';
import 'package:aqd_admin/features/audit/domain/audit_query.dart';

/// Read-only access to the audit trail. Throws a `Failure` on error.
abstract interface class AuditRepository {
  Future<PagedResult<AuditEntry>> list(AuditQuery query);

  Future<AuditDetail> detail(String id);
}

class AuditRepositoryImpl implements AuditRepository {
  AuditRepositoryImpl(this._dio);

  final Dio _dio;

  @override
  Future<PagedResult<AuditEntry>> list(AuditQuery query) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/admin/audit-logs', queryParameters: query.toParams());
      return PagedResult.fromJson(response.data!, AuditEntry.fromJson);
    } on DioException catch (error) {
      throw mapToFailure(error);
    }
  }

  @override
  Future<AuditDetail> detail(String id) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/admin/audit-logs/$id');
      return AuditDetail.fromJson(response.data!['data'] as Map<String, dynamic>);
    } on DioException catch (error) {
      throw mapToFailure(error);
    }
  }
}
