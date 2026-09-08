import 'package:aqd_ionbit/core/localization/generated/app_localizations.dart';
import 'package:aqd_ionbit/core/widgets/status_badge.dart';
import 'package:aqd_ionbit/features/consultations/domain/entities/consultation_status.dart';

extension ConsultationStatusDisplayX on ConsultationStatus {
  String label(AppLocalizations l10n) {
    return switch (this) {
      ConsultationStatus.pendingApproval => l10n.consultationStatusPending,
      // Reuses the pre-existing "Upcoming" copy — [ConsultationStatus.confirmed]
      // is the direct successor of the old `upcoming` value and this is still
      // the label a client/lawyer sees for a booked, not-yet-live consultation.
      ConsultationStatus.confirmed => l10n.consultationStatusUpcoming,
      ConsultationStatus.waiting => l10n.consultationStatusWaiting,
      ConsultationStatus.ready => l10n.consultationStatusReady,
      ConsultationStatus.connecting => l10n.consultationStatusConnecting,
      ConsultationStatus.active => l10n.consultationStatusActive,
      ConsultationStatus.ended => l10n.consultationStatusEnded,
      ConsultationStatus.completed => l10n.consultationStatusCompleted,
      ConsultationStatus.cancelled => l10n.consultationStatusCancelled,
      // Reuses the pre-existing "Rejected" copy for the renamed `declined`
      // value — same user-facing meaning as the old `rejected` status.
      ConsultationStatus.declined => l10n.consultationStatusRejected,
      ConsultationStatus.missed => l10n.consultationStatusMissed,
      ConsultationStatus.failed => l10n.consultationStatusFailed,
    };
  }

  AppStatusTone get tone {
    return switch (this) {
      ConsultationStatus.pendingApproval => AppStatusTone.warning,
      ConsultationStatus.confirmed => AppStatusTone.info,
      ConsultationStatus.waiting => AppStatusTone.info,
      ConsultationStatus.ready => AppStatusTone.info,
      ConsultationStatus.connecting => AppStatusTone.warning,
      ConsultationStatus.active => AppStatusTone.success,
      ConsultationStatus.ended => AppStatusTone.neutral,
      ConsultationStatus.completed => AppStatusTone.success,
      ConsultationStatus.cancelled => AppStatusTone.neutral,
      ConsultationStatus.declined => AppStatusTone.error,
      ConsultationStatus.missed => AppStatusTone.error,
      ConsultationStatus.failed => AppStatusTone.error,
    };
  }
}
