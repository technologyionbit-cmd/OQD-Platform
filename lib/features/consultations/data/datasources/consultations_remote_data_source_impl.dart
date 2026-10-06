import 'package:dio/dio.dart';

import 'package:aqd_ionbit/core/network/api_error_mapper.dart';
import 'package:aqd_ionbit/features/consultations/data/datasources/consultations_remote_data_source.dart';
import 'package:aqd_ionbit/features/consultations/domain/entities/availability_slot.dart';
import 'package:aqd_ionbit/features/consultations/domain/entities/consultation.dart';
import 'package:aqd_ionbit/features/consultations/domain/entities/consultation_status.dart';
import 'package:aqd_ionbit/features/lawyers/domain/entities/consultation_type.dart';

/// Dio-backed implementation talking to `<apiBaseUrl>/consultations/*` and
/// `<apiBaseUrl>/lawyers/{id}/availability` /
/// `<apiBaseUrl>/lawyers/me/availability`
/// (docs/plans/individual-user-rollout.md Part 4). Transport errors are
/// mapped to typed `Failure`s via [ApiErrorMapper] so nothing above this
/// layer ever sees a [DioException].
///
/// [addAvailabilitySlot]/[bookConsultation] accept `lawyerId`/`lawyerName`/
/// `price` for interface compatibility with the mock, but the real backend
/// derives the acting lawyer from the JWT (`/lawyers/me/availability`) and
/// always computes `price` itself from the lawyer's own offering — never
/// from client input (docs/backend/01-domain-model.md §4) — so those values
/// are never sent.
class ConsultationsRemoteDataSourceImpl implements ConsultationsRemoteDataSource {
  ConsultationsRemoteDataSourceImpl(this._dio, {ApiErrorMapper errorMapper = const ApiErrorMapper()}) : _errorMapper = errorMapper;

  final Dio _dio;
  final ApiErrorMapper _errorMapper;

  @override
  Future<List<Consultation>> getConsultations() {
    return _errorMapper.guard(() async {
      final res = await _dio.get<Map<String, dynamic>>('/consultations');
      final rows = (res.data!['data'] as List).cast<Map<String, dynamic>>();
      return rows.map(_parseConsultation).toList(growable: false);
    });
  }

  @override
  Future<Consultation> getConsultationById(String id) {
    return _errorMapper.guard(() async {
      final res = await _dio.get<Map<String, dynamic>>('/consultations/$id');
      return _parseConsultation(res.data!['data'] as Map<String, dynamic>);
    });
  }

  @override
  Future<List<AvailabilitySlot>> getAvailability(String lawyerId) {
    return _errorMapper.guard(() async {
      final res = await _dio.get<Map<String, dynamic>>('/lawyers/$lawyerId/availability');
      final rows = (res.data!['data'] as List).cast<Map<String, dynamic>>();
      return rows.map(_parseSlot).toList(growable: false);
    });
  }

  @override
  Future<AvailabilitySlot> addAvailabilitySlot({required String lawyerId, required DateTime start, required DateTime end}) {
    return _errorMapper.guard(() async {
      final res = await _dio.post<Map<String, dynamic>>(
        '/lawyers/me/availability',
        data: {'start': start.toUtc().toIso8601String(), 'end': end.toUtc().toIso8601String()},
      );
      return _parseSlot(res.data!['data'] as Map<String, dynamic>);
    });
  }

  @override
  Future<void> removeAvailabilitySlot(String slotId) {
    return _errorMapper.guard(() => _dio.delete<void>('/lawyers/me/availability/$slotId'));
  }

