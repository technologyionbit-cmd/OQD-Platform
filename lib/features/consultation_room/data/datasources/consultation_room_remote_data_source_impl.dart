import 'package:dio/dio.dart';

import 'package:aqd_ionbit/core/network/api_error_mapper.dart';
import 'package:aqd_ionbit/features/consultation_room/data/datasources/consultation_room_remote_data_source.dart';
import 'package:aqd_ionbit/features/consultation_room/domain/entities/call_metrics.dart';
import 'package:aqd_ionbit/features/consultation_room/domain/entities/consultation_room_session.dart';
import 'package:aqd_ionbit/features/consultation_room/domain/entities/session_state.dart';
import 'package:aqd_ionbit/features/lawyers/domain/entities/consultation_type.dart';

/// Dio-backed implementation talking to
/// `<apiBaseUrl>/consultations/{id}/room/*`
/// (docs/plans/individual-user-rollout.md Part 5). Transport errors are
/// mapped to typed `Failure`s via [ApiErrorMapper], matching
/// `ConsultationsRemoteDataSourceImpl`.
///
/// The abstract interface never exposes a join token — it's an
/// implementation-only concern (docs/backend/14-security.md §Token
/// security: single-use, scoped to `(consultationId, userId)`, TTL <= 5
/// minutes). [getSession] mints one via `POST .../room/token` and holds it
/// in memory just long enough for the [join] call that follows; nothing
/// above this layer, including `SessionController`, ever sees it.
///
/// `type` (voice/video/written) isn't persisted by the backend's room
/// session row — it lives on `Consultation` already — so it's cached here
/// per `consultationId` from [getSession]'s argument and reattached to
/// every subsequent response this datasource parses.
class ConsultationRoomRemoteDataSourceImpl implements ConsultationRoomRemoteDataSource {
  ConsultationRoomRemoteDataSourceImpl(this._dio, {ApiErrorMapper errorMapper = const ApiErrorMapper()}) : _errorMapper = errorMapper;

  final Dio _dio;
  final ApiErrorMapper _errorMapper;

  final Map<String, ConsultationType> _types = {};
  final Map<String, String> _pendingRoomTokens = {};

  @override
  Future<ConsultationRoomSession> getSession(String consultationId, {required ConsultationType type}) {
    return _call(() async {
      _types[consultationId] = type;
      final res = await _dio.post<Map<String, dynamic>>('/consultations/$consultationId/room/token');
      final data = res.data!['data'] as Map<String, dynamic>;
      _pendingRoomTokens[consultationId] = data['roomToken'] as String;
      return _parseSession(consultationId, data['session'] as Map<String, dynamic>);
    });
  }

  @override
  Future<ConsultationRoomSession> join(String consultationId) {
    return _call(() async {
      final roomToken = _pendingRoomTokens.remove(consultationId);
      final res = await _dio.post<Map<String, dynamic>>(
        '/consultations/$consultationId/room/join',
        data: {'roomToken': roomToken},
      );
      return _parseSession(consultationId, res.data!['data'] as Map<String, dynamic>);
    });
  }

  @override
  Future<ConsultationRoomSession> connect(String consultationId) {
    return _call(() async {
      final res = await _dio.post<Map<String, dynamic>>('/consultations/$consultationId/room/connect');
      return _parseSession(consultationId, res.data!['data'] as Map<String, dynamic>);
    });
  }

  @override
  Future<ConsultationRoomSession> retryConnection(String consultationId) {
    return _call(() async {
      final res = await _dio.post<Map<String, dynamic>>('/consultations/$consultationId/room/retry');
      return _parseSession(consultationId, res.data!['data'] as Map<String, dynamic>);
    });
  }

  @override
  Future<ConsultationRoomSession> reportConnectionLost(String consultationId) {
    return _call(() async {
      final res = await _dio.post<Map<String, dynamic>>('/consultations/$consultationId/room/connection-lost');
      return _parseSession(consultationId, res.data!['data'] as Map<String, dynamic>);
    });
  }

  @override
  Future<ConsultationRoomSession> endSession(String consultationId) {
    return _call(() async {
      final res = await _dio.post<Map<String, dynamic>>('/consultations/$consultationId/room/end');
      return _parseSession(consultationId, res.data!['data'] as Map<String, dynamic>);
    });
  }

  @override
  Future<ConsultationRoomSession> updateMetrics({
    required String consultationId,
    bool? isMuted,
    bool? isCameraOn,
    bool? isSpeakerOn,
  }) {
    return _call(() async {
      final res = await _dio.patch<Map<String, dynamic>>(
        '/consultations/$consultationId/room/metrics',
        data: {
          if (isMuted != null) 'isMuted': isMuted,
          if (isCameraOn != null) 'isCameraOn': isCameraOn,
          if (isSpeakerOn != null) 'isSpeakerOn': isSpeakerOn,
        },
      );
      return _parseSession(consultationId, res.data!['data'] as Map<String, dynamic>);
    });
  }

  ConsultationRoomSession _parseSession(String consultationId, Map<String, dynamic> row) {
    return ConsultationRoomSession(
      consultationId: consultationId,
      type: _types[consultationId]!,
      state: SessionState.values.byName(row['state'] as String),
      reconnectAttempts: row['reconnectAttempts'] as int,
      // `durationSeconds` is never round-tripped to the server (see the
      // backend's `ConsultationRoomSession` schema comment) — it always
      // starts at 0 here and `SessionController.incrementDuration()` ticks
      // it forward client-side from that point on.
      metrics: CallMetrics(
        isMuted: row['isMuted'] as bool,
        isCameraOn: row['isCameraOn'] as bool,
        isSpeakerOn: row['isSpeakerOn'] as bool,
      ),
    );
  }

  /// Runs [action], translating any [DioException] (or unexpected error)
  /// into a typed [Failure] before it escapes this layer.
  Future<T> _call<T>(Future<T> Function() action) async {
    try {
      return await action();
    } catch (error) {
      throw _errorMapper.map(error);
    }
  }
}
