import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aqd_ionbit/core/errors/failure.dart';
import 'package:aqd_ionbit/core/errors/result.dart';
import 'package:aqd_ionbit/core/network/api_error_mapper.dart';
import 'package:aqd_ionbit/core/providers/core_providers.dart';
import 'package:aqd_ionbit/core/security/token_manager.dart';
import 'package:aqd_ionbit/features/auth/data/datasources/auth_data_source_provider.dart';
import 'package:aqd_ionbit/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:aqd_ionbit/features/auth/domain/entities/auth_user.dart';
import 'package:aqd_ionbit/features/auth/domain/entities/register_request.dart';
import 'package:aqd_ionbit/features/auth/domain/repositories/auth_repository.dart';

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
  Future<Result<({AuthUser user, AuthTokens tokens})>> login({required String email, required String password}) async {
    try {
      final result = await _remote.login(email: email, password: password);
      await _tokenManager.save(result.tokens);
      return Result.success(result);
    } catch (e) {
      return Result.failure(_errorMapper.map(e));
    }
  }

  @override
  Future<Result<({AuthUser user, AuthTokens tokens})>> register(RegisterRequest request) async {
    try {
      final result = await _remote.register(request);
      await _tokenManager.save(result.tokens);
      return Result.success(result);
    } catch (e) {
      return Result.failure(_errorMapper.map(e));
    }
  }

  @override
  Future<Result<AuthTokens>> refreshToken(String refreshToken) async {
    try {
      final tokens = await _remote.refreshToken(refreshToken);
      await _tokenManager.save(tokens);
      return Result.success(tokens);
    } catch (e) {
      return Result.failure(_errorMapper.map(e));
    }
  }

  @override
  Future<Result<AuthUser>> currentUser() async {
    final accessToken = _tokenManager.current?.accessToken;
    if (accessToken == null) return const Result.failure(UnauthorizedFailure());
    try {
      final user = await _remote.currentUser(accessToken);
      return Result.success(user);
    } catch (e) {
      return Result.failure(_errorMapper.map(e));
    }
  }

  @override
  Future<void> logout() async {
    final accessToken = _tokenManager.current?.accessToken;
    if (accessToken != null) {
      try {
        await _remote.logout(accessToken);
      } catch (_) {
        // Best-effort — the local session is cleared regardless below.
      }
    }
    await _tokenManager.clear();
  }

  @override
  Future<Result<void>> requestPasswordReset({required String email}) => _guard(() => _remote.requestPasswordReset(email: email));

  @override
  Future<Result<void>> requestOtp({required String destination}) => _guard(() => _remote.requestOtp(destination: destination));

  @override
  Future<Result<bool>> verifyOtp({required String destination, required String code}) async {
    try {
      final verified = await _remote.verifyOtp(destination: destination, code: code);
      return Result.success(verified);
    } catch (e) {
      return Result.failure(_errorMapper.map(e));
    }
  }

  @override
  Future<Result<void>> resetPassword({required String destination, required String code, required String newPassword}) {
    return _guard(() => _remote.resetPassword(destination: destination, code: code, newPassword: newPassword));
  }

  Future<Result<void>> _guard(Future<void> Function() action) async {
    try {
      await action();
      return const Result.success(null);
    } catch (e) {
      return Result.failure(_errorMapper.map(e));
    }
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    remoteDataSource: ref.watch(authRemoteDataSourceProvider),
    tokenManager: ref.watch(tokenManagerProvider),
  );
});