  @override
  Future<Consultation> bookConsultation({
    required String lawyerId,
    required String lawyerName,
    required ConsultationType type,
    required DateTime scheduledAt,
    required double price,
    required String notes,
  }) {
    return _errorMapper.guard(() async {
      final res = await _dio.post<Map<String, dynamic>>(
        '/consultations',
        data: {
          'lawyerId': lawyerId,
          'type': type.name,
          'scheduledAt': scheduledAt.toUtc().toIso8601String(),
          if (notes.isNotEmpty) 'notes': notes,
        },
      );
      return _parseConsultation(res.data!['data'] as Map<String, dynamic>);
    });
  }

  @override
  Future<Consultation> acceptRequest(String id) {
    return _errorMapper.guard(() async {
      final res = await _dio.post<Map<String, dynamic>>('/consultations/$id/accept');
      return _parseConsultation(res.data!['data'] as Map<String, dynamic>);
    });
  }

  @override
  Future<Consultation> rejectRequest(String id, {String? reason}) {
    return _errorMapper.guard(() async {
      final res = await _dio.post<Map<String, dynamic>>(
        '/consultations/$id/decline',
        data: {if (reason != null) 'cancellationReason': reason},
      );
      return _parseConsultation(res.data!['data'] as Map<String, dynamic>);
    });
  }

  @override
  Future<Consultation> cancel(String id, {String? reason}) {
    return _errorMapper.guard(() async {
      final res = await _dio.post<Map<String, dynamic>>(
        '/consultations/$id/cancel',
        data: {if (reason != null) 'cancellationReason': reason},
      );
      return _parseConsultation(res.data!['data'] as Map<String, dynamic>);
    });
  }

  @override
  Future<Consultation> reschedule({required String id, required DateTime newDateTime}) {
    return _errorMapper.guard(() async {
      final res = await _dio.post<Map<String, dynamic>>(
        '/consultations/$id/reschedule',
        data: {'scheduledAt': newDateTime.toUtc().toIso8601String()},
      );
      return _parseConsultation(res.data!['data'] as Map<String, dynamic>);
    });
  }

  @override
  Future<Consultation> complete(String id) {
    return _errorMapper.guard(() async {
      final res = await _dio.post<Map<String, dynamic>>('/consultations/$id/complete');
      return _parseConsultation(res.data!['data'] as Map<String, dynamic>);
    });
  }

  @override
  Future<Consultation> markMissed(String id) {
    return _errorMapper.guard(() async {
      final res = await _dio.post<Map<String, dynamic>>('/consultations/$id/miss');
      return _parseConsultation(res.data!['data'] as Map<String, dynamic>);
    });
  }

  @override
  Future<Consultation> markFailed(String id) {
    return _errorMapper.guard(() async {
      final res = await _dio.post<Map<String, dynamic>>('/consultations/$id/fail');
      return _parseConsultation(res.data!['data'] as Map<String, dynamic>);
    });
  }

  Consultation _parseConsultation(Map<String, dynamic> row) {
    return Consultation(
      id: row['id'] as String,
      lawyerId: row['lawyerProfileId'] as String,
      lawyerName: row['lawyerName'] as String,
      clientName: row['clientName'] as String,
      type: ConsultationType.values.byName(row['type'] as String),
      status: ConsultationStatus.values.byName(row['status'] as String),
      scheduledAt: DateTime.parse(row['scheduledAt'] as String).toLocal(),
      createdAt: DateTime.parse(row['createdAt'] as String).toLocal(),
      // Prisma `Decimal` serializes as a JSON string, not a number.
      price: double.parse(row['price'] as String),
      notes: row['notes'] as String? ?? '',
    );
  }

  AvailabilitySlot _parseSlot(Map<String, dynamic> row) {
    final consultation = row['consultation'] as Map<String, dynamic>?;
    return AvailabilitySlot(
      id: row['id'] as String,
      lawyerId: row['lawyerProfileId'] as String,
      start: DateTime.parse(row['startAt'] as String).toLocal(),
      end: DateTime.parse(row['endAt'] as String).toLocal(),
      isBooked: row['isBooked'] as bool,
      consultationId: consultation?['id'] as String?,
    );
  }
}
