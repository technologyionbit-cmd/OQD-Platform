import 'package:aqd_ionbit/features/notifications/data/datasources/notifications_remote_data_source.dart';
import 'package:aqd_ionbit/features/notifications/domain/entities/app_notification.dart';
import 'package:aqd_ionbit/features/notifications/domain/entities/notification_type.dart';

/// In-memory stand-in for tests. Seeded with a few notifications for the
/// signed-in account; like the server, it only ever returns that
/// account's own list.
class NotificationsMockDataSource implements NotificationsRemoteDataSource {
  final List<AppNotification> _notifications = [
    AppNotification(
      id: 'n_seed_1',
      type: NotificationType.consultationAccepted,
      createdAt: DateTime.now().subtract(const Duration(minutes: 20)),
      relatedId: 'cons_seed_1',
      params: const {'actorName': 'سارة المطيري'},
    ),
    AppNotification(
      id: 'n_seed_2',
      type: NotificationType.consultationRequested,
      createdAt: DateTime.now().subtract(const Duration(hours: 6)),
      relatedId: 'cons_seed_2',
      params: const {'actorName': 'أحمد الخالدي'},
    ),
    AppNotification(
      id: 'n_seed_3',
      type: NotificationType.consultationCompleted,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      isRead: true,
      relatedId: 'cons_seed_3',
      params: const {'actorName': 'سارة المطيري'},
    ),
  ];

  @override
  Future<List<AppNotification>> getNotifications() async {
    await _simulateLatency();
    final sorted = List<AppNotification>.of(_notifications)..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted;
  }

  @override
  Future<void> markAsRead(String id) async {
    await _simulateLatency();
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index == -1) return;
    _notifications[index] = _notifications[index].copyWith(isRead: true);
  }

  @override
  Future<void> markAllAsRead() async {
    await _simulateLatency();
    for (var i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isRead: true);
    }
  }

  @override
  Future<void> deleteNotification(String id) async {
    await _simulateLatency();
    _notifications.removeWhere((n) => n.id == id);
  }

  Future<void> _simulateLatency() => Future.delayed(const Duration(milliseconds: 300));
}
