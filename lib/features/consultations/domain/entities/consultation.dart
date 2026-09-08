import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:aqd_ionbit/features/consultations/domain/entities/consultation_message.dart';
import 'package:aqd_ionbit/features/consultations/domain/entities/consultation_status.dart';
import 'package:aqd_ionbit/features/lawyers/domain/entities/consultation_type.dart';

part 'consultation.freezed.dart';

@freezed
abstract class Consultation with _$Consultation {
  const factory Consultation({
    required String id,
    required String lawyerId,
    required String lawyerName,
    required String clientName,
    required ConsultationType type,
    required ConsultationStatus status,
    required DateTime scheduledAt,
    required DateTime createdAt,
    required double price,
    @Default('') String notes,
    @Default(<ConsultationMessage>[]) List<ConsultationMessage> messages,
  }) = _Consultation;
}
