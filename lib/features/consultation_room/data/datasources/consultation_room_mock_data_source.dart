import 'package:aqd_ionbit/core/errors/failure.dart';
import 'package:aqd_ionbit/features/consultation_room/data/datasources/consultation_room_remote_data_source.dart';
import 'package:aqd_ionbit/features/consultation_room/domain/entities/consultation_room_session.dart';
import 'package:aqd_ionbit/features/consultation_room/domain/entities/consultation_room_timing.dart';
import 'package:aqd_ionbit/features/consultation_room/domain/entities/session_state.dart';
import 'package:aqd_ionbit/features/lawyers/domain/entities/consultation_type.dart';

/// Which of the three deterministic connection outcomes a given
/// consultation ID is seeded with — see [ConsultationRoomMockDataSource]
/// for what each one simulates.
enum _ConnectionProfile { reliable, recoversOnRetry, neverConnects }

/// No real communication SDK involved — this simulates the live-session
/// runtime entirely in memory, with the same consultation ID always
/// producing the same outcome (seeded off `consultationId.hashCode`) so
/// success/failure/reconnection paths are reproducible in tests and,
/// later, in manual QA.
class ConsultationRoomMockDataSource implements ConsultationRoomRemoteDataSource {
  final Map<String, ConsultationRoomSession> _sessions = {};

  _ConnectionProfile _profileFor(String consultationId) {
    switch (consultationId.hashCode.abs() % 3) {
      case 0:
        return _ConnectionProfile.reliable;
      case 1:
        return _ConnectionProfile.recoversOnRetry;
      default:
        return _ConnectionProfile.neverConnects;
    }
  }

  @override
  Future<ConsultationRoomSession> getSession(String consultationId, {required ConsultationType type}) async {
    await _simulateLatency();
    return _sessions.putIfAbsent(
      consultationId,
      () => ConsultationRoomSession(consultationId: consultationId, type: type, state: SessionState.waiting),
    );
  }

  @override
  Future<ConsultationRoomSession> join(String consultationId) {
    return _transition(consultationId, from: {SessionState.waiting}, to: SessionState.ready);
  }

  @override
  Future<ConsultationRoomSession> connect(String consultationId) async {
    await _simulateLatency();
    final session = _require(consultationId);
    if (session.state != SessionState.ready) {
      throw const ValidationFailure(message: 'Session must be ready before connecting.');
    }

    // Written consultations have no live transport to negotiate — they go
    // straight to active, matching the blueprint's `ready -> active` path.
    if (session.type == ConsultationType.written) {
      return _save(session.copyWith(state: SessionState.active));
    }

    final connecting = _save(session.copyWith(state: SessionState.connecting));
    final succeeds = _profileFor(consultationId) == _ConnectionProfile.reliable;
    return _save(connecting.copyWith(state: succeeds ? SessionState.active : SessionState.failed));
  }

  @override
  Future<ConsultationRoomSession> retryConnection(String consultationId) async {
    await _simulateLatency();
    final session = _require(consultationId);
    if (session.state != SessionState.failed) {
      throw const ValidationFailure(message: 'Only a failed session can be retried.');
    }
    if (session.reconnectAttempts >= ConsultationRoomTiming.maxReconnectionAttempts) {
      throw const ValidationFailure(message: 'Maximum reconnection attempts exhausted.');
    }

    final attempted = _save(session.copyWith(reconnectAttempts: session.reconnectAttempts + 1));
    final profile = _profileFor(consultationId);
    // `recoversOnRetry` succeeds on its very first retry; `reliable` also
    // succeeds on retry (a reliable connection that drops mid-call — e.g.
    // via `reportConnectionLost` — reconnects reliably too, same as it
    // connected reliably the first time); `neverConnects` keeps failing
    // until the caller stops retrying (or attempts run out).
    final succeeds = profile != _ConnectionProfile.neverConnects;
    return _save(attempted.copyWith(state: succeeds ? SessionState.active : SessionState.failed));
  }

  @override
  Future<ConsultationRoomSession> reportConnectionLost(String consultationId) {
    return _transition(consultationId, from: {SessionState.active}, to: SessionState.failed);
  }

  @override
  Future<ConsultationRoomSession> endSession(String consultationId) {
    return _transition(
      consultationId,
      from: {SessionState.waiting, SessionState.ready, SessionState.connecting, SessionState.active, SessionState.failed},
      to: SessionState.ended,
    );
  }

  @override
  Future<ConsultationRoomSession> updateMetrics({
    required String consultationId,
    bool? isMuted,
    bool? isCameraOn,
    bool? isSpeakerOn,
  }) async {
    await _simulateLatency();
    final session = _require(consultationId);
    return _save(
      session.copyWith(
        metrics: session.metrics.copyWith(
          isMuted: isMuted ?? session.metrics.isMuted,
          isCameraOn: isCameraOn ?? session.metrics.isCameraOn,
          isSpeakerOn: isSpeakerOn ?? session.metrics.isSpeakerOn,
        ),
      ),
    );
  }

  Future<ConsultationRoomSession> _transition(String consultationId, {required Set<SessionState> from, required SessionState to}) async {
    await _simulateLatency();
    final session = _require(consultationId);
    if (!from.contains(session.state)) {
      throw ValidationFailure(message: 'Cannot move from ${session.state} to $to.');
    }
    return _save(session.copyWith(state: to));
  }

  ConsultationRoomSession _require(String consultationId) {
    final session = _sessions[consultationId];
    if (session == null) throw const NotFoundFailure();
    return session;
  }

  ConsultationRoomSession _save(ConsultationRoomSession session) {
    _sessions[session.consultationId] = session;
    return session;
  }

  Future<void> _simulateLatency() => Future.delayed(const Duration(milliseconds: 300));
}
