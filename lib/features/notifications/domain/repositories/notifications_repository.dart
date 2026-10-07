import 'package:aqd_ionbit/core/errors/result.dart';
import 'package:aqd_ionbit/features/notifications/domain/entities/app_notification.dart';

abstract interface class NotificationsRepository {
  Future<Result<List<AppNotification>>> getNotifications();

  Future<Result<void>> markAsRead(String id);

  Future<Result<void>> markAllAsRead();

  Future<Result<void>> deleteNotification(String id);
}
