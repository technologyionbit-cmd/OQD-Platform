import 'dart:typed_data';

import 'package:dio/dio.dart';

import 'package:aqd_admin/core/errors/failure.dart';
import 'package:aqd_admin/core/models/paged_result.dart';
import 'package:aqd_admin/features/users/domain/managed_user.dart';
import 'package:aqd_admin/features/users/domain/users_query.dart';
import 'package:aqd_admin/features/users/domain/users_repository.dart';

class UsersRepositoryImpl implements UsersRepository {
  UsersRepositoryImpl(this._dio);

  final Dio _dio;

  @override
  Future<PagedResult<ManagedUser>> list(UsersQuery query) => _guard(() async {
        final response = await _dio.get<Map<String, dynamic>>('/admin/users', queryParameters: query.toParams());
        return PagedResult.fromJson(response.data!, ManagedUser.fromJson);
      });

  @override
  Future<UserDetail> detail(String id) => _guard(() async {
        final response = await _dio.get<Map<String, dynamic>>('/admin/users/$id');
        return UserDetail.fromJson(response.data!['data'] as Map<String, dynamic>);
      });

  @override
  Future<void> suspend(String id, {required String reason}) => _guard(() => _dio.post<void>('/admin/users/$id/suspend', data: {'reason': reason}));

  @override
  Future<void> activate(String id) => _guard(() => _dio.post<void>('/admin/users/$id/activate'));

  @override
  Future<int> revokeSessions(String id) => _guard(() async {
        final response = await _dio.post<Map<String, dynamic>>('/admin/users/$id/revoke-sessions');
        return ((response.data!['data'] as Map<String, dynamic>)['revoked'] as num).toInt();
      });

  @override
  Future<void> resetPassword(String id) => _guard(() => _dio.post<void>('/admin/users/$id/reset-password'));

  @override
  Future<void> softDelete(String id, {required String reason}) => _guard(() => _dio.post<void>('/admin/users/$id/delete', data: {'reason': reason}));

  @override
  Future<void> restore(String id) => _guard(() => _dio.post<void>('/admin/users/$id/restore'));

  @override
  Future<BulkResult> bulk({required String action, required List<String> ids, String? reason}) => _guard(() async {
        final response = await _dio.post<Map<String, dynamic>>(
          '/admin/users/bulk',
          data: {'action': action, 'ids': ids, if (reason != null) 'reason': reason},
        );
        return BulkResult.fromJson(response.data!['data'] as Map<String, dynamic>);
      });

  @override
  Future<Uint8List> exportCsv(UsersQuery query) => _guard(() async {
        final response = await _dio.get<List<int>>(
          '/admin/users/export.csv',
          queryParameters: query.toParams(paged: false),
          options: Options(responseType: ResponseType.bytes),
        );
        return Uint8List.fromList(response.data!);
      });

  Future<T> _guard<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on DioException catch (error) {
      throw mapToFailure(error);
    }
  }
}
