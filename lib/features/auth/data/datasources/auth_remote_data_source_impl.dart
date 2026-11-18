import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'package:aqd_ionbit/core/errors/failure.dart';
import 'package:aqd_ionbit/core/network/api_error_mapper.dart';
import 'package:aqd_ionbit/core/network/dio_extra_keys.dart';
import 'package:aqd_ionbit/core/security/token_manager.dart';
import 'package:aqd_ionbit/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:aqd_ionbit/features/auth/data/datasources/auth_wire.dart';
import 'package:aqd_ionbit/features/auth/domain/entities/auth_session.dart';
import 'package:aqd_ionbit/features/auth/domain/entities/auth_user.dart';
import 'package:aqd_ionbit/features/auth/domain/entities/register_request.dart';

/// Dio-backed implementation of the auth wire contract, talking to the
/// NestJS backend at `<apiBaseUrl>/auth/*`. Transport errors are mapped to
/// typed [Failure]s via [ApiErrorMapper] so nothing above this layer ever
/// sees a [DioException].
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl(this._dio, {ApiErrorMapper errorMapper = const ApiErrorMapper()}) : _errorMapper = errorMapper;

  final Dio _dio;
  final ApiErrorMapper _errorMapper;

  static final _publicOptions = Options(extra: {DioExtraKeys.skipAuth: true});

  @override
  Future<({AuthUser user, AuthTokens tokens})> login({required String phone, required String password}) {
    return _errorMapper.guard(() async {
      final res = await _dio.post<Map<String, dynamic>>(
        '/auth/login',
        data: {'phone': phone, 'password': password},
        options: _publicOptions,
      );
      try {
        return AuthWire.session(res.data);
      } on ForbiddenFailure catch (failure) {
        // The server accepted the credentials and opened a session, but this
        // app cannot serve the account's role. Revoke that session instead
        // of leaving it alive on the server, then report the refusal.
        if (failure.code == ApiErrorCodes.unsupportedRole) {
          await _revokeUnusableSession(res.data);
        }
        rethrow;
      }
    });
  }

  Future<void> _revokeUnusableSession(Map<String, dynamic>? body) async {
    try {
      final tokens = AuthWire.data(body)['tokens'] as Map<String, dynamic>;
      await _dio.post<void>('/auth/logout', data: {'refreshToken': tokens['refreshToken']}, options: _publicOptions);
    } catch (_) {
      // Best-effort; the refusal below is what the user needs to see.
    }
  }

  @override
  Future<({AuthUser user, AuthTokens tokens})> register(RegisterRequest request) {
    return _errorMapper.guard(() async {
      try {
        final res = await _dio.post<Map<String, dynamic>>('/auth/register', data: AuthWire.registerBody(request), options: _publicOptions);
        _debugLogResponse('/auth/register', res.statusCode, res.data);
        return AuthWire.session(res.data);
      } on DioException catch (e) {
        _debugLogResponse('/auth/register', e.response?.statusCode, e.response?.data ?? e.message);
        rethrow;
      }
    });
  }

  /// Debug builds only: prints an API response so it can be inspected in the
  /// console. Token values are cut short — they are credentials.
  static void _debugLogResponse(String path, int? status, Object? body) {
    if (!kDebugMode) return;
    Object? mask(Object? v, [String? key]) {
      if (v is Map) return {for (final e in v.entries) e.key: mask(e.value, e.key.toString())};
      if (v is List) return v.map(mask).toList();
      if (v is String && key != null && key.toLowerCase().contains('token')) {
        return v.length > 12 ? '${v.substring(0, 12)}...' : v;
      }
      return v;
    }

    final pretty = const JsonEncoder.withIndent('  ').convert(mask(body));
    debugPrint('[API] POST $path -> $status\n$pretty');
  }

  @override
  Future<AuthTokens> refreshToken(String refreshToken) {
    return _errorMapper.guard(() async {
      final res = await _dio.post<Map<String, dynamic>>('/auth/refresh', data: {'refreshToken': refreshToken}, options: _publicOptions);
      return AuthWire.tokens(AuthWire.data(res.data)['tokens'] as Map<String, dynamic>);
    });
  }

  @override
  Future<AuthUser> currentUser() {
    return _errorMapper.guard(() async {
      final res = await _dio.get<Map<String, dynamic>>('/auth/me');
      return AuthWire.user(AuthWire.data(res.data)['user'] as Map<String, dynamic>);
    });
  }

  @override
  Future<AuthUser> updateProfile({required String fullName, required String email}) {
    return _errorMapper.guard(() async {
      final res = await _dio.patch<Map<String, dynamic>>('/auth/me', data: {'fullName': fullName, 'email': email});
      return AuthWire.user(AuthWire.data(res.data)['user'] as Map<String, dynamic>);
    });
  }

  @override
  Future<void> logout(String refreshToken) {
    return _errorMapper.guard(() async {
      await _dio.post<void>('/auth/logout', data: {'refreshToken': refreshToken}, options: _publicOptions);
    });
  }

  @override
  Future<AuthUser> verifyPhone({required String code}) {
    return _errorMapper.guard(() async {
      final res = await _dio.post<Map<String, dynamic>>('/auth/phone/verify', data: {'code': code});
      return AuthWire.user(AuthWire.data(res.data)['user'] as Map<String, dynamic>);
    });
  }

  @override
  Future<void> resendPhoneVerification() {
    return _errorMapper.guard(() => _dio.post<void>('/auth/phone/resend'));
  }

  @override
  Future<void> requestPasswordReset({required String phone}) {
    return _errorMapper.guard(() async {
      await _dio.post<void>('/auth/password/forgot', data: {'phone': phone}, options: _publicOptions);
    });
  }

  @override
  Future<void> verifyPasswordResetCode({required String phone, required String code}) {
    return _errorMapper.guard(() async {
      await _dio.post<void>('/auth/password/verify-otp', data: {'phone': phone, 'code': code}, options: _publicOptions);
    });
  }

  @override
  Future<void> resetPassword({required String phone, required String code, required String newPassword}) {
    return _errorMapper.guard(() async {
      await _dio.post<void>(
        '/auth/password/reset',
        data: {'phone': phone, 'code': code, 'newPassword': newPassword},
        options: _publicOptions,
      );
    });
  }

  @override
  Future<void> changePassword({required String currentPassword, required String newPassword}) {
    return _errorMapper.guard(() async {
      await _dio.post<void>('/auth/password/change', data: {'currentPassword': currentPassword, 'newPassword': newPassword});
    });
  }

  @override
  Future<List<AuthSession>> listSessions() {
    return _errorMapper.guard(() async {
      final res = await _dio.get<Map<String, dynamic>>('/auth/sessions');
      return AuthWire.dataList(res.data).map((row) => AuthWire.sessionSummary(row as Map<String, dynamic>)).toList(growable: false);
    });
  }

  @override
  Future<void> revokeSession(String sessionId) {
    return _errorMapper.guard(() => _dio.delete<void>('/auth/sessions/$sessionId'));
  }

  @override
  Future<void> revokeOtherSessions() {
    return _errorMapper.guard(() => _dio.delete<void>('/auth/sessions'));
  }
}
