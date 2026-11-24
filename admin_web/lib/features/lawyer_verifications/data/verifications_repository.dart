import 'dart:typed_data';

import 'package:dio/dio.dart';

import 'package:aqd_admin/core/errors/failure.dart';
import 'package:aqd_admin/features/lawyer_verifications/domain/pending_lawyer.dart';

/// `/admin/lawyer-verifications`. Throws a `Failure` on error.
class VerificationsRepository {
  VerificationsRepository(this._dio);

  final Dio _dio;

  Future<List<PendingLawyer>> pending() => _guard(() async {
        final response = await _dio.get<Map<String, dynamic>>('/admin/lawyer-verifications');
        return [for (final row in response.data!['data'] as List<dynamic>) PendingLawyer.fromJson(row as Map<String, dynamic>)];
      });

  Future<void> approve(String lawyerProfileId) => _guard(() => _dio.post<void>('/admin/lawyer-verifications/$lawyerProfileId/approve'));

  Future<void> reject(String lawyerProfileId, {required String reason}) =>
      _guard(() => _dio.post<void>('/admin/lawyer-verifications/$lawyerProfileId/reject', data: {'reason': reason}));

  Future<Uint8List> document(String lawyerProfileId, String documentId) => _guard(() async {
        final response = await _dio.get<List<int>>(
          '/admin/lawyer-verifications/$lawyerProfileId/documents/$documentId',
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
