import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aqd_ionbit/core/errors/result.dart';
import 'package:aqd_ionbit/features/auth/presentation/providers/current_user_id_provider.dart';
import 'package:aqd_ionbit/features/consultations/data/repositories/consultations_repository_impl.dart';
import 'package:aqd_ionbit/features/consultations/domain/entities/consultation.dart';
import 'package:aqd_ionbit/features/consultations/domain/repositories/consultations_repository.dart';

/// The full consultations list (bookings + requests, every status) —
/// client/lawyer/company screens all filter this by status client-side,
/// mirroring `ContractsController`.
class ConsultationsController extends AsyncNotifier<List<Consultation>> {
  ConsultationsRepository get _repository => ref.read(consultationsRepositoryProvider);

  @override
  FutureOr<List<Consultation>> build() async {
    ref.watch(consultationsRepositoryProvider);
    if (ref.watch(currentUserIdProvider) == null) return const []; // Signed out: no one's data.
    final result = await _repository.getConsultations();
    return result.fold((failure) => throw failure, (consultations) => consultations);
  }

  Future<void> refresh() async {
    final result = await _repository.getConsultations();
    state = result.fold((failure) => AsyncError(failure, StackTrace.current), AsyncData.new);
  }

  Future<Result<Consultation>> acceptRequest(String id) => _thenRefresh(_repository.acceptRequest(id));

  Future<Result<Consultation>> rejectRequest(String id, {String? reason}) => _thenRefresh(_repository.rejectRequest(id, reason: reason));

  Future<Result<Consultation>> cancel(String id, {String? reason}) => _thenRefresh(_repository.cancel(id, reason: reason));

  Future<Result<Consultation>> reschedule({required String id, required DateTime newDateTime}) =>
      _thenRefresh(_repository.reschedule(id: id, newDateTime: newDateTime));

  Future<Result<Consultation>> complete(String id) => _thenRefresh(_repository.complete(id));

  /// The server notifies the other participant of each change itself.
  Future<Result<Consultation>> _thenRefresh(Future<Result<Consultation>> action) async {
    final result = await action;
    if (result.isSuccess) await refresh();
    return result;
  }

  /// Best-effort sync fired once `ConsultationWaitingScreen` observes the
  /// join-window grace period has elapsed with nobody having joined — keeps
  /// the booking-level status a true, persisted `missed` outcome instead of
  /// only ever existing as a wall-clock-computed lobby display, so it
  /// actually survives into consultation history/list screens.
  Future<Result<Consultation>> markMissed(String id) async {
    final result = await _repository.markMissed(id);
    if (result.isSuccess) await refresh();
    return result;
  }

  /// Best-effort sync fired once a live call's reconnection attempts are
  /// exhausted (see `VoiceCallScreen`/`VideoCallScreen`'s `_syncSession`) —
  /// mirrors [complete]'s sync-on-end so a call that never recovers doesn't
  /// stay `confirmed` forever in consultation lists/history.
  Future<Result<Consultation>> markFailed(String id) async {
    final result = await _repository.markFailed(id);
    if (result.isSuccess) await refresh();
    return result;
  }
}

final consultationsControllerProvider = AsyncNotifierProvider<ConsultationsController, List<Consultation>>(ConsultationsController.new);
