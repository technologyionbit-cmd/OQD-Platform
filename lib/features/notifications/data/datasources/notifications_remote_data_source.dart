import 'package:aqd_ionbit/features/notifications/domain/entities/app_notification.dart';

/// Wire-level contract for the notifications feature. Throws a [Failure]
/// on any failure path, never a raw exception. The server creates
/// notifications itself, so the app can only read, mark and delete.
abstract interface class NotificationsRemoteDataSource {
  Future<List<AppNotification>> getNotifications();

  Future<void> markAsRead(String id);

  Future<void> markAllAsRead();

  Future<void> deleteNotification(String id);
}
