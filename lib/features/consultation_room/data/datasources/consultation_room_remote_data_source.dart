import 'package:aqd_ionbit/features/consultation_room/domain/entities/consultation_room_session.dart';
import 'package:aqd_ionbit/features/lawyers/domain/entities/consultation_type.dart';

/// Wire-level contract for the live-session runtime, mirroring
/// `ConsultationsRemoteDataSource` — throws a `Failure` on any failure
/// path (invalid state transition, unknown session, exhausted retries),
/// never a raw exception.
abstract interface class ConsultationRoomRemoteDataSource {
  Future<ConsultationRoomSession> getSession(String consultationId, {required ConsultationType type});

  Future<ConsultationRoomSession> join(String consultationId);

  Future<ConsultationRoomSession> connect(String consultationId);

  Future<ConsultationRoomSession> retryConnection(String consultationId);

  Future<ConsultationRoomSession> reportConnectionLost(String consultationId);

  Future<ConsultationRoomSession> endSession(String consultationId);

  Future<ConsultationRoomSession> updateMetrics({
    required String consultationId,
    bool? isMuted,
    bool? isCameraOn,
    bool? isSpeakerOn,
  });
}
