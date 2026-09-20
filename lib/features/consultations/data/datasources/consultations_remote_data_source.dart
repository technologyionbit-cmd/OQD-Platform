import 'package:aqd_ionbit/features/consultations/domain/entities/availability_slot.dart';
import 'package:aqd_ionbit/features/consultations/domain/entities/consultation.dart';
import 'package:aqd_ionbit/features/lawyers/domain/entities/consultation_type.dart';

/// Wire-level contract for the consultations feature (booking + lifecycle
/// + messaging + lawyer availability). Mirrors `ContractsRemoteDataSource`
/// — throws a [Failure] on any failure path, never a raw exception.
abstract interface class ConsultationsRemoteDataSource {
  Future<List<Consultation>> getConsultations();

  Future<Consultation> getConsultationById(String id);

  Future<List<AvailabilitySlot>> getAvailability(String lawyerId);

  Future<AvailabilitySlot> addAvailabilitySlot({required String lawyerId, required DateTime start, required DateTime end});

  Future<void> removeAvailabilitySlot(String slotId);

  Future<Consultation> bookConsultation({
    required String lawyerId,
    required String lawyerName,
    required ConsultationType type,
    required DateTime scheduledAt,
    required double price,
    required String notes,
  });

  Future<Consultation> acceptRequest(String id);

  Future<Consultation> rejectRequest(String id, {String? reason});

  Future<Consultation> cancel(String id, {String? reason});

  Future<Consultation> reschedule({required String id, required DateTime newDateTime});

  Future<Consultation> complete(String id);

  Future<Consultation> markMissed(String id);

  Future<Consultation> markFailed(String id);
}
