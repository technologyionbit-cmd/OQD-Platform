import 'package:dio/dio.dart';

import 'package:aqd_admin/core/errors/failure.dart';
import 'package:aqd_admin/core/models/paged_result.dart';
import 'package:aqd_admin/features/lawyers/domain/lawyer.dart';

/// `GET /admin/lawyers`. Throws a `Failure` on error.
class LawyersRepository {
  LawyersRepository(this._dio);

  final Dio _dio;

  Future<PagedResult<Lawyer>> list(LawyersQuery query) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/admin/lawyers', queryParameters: query.toParams());
      return PagedResult.fromJson(response.data!, Lawyer.fromJson);
    } on DioException catch (error) {
      throw mapToFailure(error);
    }
  }
}
