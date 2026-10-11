import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aqd_ionbit/core/errors/failure.dart';
import 'package:aqd_ionbit/core/errors/result.dart';
import 'package:aqd_ionbit/core/network/api_error_mapper.dart';
import 'package:aqd_ionbit/core/network/auth_session_ports.dart';
import 'package:aqd_ionbit/core/providers/core_providers.dart';
import 'package:aqd_ionbit/core/security/token_manager.dart';
import 'package:aqd_ionbit/features/auth/data/datasources/auth_data_source_provider.dart';
import 'package:aqd_ionbit/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:aqd_ionbit/features/auth/domain/entities/auth_session.dart';
import 'package:aqd_ionbit/features/auth/domain/entities/auth_user.dart';
import 'package:aqd_ionbit/features/auth/domain/entities/register_request.dart';
import 'package:aqd_ionbit/features/auth/domain/repositories/auth_repository.dart';

/// Bridges the domain [AuthRepository] to the wire [AuthRemoteDataSource]:
/// persists tokens on any call that issues them, clears them on logout,
/// and turns every thrown [Failure] into a [Result] so the presentation
/// layer never sees an exception.
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required TokenManager tokenManager,
    ApiErrorMapper errorMapper = const ApiErrorMapper(),
  }) : _remote = remoteDataSource,
       _tokenManager = tokenManager,
       _errorMapper = errorMapper;

  final AuthRemoteDataSource _remote;
  final TokenManager _tokenManager;
  final ApiErrorMapper _errorMapper;

  @override
  Future<Result<({AuthUser user, AuthTokens tokens})>> login({required String phone, required String password}) {
    return _errorMapper.capture(() async {
      final result = await _remote.login(phone: phone, password: password);
      await _tokenManager.save(result.tokens);
      return result;
    });
  }

  @override
  Future<Result<({AuthUser user, AuthTokens tokens})>> register(RegisterRequest request) {
    return _errorMapper.capture(() async {
      final result = await _remote.register(request);
      await _tokenManager.save(result.tokens);
      return result;
    });
  }

  @override
  Future<Result<AuthUser?>> restoreSession() async {
    final stored = await _tokenManager.loadFromStorage();
    if (stored == null) return const Result.success(null);

    // An expired access token is refreshed transparently by AuthInterceptor
    // on the way — a 401 reaching here means the refresh was rejected too.
    final result = await currentUser();
    switch (result) {
      case Success(:final data):
        return Result.success(data);
      case ResultFailure(failure: UnauthorizedFailure() || ForbiddenFailure()):
        await clearLocalSession();
        return const Result.success(null);
      case ResultFailure(:final failure):
        return Result.failure(failure);
    }
  }

  @override
  Future<RefreshOutcome> refreshSession() async {
    final refreshToken = _tokenManager.current?.refreshToken;
    if (refreshToken == null) return const RefreshRejected();

    try {
      final tokens = await _remote.refreshToken(refreshToken);
      await _tokenManager.save(tokens);
      return RefreshSucceeded(tokens);
    } catch (error) {
      return _isRefusal(_errorMapper.map(error)) ? const RefreshRejected() : const RefreshUnavailable();
    }
  }

  /// Only an explicit refusal from the server ends the session. Throttling
  /// (429), server errors and connectivity problems are all retryable.
  bool _isRefusal(Failure failure) => switch (failure) {
    UnauthorizedFailure() || ForbiddenFailure() || ValidationFailure() => true,
    ServerFailure(statusCode: 400) => true,
    _ => false,
  };

  @override
  Future<void> clearLocalSession() => _tokenManager.clear();

  @override
  Future<Result<AuthUser>> currentUser() {
    if (_tokenManager.current?.accessToken == null) {
      return Future.value(const Result.failure(UnauthorizedFailure()));
    }
    return _errorMapper.capture(_remote.currentUser);
  }

  @override
  Future<Result<AuthUser>> updateProfile({required String fullName, required String email, required String currentPassword}) {
    return _errorMapper.capture(() => _remote.updateProfile(fullName: fullName, email: email, currentPassword: currentPassword));
  }

  @override
  Future<void> logout() async {
    final refreshToken = _tokenManager.current?.refreshToken;
    if (refreshToken != null) {
      try {
        await _remote.logout(refreshToken);
      } catch (_) {
        // Best-effort — the local session is cleared regardless below.
      }
    }
    await _tokenManager.clear();
  }

  @override
  Future<Result<AuthUser>> verifyPhone({required String code}) {
    return _errorMapper.capture(() => _remote.verifyPhone(code: code));
  }

  @override
  Future<Result<void>> resendPhoneVerification() => _errorMapper.capture(_remote.resendPhoneVerification);

  @override
  Future<Result<void>> requestPasswordReset({required String phone}) {
    return _errorMapper.capture(() => _remote.requestPasswordReset(phone: phone));
  }

  @override
  Future<Result<void>> verifyPasswordResetCode({required String phone, required String code}) {
    return _errorMapper.capture(() => _remote.verifyPasswordResetCode(phone: phone, code: code));
  }

  @override
  Future<Result<void>> resetPassword({required String phone, required String code, required String newPassword}) {
    return _errorMapper.capture(() => _remote.resetPassword(phone: phone, code: code, newPassword: newPassword));
  }

  @override
  Future<Result<void>> changePassword({required String currentPassword, required String newPassword}) {
    return _errorMapper.capture(() => _remote.changePassword(currentPassword: currentPassword, newPassword: newPassword));
  }

  @override
  Future<Result<List<AuthSession>>> listSessions() => _errorMapper.capture(_remote.listSessions);

  @override
  Future<Result<void>> revokeSession(String sessionId) => _errorMapper.capture(() => _remote.revokeSession(sessionId));

  @override
  Future<Result<void>> revokeOtherSessions() => _errorMapper.capture(_remote.revokeOtherSessions);
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    remoteDataSource: ref.watch(authRemoteDataSourceProvider),
    tokenManager: ref.watch(tokenManagerProvider),
  );
});
