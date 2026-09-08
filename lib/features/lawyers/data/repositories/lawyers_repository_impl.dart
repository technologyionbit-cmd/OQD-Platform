import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aqd_ionbit/core/errors/result.dart';
import 'package:aqd_ionbit/core/network/api_error_mapper.dart';
import 'package:aqd_ionbit/features/lawyers/data/datasources/lawyers_data_source_provider.dart';
import 'package:aqd_ionbit/features/lawyers/data/datasources/lawyers_remote_data_source.dart';
import 'package:aqd_ionbit/features/lawyers/domain/entities/lawyer_profile.dart';
import 'package:aqd_ionbit/features/lawyers/domain/repositories/lawyers_repository.dart';

class LawyersRepositoryImpl implements LawyersRepository {
  LawyersRepositoryImpl({required LawyersRemoteDataSource remoteDataSource, ApiErrorMapper errorMapper = const ApiErrorMapper()})
    : _remote = remoteDataSource,
      _errorMapper = errorMapper;

  final LawyersRemoteDataSource _remote;
  final ApiErrorMapper _errorMapper;

  @override
  Future<Result<List<LawyerProfile>>> getLawyers() => _guard(_remote.getLawyers);

  @override
  Future<Result<LawyerProfile>> getLawyerById(String id) => _guard(() => _remote.getLawyerById(id));

  @override
  Future<Result<LawyerProfile>> updateProfile(LawyerProfile profile) => _guard(() => _remote.updateProfile(profile));

  Future<Result<T>> _guard<T>(Future<T> Function() action) async {
    try {
      return Result.success(await action());
    } catch (e) {
      return Result.failure(_errorMapper.map(e));
    }
  }
}

final lawyersRepositoryProvider = Provider<LawyersRepository>((ref) {
  return LawyersRepositoryImpl(remoteDataSource: ref.watch(lawyersRemoteDataSourceProvider));
});
