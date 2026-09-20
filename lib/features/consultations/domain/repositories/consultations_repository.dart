import 'package:aqd_ionbit/core/errors/result.dart';
import 'package:aqd_ionbit/features/consultations/domain/entities/availability_slot.dart';
import 'package:aqd_ionbit/features/consultations/domain/entities/consultation.dart';
import 'package:aqd_ionbit/features/lawyers/domain/entities/consultation_type.dart';

abstract interface class ConsultationsRepository {
  Future<Result<List<Consultation>>> getConsultations();

  Future<Result<Consultation>> getConsultationById(String id);

  Future<Result<List<AvailabilitySlot>>> getAvailability(String lawyerId);

  Future<Result<AvailabilitySlot>> addAvailabilitySlot({required String lawyerId, required DateTime start, required DateTime end});

  Future<Result<void>> removeAvailabilitySlot(String slotId);

  Future<Result<Consultation>> bookConsultation({
    required String lawyerId,
    required String lawyerName,
    required ConsultationType type,
    required DateTime scheduledAt,
    required double price,
    String notes,
  });

  Future<Result<Consultation>> acceptRequest(String id);

  Future<Result<Consultation>> rejectRequest(String id, {String? reason});

  Future<Result<Consultation>> cancel(String id, {String? reason});

  Future<Result<Consultation>> reschedule({required String id, required DateTime newDateTime});

  Future<Result<Consultation>> complete(String id);

  Future<Result<Consultation>> markMissed(String id);

  Future<Result<Consultation>> markFailed(String id);
}
