import 'package:aqd_ionbit/features/notifications/domain/entities/app_notification.dart';
import 'package:aqd_ionbit/features/notifications/domain/entities/notification_type.dart';

/// Wire-level contract for the notifications feature. Mirrors
/// `ContractsRemoteDataSource` — throws a [Failure] on any failure path,
/// never a raw exception, so swapping in a real backend/push-notification
/// service later is a same-signature change.
abstract interface class NotificationsRemoteDataSource {
  Future<List<AppNotification>> getNotifications();

  Future<void> markAsRead(String id);

  Future<void> markAllAsRead();

  Future<void> deleteNotification(String id);

  Future<AppNotification> create({
    required NotificationType type,
    required String title,
    required String body,
    String? relatedId,
    String? recipientUserId,
  });
}
