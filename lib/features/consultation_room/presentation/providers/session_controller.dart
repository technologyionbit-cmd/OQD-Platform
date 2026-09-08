import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aqd_ionbit/core/errors/failure.dart';
import 'package:aqd_ionbit/core/errors/result.dart';
import 'package:aqd_ionbit/features/consultation_room/data/repositories/consultation_room_repository_impl.dart';
import 'package:aqd_ionbit/features/consultation_room/domain/entities/consultation_room_session.dart';
import 'package:aqd_ionbit/features/consultation_room/domain/repositories/consultation_room_repository.dart';
import 'package:aqd_ionbit/features/lawyers/domain/entities/consultation_type.dart';

/// Family key for [sessionControllerProvider] — a session is scoped to one
/// consultation, and its [type] decides whether [SessionController.connect]
/// takes the voice/video connecting path or goes straight to active.
typedef SessionControllerArgs = ({String consultationId, ConsultationType type});

const _notReadyFailure = UnknownFailure(message: 'Session not loaded yet.');

/// Drives one consultation's live-session state through the repository:
/// `waiting -> ready -> connecting -> active -> ended` for voice/video,
/// `waiting -> ready -> active -> ended` for written — plus the
/// failure/retry/end-anytime side paths the repository exposes.
class SessionController extends AsyncNotifier<ConsultationRoomSession> {
  SessionController(this.arg);

  final SessionControllerArgs arg;
  late final ConsultationRoomRepository _repository;

  @override
  FutureOr<ConsultationRoomSession> build() async {
    _repository = ref.watch(consultationRoomRepositoryProvider);
    final result = await _repository.getSession(arg.consultationId, type: arg.type);
    return result.fold((failure) => throw failure, (session) => session);
  }

  Future<Result<ConsultationRoomSession>> join() => _apply(_repository.join(arg.consultationId));

  Future<Result<ConsultationRoomSession>> connect() => _apply(_repository.connect(arg.consultationId));

  Future<Result<ConsultationRoomSession>> retryConnection() => _apply(_repository.retryConnection(arg.consultationId));

  Future<Result<ConsultationRoomSession>> reportConnectionLost() => _apply(_repository.reportConnectionLost(arg.consultationId));

  Future<Result<ConsultationRoomSession>> end() => _apply(_repository.endSession(arg.consultationId));

  Future<Result<ConsultationRoomSession>> toggleMute() {
    final current = state.value;
    if (current == null) return Future.value(const Result.failure(_notReadyFailure));
    return _apply(_repository.updateMetrics(consultationId: arg.consultationId, isMuted: !current.metrics.isMuted));
  }

  Future<Result<ConsultationRoomSession>> toggleCamera() {
    final current = state.value;
    if (current == null) return Future.value(const Result.failure(_notReadyFailure));
    return _apply(_repository.updateMetrics(consultationId: arg.consultationId, isCameraOn: !current.metrics.isCameraOn));
  }

  Future<Result<ConsultationRoomSession>> toggleSpeaker() {
    final current = state.value;
    if (current == null) return Future.value(const Result.failure(_notReadyFailure));
    return _apply(_repository.updateMetrics(consultationId: arg.consultationId, isSpeakerOn: !current.metrics.isSpeakerOn));
  }

  /// Adds one second to the session's accumulated call/chat duration. The
  /// *ticking* (the actual `Timer`) stays owned by whichever screen is
  /// currently displaying this session (`VoiceCallScreen`/`VideoCallScreen`/
  /// `ChatRoomScreen`, each cancelling it reliably in their own
  /// `State.dispose()`) — only the accumulated *count* lives here, on
  /// [ConsultationRoomSession.metrics], so it survives that screen being
  /// disposed and recreated (e.g. navigating away and back): a fresh widget
  /// instance just resumes incrementing this same counter instead of
  /// restarting it from zero.
  void incrementDuration() {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(current.copyWith(metrics: current.metrics.copyWith(durationSeconds: current.metrics.durationSeconds + 1)));
  }

  Future<Result<ConsultationRoomSession>> _apply(Future<Result<ConsultationRoomSession>> action) async {
    final result = await action;
    result.fold((failure) {}, (session) => state = AsyncData(session));
    return result;
  }
}

final sessionControllerProvider = AsyncNotifierProvider.family<SessionController, ConsultationRoomSession, SessionControllerArgs>(
  SessionController.new,
);
