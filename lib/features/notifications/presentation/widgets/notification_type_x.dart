import 'package:flutter/material.dart';

import 'package:aqd_ionbit/core/widgets/status_badge.dart';
import 'package:aqd_ionbit/features/notifications/domain/entities/notification_type.dart';

/// Icon + [AppStatusTone] tint for each notification type — defined once so
/// the notification tile (and any future summary/badge) never duplicates
/// this mapping.
extension NotificationTypeX on NotificationType {
  IconData get icon {
    return switch (this) {
      NotificationType.contractCreated => Icons.description_outlined,
      NotificationType.contractUpdated => Icons.edit_note_outlined,
      NotificationType.contractReady => Icons.task_alt_outlined,
      NotificationType.contractRequiresAction => Icons.error_outline,
      NotificationType.consultationBooked => Icons.event_available_outlined,
      NotificationType.consultationAccepted => Icons.check_circle_outline,
      NotificationType.consultationRejected => Icons.cancel_outlined,
      NotificationType.consultationCancelled => Icons.event_busy_outlined,
      NotificationType.consultationCompleted => Icons.task_alt_outlined,
      NotificationType.consultationReminder => Icons.notifications_active_outlined,
      NotificationType.newMessage => Icons.chat_bubble_outline,
      NotificationType.documentUploaded => Icons.upload_file_outlined,
      NotificationType.aiAnalysisCompleted => Icons.smart_toy_outlined,
    };
  }

  AppStatusTone get tone {
    return switch (this) {
      NotificationType.contractCreated => AppStatusTone.info,
      NotificationType.contractUpdated => AppStatusTone.info,
      NotificationType.contractReady => AppStatusTone.success,
      NotificationType.contractRequiresAction => AppStatusTone.warning,
      NotificationType.consultationBooked => AppStatusTone.info,
      NotificationType.consultationAccepted => AppStatusTone.success,
      NotificationType.consultationRejected => AppStatusTone.error,
      NotificationType.consultationCancelled => AppStatusTone.neutral,
      NotificationType.consultationCompleted => AppStatusTone.success,
      NotificationType.consultationReminder => AppStatusTone.warning,
      NotificationType.newMessage => AppStatusTone.info,
      NotificationType.documentUploaded => AppStatusTone.neutral,
      NotificationType.aiAnalysisCompleted => AppStatusTone.success,
    };
  }
}
