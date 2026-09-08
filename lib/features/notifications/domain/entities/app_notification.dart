import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:aqd_ionbit/features/notifications/domain/entities/notification_type.dart';

part 'app_notification.freezed.dart';

@freezed
abstract class AppNotification with _$AppNotification {
  const factory AppNotification({
    required String id,
    required NotificationType type,
    required String title,
    required String body,
    required DateTime createdAt,
    @Default(false) bool isRead,
    /// Id of the entity this notification is about (contract id,
    /// consultation id, analysis id, ...) — the presentation layer maps
    /// `(type, relatedId)` to an actual route; this stays a plain id so it
    /// never needs to know about routing.
    String? relatedId,
    /// The `AuthUser.id` this notification is meant for. `null` means
    /// legacy/broadcast (kept visible to everyone rather than silently
    /// dropped) — every notification created going forward should set this,
    /// so `NotificationsController` can filter the single shared mock list
    /// down to "what the current role should actually see" instead of every
    /// role seeing every other role's notifications.
    String? recipientUserId,
  }) = _AppNotification;
}
