import 'package:freezed_annotation/freezed_annotation.dart';

part 'availability_slot.freezed.dart';

@freezed
abstract class AvailabilitySlot with _$AvailabilitySlot {
  const factory AvailabilitySlot({
    required String id,
    required String lawyerId,
    required DateTime start,
    required DateTime end,
    @Default(false) bool isBooked,
    // Only ever set for slots booked through the live `bookConsultation`
    // flow (or, for seed data, explicitly correlated at seed time) — a
    // booked slot with no consultationId is a legacy/unlinked booking the
    // mock model can't resolve back to a specific Consultation.
    String? consultationId,
  }) = _AvailabilitySlot;
}
