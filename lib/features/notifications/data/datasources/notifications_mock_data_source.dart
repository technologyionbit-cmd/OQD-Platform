import 'package:aqd_ionbit/features/auth/domain/entities/auth_user.dart';
import 'package:aqd_ionbit/features/notifications/data/datasources/notifications_remote_data_source.dart';
import 'package:aqd_ionbit/features/notifications/domain/entities/app_notification.dart';
import 'package:aqd_ionbit/features/notifications/domain/entities/notification_type.dart';

/// Temporary, isolated stand-in for the real backend/push-notification
/// service. Seeded with a few demo notifications so the center isn't empty
/// on first run; every real action taken during the session (contract
/// generated, booking accepted, ...) is added for real via [create] —
/// called from each feature's controller once its own mutation succeeds.
class NotificationsMockDataSource implements NotificationsRemoteDataSource {
  final List<AppNotification> _notifications = [
    AppNotification(
      id: 'n_seed_1',
      type: NotificationType.consultationReminder,
      title: 'موعد استشارة قريب',
      body: 'لديك استشارة محجوزة خلال 30 دقيقة مع المحامية سارة المطيري',
      createdAt: DateTime.now().subtract(const Duration(minutes: 20)),
      relatedId: 'cons_seed_1',
      recipientUserId: kDemoClientUserId,
    ),
    AppNotification(
      id: 'n_seed_2',
      type: NotificationType.contractReady,
      title: 'عقدك جاهز',
      body: 'تم إنشاء "عقد خدمات — شركة الأفق" بنجاح وهو متاح الآن في خزنتك الرقمية',
      createdAt: DateTime.now().subtract(const Duration(hours: 6)),
      relatedId: 'c_seed_1',
      recipientUserId: kDemoClientUserId,
    ),
    AppNotification(
      id: 'n_seed_3',
      type: NotificationType.newMessage,
      title: 'رسالة جديدة',
      body: 'راسلك المحامي بخصوص استشارتك المكتوبة',
      createdAt: DateTime.now().subtract(const Duration(hours: 9)),
      isRead: true,
      relatedId: 'cons_seed_2',
      recipientUserId: kDemoClientUserId,
    ),
    AppNotification(
      id: 'n_seed_4',
      type: NotificationType.documentUploaded,
      title: 'تم رفع مستند',
      body: 'تمت إضافة مستند جديد إلى خزنتك الرقمية',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      isRead: true,
      recipientUserId: kDemoClientUserId,
    ),
    AppNotification(
      id: 'n_seed_5',
      type: NotificationType.contractRequiresAction,
      title: 'مسودة عقد بانتظارك',
      body: 'لديك مسودة "عقد إيجار شقة سكنية" لم تكتمل بعد',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      isRead: true,
      relatedId: 'c_seed_2',
      recipientUserId: kDemoClientUserId,
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

  @override
  Future<AppNotification> create({
    required NotificationType type,
    required String title,
    required String body,
    String? relatedId,
    String? recipientUserId,
  }) async {
    await _simulateLatency();
    final notification = AppNotification(
      id: 'n_${DateTime.now().microsecondsSinceEpoch}',
      type: type,
      title: title,
      body: body,
      createdAt: DateTime.now(),
      relatedId: relatedId,
      recipientUserId: recipientUserId,
    );
    _notifications.insert(0, notification);
    return notification;
  }

  Future<void> _simulateLatency() => Future.delayed(const Duration(milliseconds: 300));
}
