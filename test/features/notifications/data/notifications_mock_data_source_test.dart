import 'package:flutter_test/flutter_test.dart';

import 'package:aqd_ionbit/features/notifications/data/datasources/notifications_mock_data_source.dart';
import 'package:aqd_ionbit/features/notifications/domain/entities/notification_type.dart';

void main() {
  late NotificationsMockDataSource dataSource;

  setUp(() => dataSource = NotificationsMockDataSource());

  test('getNotifications returns the seeded notifications sorted by most-recent first', () async {
    final notifications = await dataSource.getNotifications();

    expect(notifications.length, 5);
    for (var i = 1; i < notifications.length; i++) {
      expect(notifications[i - 1].createdAt.isAfter(notifications[i].createdAt) || notifications[i - 1].createdAt.isAtSameMomentAs(notifications[i].createdAt), isTrue);
    }
  });

  test('markAsRead flips only the targeted notification', () async {
    await dataSource.markAsRead('n_seed_1');
    final notifications = await dataSource.getNotifications();

    final target = notifications.firstWhere((n) => n.id == 'n_seed_1');
    expect(target.isRead, isTrue);
  });

  test('markAllAsRead flips every notification', () async {
    await dataSource.markAllAsRead();
    final notifications = await dataSource.getNotifications();

    expect(notifications.every((n) => n.isRead), isTrue);
  });

  test('deleteNotification removes it from the list', () async {
    final before = await dataSource.getNotifications();
    await dataSource.deleteNotification('n_seed_1');
    final after = await dataSource.getNotifications();

    expect(after.length, before.length - 1);
    expect(after.any((n) => n.id == 'n_seed_1'), isFalse);
  });

  test('create inserts a new unread notification at the top', () async {
    final created = await dataSource.create(
      type: NotificationType.contractReady,
      title: 'عنوان',
      body: 'نص',
      relatedId: 'c_1',
    );

    expect(created.isRead, isFalse);
    final notifications = await dataSource.getNotifications();
    expect(notifications.first.id, created.id);
  });
}
