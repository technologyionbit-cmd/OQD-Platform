import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:aqd_ionbit/features/lawyers/domain/entities/consultation_type.dart';

part 'booking_state.freezed.dart';

/// In-progress "book a consultation" state — spans the type, date/time,
/// and details/confirm screens, so it lives in a provider (not any one
/// screen's State) and survives navigating between them. Mirrors
/// `ContractDraftState`.
@freezed
abstract class BookingState with _$BookingState {
  const factory BookingState({
    String? lawyerId,
    String? lawyerName,
    ConsultationType? type,
    double? price,
    DateTime? scheduledAt,
    @Default('') String notes,
  }) = _BookingState;
}
