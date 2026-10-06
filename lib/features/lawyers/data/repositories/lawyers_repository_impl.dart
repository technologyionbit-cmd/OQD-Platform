import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aqd_ionbit/core/errors/result.dart';
import 'package:aqd_ionbit/core/network/api_error_mapper.dart';
import 'package:aqd_ionbit/features/lawyers/data/datasources/lawyers_data_source_provider.dart';
import 'package:aqd_ionbit/features/lawyers/data/datasources/lawyers_remote_data_source.dart';
import 'package:aqd_ionbit/features/lawyers/domain/entities/lawyer_profile.dart';
import 'package:aqd_ionbit/features/lawyers/domain/entities/lawyer_specialty.dart';
import 'package:aqd_ionbit/features/lawyers/domain/entities/verification_document_upload.dart';
import 'package:aqd_ionbit/features/lawyers/domain/repositories/lawyers_repository.dart';

class LawyersRepositoryImpl implements LawyersRepository {
  LawyersRepositoryImpl({required LawyersRemoteDataSource remoteDataSource, ApiErrorMapper errorMapper = const ApiErrorMapper()})
    : _remote = remoteDataSource,
      _errorMapper = errorMapper;

  final LawyersRemoteDataSource _remote;
  final ApiErrorMapper _errorMapper;

  @override
  Future<Result<List<LawyerProfile>>> getLawyers({String? query, LawyerSpecialty? specialty, double? minRating, int? page}) =>
      _errorMapper.capture(() => _remote.getLawyers(query: query, specialty: specialty, minRating: minRating, page: page));

  @override
  Future<Result<LawyerProfile>> getLawyerById(String id) => _errorMapper.capture(() => _remote.getLawyerById(id));

  @override
  Future<Result<LawyerProfile>> getMyProfile() => _errorMapper.capture(_remote.getMyProfile);

  @override
  Future<Result<LawyerProfile>> updateProfile(LawyerProfile profile) => _errorMapper.capture(() => _remote.updateProfile(profile));

  @override
  Future<Result<LawyerProfile>> submitVerification(List<VerificationDocumentUpload> documents) =>
      _errorMapper.capture(() => _remote.submitVerification(documents));
}

final lawyersRepositoryProvider = Provider<LawyersRepository>((ref) {
  return LawyersRepositoryImpl(remoteDataSource: ref.watch(lawyersRemoteDataSourceProvider));
});
