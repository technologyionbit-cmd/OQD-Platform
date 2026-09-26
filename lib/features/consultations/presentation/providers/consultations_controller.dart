import 'dart:async';

import 'package:flutter/widgets.dart' show Locale;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aqd_ionbit/core/errors/result.dart';
import 'package:aqd_ionbit/core/localization/generated/app_localizations.dart';
import 'package:aqd_ionbit/core/localization/locale_controller.dart';
import 'package:aqd_ionbit/features/auth/domain/entities/auth_user.dart';
import 'package:aqd_ionbit/features/consultations/data/repositories/consultations_repository_impl.dart';
import 'package:aqd_ionbit/features/consultations/domain/entities/consultation.dart';
import 'package:aqd_ionbit/features/consultations/domain/repositories/consultations_repository.dart';
import 'package:aqd_ionbit/features/notifications/domain/entities/notification_type.dart';
import 'package:aqd_ionbit/features/notifications/presentation/providers/notifications_controller.dart';

/// The full consultations list (bookings + requests, every status) —
/// client/lawyer/company screens all filter this by status client-side,
/// mirroring `ContractsController`.
class ConsultationsController extends AsyncNotifier<List<Consultation>> {
  late final ConsultationsRepository _repository;

  @override
  FutureOr<List<Consultation>> build() async {
    _repository = ref.watch(consultationsRepositoryProvider);
    final result = await _repository.getConsultations();
    return result.fold((failure) => throw failure, (consultations) => consultations);
  }

  Future<void> refresh() async {
    final result = await _repository.getConsultations();
    state = result.fold((failure) => AsyncError(failure, StackTrace.current), AsyncData.new);
  }

  /// Notification title/body must reflect the app's *current* locale even
  /// though this is a plain [AsyncNotifier] with no `BuildContext` — loading
  /// the delegate directly off the persisted locale is the same trick used
  /// wherever else this codebase needs l10n outside the widget tree. Falls
  /// back to the app's default locale if `localeControllerProvider` isn't
  /// wired up in the current container (e.g. a narrowly-scoped test that
  /// only overrides the consultations/session providers it's exercising) —
  /// a notification's language is never worth failing the underlying action
  /// over.
  Future<AppLocalizations> _l10n() async {
    Locale locale;
    try {
      locale = ref.read(localeControllerProvider);
    } catch (_) {
      locale = const Locale('ar');
    }
    return AppLocalizations.delegate.load(locale);
  }

  Future<Result<Consultation>> acceptRequest(String id) async {
    final result = await _repository.acceptRequest(id);
    if (result.isSuccess) {
      await refresh();
      final consultation = result.valueOrNull!;
      final l10n = await _l10n();
      await ref
          .read(notificationsControllerProvider.notifier)
          .create(
            type: NotificationType.consultationAccepted,
            title: l10n.notificationConsultationAcceptedTitle,
            body: l10n.notificationConsultationAcceptedBody(consultation.lawyerName),
            relatedId: consultation.id,
            recipientUserId: kDemoClientUserId,
          );
    }
    return result;
  }

  Future<Result<Consultation>> rejectRequest(String id, {String? reason}) async {
    final result = await _repository.rejectRequest(id, reason: reason);
    if (result.isSuccess) {
      await refresh();
      final consultation = result.valueOrNull!;
      final l10n = await _l10n();
      await ref
          .read(notificationsControllerProvider.notifier)
          .create(
            type: NotificationType.consultationRejected,
            title: l10n.notificationConsultationRejectedTitle,
            body: l10n.notificationConsultationRejectedBody(consultation.lawyerName),
            relatedId: consultation.id,
            recipientUserId: kDemoClientUserId,
          );
    }
    return result;
  }

  Future<Result<Consultation>> cancel(String id, {String? reason}) async {
    final result = await _repository.cancel(id, reason: reason);
    if (result.isSuccess) {
      await refresh();
      final consultation = result.valueOrNull!;
      final l10n = await _l10n();
      await ref
          .read(notificationsControllerProvider.notifier)
          .create(
            type: NotificationType.consultationCancelled,
            title: l10n.notificationConsultationCancelledTitle,
            body: l10n.notificationConsultationCancelledBody,
            relatedId: consultation.id,
            // Simplified to the fixed demo client identity — `Consultation`
            // has no `clientId` to derive "the other party" from regardless
            // of who (client or lawyer) initiated the cancellation; a real
            // backend would notify whichever side didn't act.
            recipientUserId: kDemoClientUserId,
          );
    }
    return result;
  }

  Future<Result<Consultation>> reschedule({required String id, required DateTime newDateTime}) async {
    final result = await _repository.reschedule(id: id, newDateTime: newDateTime);
    if (result.isSuccess) await refresh();
    return result;
  }

  Future<Result<Consultation>> complete(String id) async {
    final result = await _repository.complete(id);
    if (result.isSuccess) {
      await refresh();
      final consultation = result.valueOrNull!;
      final l10n = await _l10n();
      await ref
          .read(notificationsControllerProvider.notifier)
          .create(
            type: NotificationType.consultationCompleted,
            title: l10n.notificationConsultationCompletedTitle,
            body: l10n.notificationConsultationCompletedBody,
            relatedId: consultation.id,
            recipientUserId: kDemoClientUserId,
          );
    }
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
