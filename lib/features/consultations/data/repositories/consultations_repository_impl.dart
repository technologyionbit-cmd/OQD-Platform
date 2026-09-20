import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aqd_ionbit/core/errors/result.dart';
import 'package:aqd_ionbit/core/network/api_error_mapper.dart';
import 'package:aqd_ionbit/features/consultations/data/datasources/consultations_data_source_provider.dart';
import 'package:aqd_ionbit/features/consultations/data/datasources/consultations_remote_data_source.dart';
import 'package:aqd_ionbit/features/consultations/domain/entities/availability_slot.dart';
import 'package:aqd_ionbit/features/consultations/domain/entities/consultation.dart';
import 'package:aqd_ionbit/features/consultations/domain/repositories/consultations_repository.dart';
import 'package:aqd_ionbit/features/lawyers/domain/entities/consultation_type.dart';

class ConsultationsRepositoryImpl implements ConsultationsRepository {
  ConsultationsRepositoryImpl({
    required ConsultationsRemoteDataSource remoteDataSource,
    ApiErrorMapper errorMapper = const ApiErrorMapper(),
  }) : _remote = remoteDataSource,
       _errorMapper = errorMapper;

  final ConsultationsRemoteDataSource _remote;
  final ApiErrorMapper _errorMapper;

  @override
  Future<Result<List<Consultation>>> getConsultations() => _guard(_remote.getConsultations);

  @override
  Future<Result<Consultation>> getConsultationById(String id) => _guard(() => _remote.getConsultationById(id));

  @override
  Future<Result<List<AvailabilitySlot>>> getAvailability(String lawyerId) => _guard(() => _remote.getAvailability(lawyerId));

  @override
  Future<Result<AvailabilitySlot>> addAvailabilitySlot({required String lawyerId, required DateTime start, required DateTime end}) {
    return _guard(() => _remote.addAvailabilitySlot(lawyerId: lawyerId, start: start, end: end));
  }

  @override
  Future<Result<void>> removeAvailabilitySlot(String slotId) => _guard(() => _remote.removeAvailabilitySlot(slotId));

  @override
  Future<Result<Consultation>> bookConsultation({
    required String lawyerId,
    required String lawyerName,
    required ConsultationType type,
    required DateTime scheduledAt,
    required double price,
    String notes = '',
  }) {
    return _guard(
      () => _remote.bookConsultation(
        lawyerId: lawyerId,
        lawyerName: lawyerName,
        type: type,
        scheduledAt: scheduledAt,
        price: price,
        notes: notes,
      ),
    );
  }

  @override
  Future<Result<Consultation>> acceptRequest(String id) => _guard(() => _remote.acceptRequest(id));

  @override
  Future<Result<Consultation>> rejectRequest(String id, {String? reason}) => _guard(() => _remote.rejectRequest(id, reason: reason));

  @override
  Future<Result<Consultation>> cancel(String id, {String? reason}) => _guard(() => _remote.cancel(id, reason: reason));

  @override
  Future<Result<Consultation>> reschedule({required String id, required DateTime newDateTime}) {
    return _guard(() => _remote.reschedule(id: id, newDateTime: newDateTime));
  }

  @override
  Future<Result<Consultation>> complete(String id) => _guard(() => _remote.complete(id));

  @override
  Future<Result<Consultation>> markMissed(String id) => _guard(() => _remote.markMissed(id));

  @override
  Future<Result<Consultation>> markFailed(String id) => _guard(() => _remote.markFailed(id));

  Future<Result<T>> _guard<T>(Future<T> Function() action) async {
    try {
      return Result.success(await action());
    } catch (e) {
      return Result.failure(_errorMapper.map(e));
    }
  }
}

final consultationsRepositoryProvider = Provider<ConsultationsRepository>((ref) {
  return ConsultationsRepositoryImpl(remoteDataSource: ref.watch(consultationsRemoteDataSourceProvider));
});
