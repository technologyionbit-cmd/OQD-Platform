import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aqd_ionbit/core/errors/result.dart';
import 'package:aqd_ionbit/core/network/api_error_mapper.dart';
import 'package:aqd_ionbit/features/consultation_room/data/datasources/consultation_room_data_source_provider.dart';
import 'package:aqd_ionbit/features/consultation_room/data/datasources/consultation_room_remote_data_source.dart';
import 'package:aqd_ionbit/features/consultation_room/domain/entities/consultation_room_session.dart';
import 'package:aqd_ionbit/features/consultation_room/domain/repositories/consultation_room_repository.dart';
import 'package:aqd_ionbit/features/lawyers/domain/entities/consultation_type.dart';

class ConsultationRoomRepositoryImpl implements ConsultationRoomRepository {
  ConsultationRoomRepositoryImpl({
    required ConsultationRoomRemoteDataSource remoteDataSource,
    ApiErrorMapper errorMapper = const ApiErrorMapper(),
  }) : _remote = remoteDataSource,
       _errorMapper = errorMapper;

  final ConsultationRoomRemoteDataSource _remote;
  final ApiErrorMapper _errorMapper;

  @override
  Future<Result<ConsultationRoomSession>> getSession(String consultationId, {required ConsultationType type}) {
    return _guard(() => _remote.getSession(consultationId, type: type));
  }

  @override
  Future<Result<ConsultationRoomSession>> join(String consultationId) => _guard(() => _remote.join(consultationId));

  @override
  Future<Result<ConsultationRoomSession>> connect(String consultationId) => _guard(() => _remote.connect(consultationId));

  @override
  Future<Result<ConsultationRoomSession>> retryConnection(String consultationId) => _guard(() => _remote.retryConnection(consultationId));

  @override
  Future<Result<ConsultationRoomSession>> reportConnectionLost(String consultationId) {
    return _guard(() => _remote.reportConnectionLost(consultationId));
  }

  @override
  Future<Result<ConsultationRoomSession>> endSession(String consultationId) => _guard(() => _remote.endSession(consultationId));

  @override
  Future<Result<ConsultationRoomSession>> updateMetrics({
    required String consultationId,
    bool? isMuted,
    bool? isCameraOn,
    bool? isSpeakerOn,
  }) {
    return _guard(
      () => _remote.updateMetrics(consultationId: consultationId, isMuted: isMuted, isCameraOn: isCameraOn, isSpeakerOn: isSpeakerOn),
    );
  }

  Future<Result<T>> _guard<T>(Future<T> Function() action) async {
    try {
      return Result.success(await action());
    } catch (e) {
      return Result.failure(_errorMapper.map(e));
    }
  }
}

final consultationRoomRepositoryProvider = Provider<ConsultationRoomRepository>((ref) {
  return ConsultationRoomRepositoryImpl(remoteDataSource: ref.watch(consultationRoomRemoteDataSourceProvider));
});
