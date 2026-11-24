import 'package:dio/dio.dart';

import 'package:aqd_admin/core/errors/failure.dart';
import 'package:aqd_admin/core/network/session_store.dart';
import 'package:aqd_admin/features/auth/domain/admin_user.dart';
import 'package:aqd_admin/features/auth/domain/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({required Dio dio, required SessionStore session})
      : _dio = dio,
        _session = session;

  final Dio _dio;
  final SessionStore _session;

  @override
  Future<AdminUser> login({required String phone, required String password}) async {
    final data = await _post('/admin-auth/login', {'phone': phone, 'password': password});
    return _accept(data);
  }

  @override
  Future<AdminUser?> restoreSession() async {
    try {
      final data = await _post('/admin-auth/refresh');
      return _accept(data);
    } on UnauthorizedFailure {
      _session.clear();
      return null;
    } on ForbiddenFailure {
      // The account lost its admin role: same as no session.
      _session.clear();
      return null;
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _post('/admin-auth/logout');
    } on Failure {
      // The cookie may already be gone; leaving is local either way.
    } finally {
      _session.clear();
    }
  }

  Future<Map<String, dynamic>> _post(String path, [Map<String, dynamic>? body]) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(path, data: body);
      final envelope = response.data;
      final data = envelope?['data'];
      return data is Map<String, dynamic> ? data : <String, dynamic>{};
    } on DioException catch (error) {
      throw mapToFailure(error);
    }
  }

  AdminUser _accept(Map<String, dynamic> data) {
    final token = data['accessToken'];
    final user = data['user'];
    if (token is! String || user is! Map<String, dynamic>) {
      throw const UnknownFailure(message: 'Malformed sign-in response');
    }
    final access = data['access'];
    final admin = AdminUser.fromJson({
      ...user,
      if (access is Map<String, dynamic>) ...{
        'fullAccess': access['fullAccess'] == true,
        'permissions': [for (final p in (access['permissions'] as List<dynamic>? ?? const [])) p.toString()],
      },
    });
    if (!admin.isAdmin) {
      throw const ForbiddenFailure(message: 'Not an admin');
    }
    _session.setAccessToken(token);
    return admin;
  }
}
