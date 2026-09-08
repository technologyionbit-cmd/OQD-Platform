import 'package:aqd_ionbit/core/errors/result.dart';
import 'package:aqd_ionbit/features/consultation_room/domain/entities/consultation_room_session.dart';
import 'package:aqd_ionbit/features/lawyers/domain/entities/consultation_type.dart';

/// Contract for the live-session runtime. Every method returns the
/// resulting [ConsultationRoomSession], mirroring `ConsultationsRepository`'s
/// own shape so a real WebRTC/Agora/Twilio-backed implementation can drop
/// in later without touching the controller that drives it.
abstract interface class ConsultationRoomRepository {
  /// Fetches (creating if this is the first call) the room session for
  /// [consultationId], seeded at [SessionState.waiting].
  Future<Result<ConsultationRoomSession>> getSession(String consultationId, {required ConsultationType type});

  /// Moves a [SessionState.waiting] session to [SessionState.ready] —
  /// both sides have entered the room and can now start the call/chat.
  Future<Result<ConsultationRoomSession>> join(String consultationId);

  /// From [SessionState.ready]: written consultations go straight to
  /// [SessionState.active]; voice/video consultations pass through
  /// [SessionState.connecting] and resolve to [SessionState.active] or
  /// [SessionState.failed].
  Future<Result<ConsultationRoomSession>> connect(String consultationId);

  /// Retries a [SessionState.failed] connection attempt, incrementing
  /// [ConsultationRoomSession.reconnectAttempts]. Fails outright once
  /// `ConsultationRoomTiming.maxReconnectionAttempts` is exhausted.
  Future<Result<ConsultationRoomSession>> retryConnection(String consultationId);

  /// Reports that an [SessionState.active] session's connection dropped,
  /// moving it to [SessionState.failed] so the caller can offer a retry.
  Future<Result<ConsultationRoomSession>> reportConnectionLost(String consultationId);

  /// Ends the session, moving it to [SessionState.ended].
  Future<Result<ConsultationRoomSession>> endSession(String consultationId);

  /// Updates any subset of the session's call-control metrics.
  Future<Result<ConsultationRoomSession>> updateMetrics({
    required String consultationId,
    bool? isMuted,
    bool? isCameraOn,
    bool? isSpeakerOn,
  });
}
