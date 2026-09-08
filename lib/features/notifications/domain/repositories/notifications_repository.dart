import 'package:aqd_ionbit/core/errors/result.dart';
import 'package:aqd_ionbit/features/notifications/domain/entities/app_notification.dart';
import 'package:aqd_ionbit/features/notifications/domain/entities/notification_type.dart';

abstract interface class NotificationsRepository {
  Future<Result<List<AppNotification>>> getNotifications();

  Future<Result<void>> markAsRead(String id);

  Future<Result<void>> markAllAsRead();

  Future<Result<void>> deleteNotification(String id);

  /// Called by other features' controllers when something notification-worthy
  /// happens (contract generated, booking accepted, ...) — see
  /// `NotificationsController.create` for the presentation-layer entry point.
  Future<Result<AppNotification>> create({
    required NotificationType type,
    required String title,
    required String body,
    String? relatedId,
    String? recipientUserId,
  });
}
