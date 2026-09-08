import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:aqd_ionbit/features/consultation_room/domain/entities/call_metrics.dart';
import 'package:aqd_ionbit/features/consultation_room/domain/entities/session_state.dart';
import 'package:aqd_ionbit/features/lawyers/domain/entities/consultation_type.dart';

part 'consultation_room_session.freezed.dart';

/// The live-session runtime's view of one consultation — separate from
/// (but keyed by the same id as) `consultations`' own `Consultation`
/// entity, which only tracks the coarser [SessionState]-adjacent values on
/// [ConsultationStatus] for list/badge display.
@freezed
abstract class ConsultationRoomSession with _$ConsultationRoomSession {
  const factory ConsultationRoomSession({
    required String consultationId,
    required ConsultationType type,
    required SessionState state,
    @Default(CallMetrics()) CallMetrics metrics,
    @Default(0) int reconnectAttempts,
  }) = _ConsultationRoomSession;
}
