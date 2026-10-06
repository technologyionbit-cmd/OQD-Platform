import 'package:flutter/material.dart';

import 'package:aqd_ionbit/core/localization/generated/app_localizations.dart';
import 'package:aqd_ionbit/core/widgets/status_badge.dart';
import 'package:aqd_ionbit/features/notifications/domain/entities/app_notification.dart';
import 'package:aqd_ionbit/features/notifications/domain/entities/notification_type.dart';

/// Icon + [AppStatusTone] tint for each notification type — defined once so
/// the notification tile (and any future summary/badge) never duplicates
/// this mapping.
extension NotificationTypeX on NotificationType {
  IconData get icon {
    return switch (this) {
      NotificationType.consultationRequested => Icons.event_available_outlined,
      NotificationType.consultationAccepted => Icons.check_circle_outline,
      NotificationType.consultationRejected => Icons.cancel_outlined,
      NotificationType.consultationCancelled => Icons.event_busy_outlined,
      NotificationType.consultationCompleted => Icons.task_alt_outlined,
      NotificationType.consultationRescheduled => Icons.update_outlined,
      NotificationType.lawyerVerificationApproved => Icons.verified_outlined,
      NotificationType.lawyerVerificationRejected => Icons.gpp_bad_outlined,
    };
  }

  AppStatusTone get tone {
    return switch (this) {
      NotificationType.consultationRequested => AppStatusTone.info,
      NotificationType.consultationAccepted => AppStatusTone.success,
      NotificationType.consultationRejected => AppStatusTone.error,
      NotificationType.consultationCancelled => AppStatusTone.neutral,
      NotificationType.consultationCompleted => AppStatusTone.success,
      NotificationType.consultationRescheduled => AppStatusTone.warning,
      NotificationType.lawyerVerificationApproved => AppStatusTone.success,
      NotificationType.lawyerVerificationRejected => AppStatusTone.error,
    };
  }
}

/// The text is built here, in the reader's current language, from the
/// type and the server's params — never stored as text.
extension AppNotificationText on AppNotification {
  String title(AppLocalizations l10n) {
    return switch (type) {
      NotificationType.consultationRequested => l10n.notificationConsultationRequestedTitle,
      NotificationType.consultationAccepted => l10n.notificationConsultationAcceptedTitle,
      NotificationType.consultationRejected => l10n.notificationConsultationRejectedTitle,
      NotificationType.consultationCancelled => l10n.notificationConsultationCancelledTitle,
      NotificationType.consultationCompleted => l10n.notificationConsultationCompletedTitle,
      NotificationType.consultationRescheduled => l10n.notificationConsultationRescheduledTitle,
      NotificationType.lawyerVerificationApproved => l10n.notificationVerificationApprovedTitle,
      NotificationType.lawyerVerificationRejected => l10n.notificationVerificationRejectedTitle,
    };
  }

  String body(AppLocalizations l10n) {
    final name = params['actorName'] ?? '';
    return switch (type) {
      NotificationType.consultationRequested => l10n.notificationConsultationRequestedBody(name),
      NotificationType.consultationAccepted => l10n.notificationConsultationAcceptedBody(name),
      NotificationType.consultationRejected => l10n.notificationConsultationRejectedBody(name),
      NotificationType.consultationCancelled => l10n.notificationConsultationCancelledBody(name),
      NotificationType.consultationCompleted => l10n.notificationConsultationCompletedBody(name),
      NotificationType.consultationRescheduled => l10n.notificationConsultationRescheduledBody(name),
      NotificationType.lawyerVerificationApproved => l10n.notificationVerificationApprovedBody,
      NotificationType.lawyerVerificationRejected => l10n.notificationVerificationRejectedBody(params['reason'] ?? ''),
    };
  }
}
