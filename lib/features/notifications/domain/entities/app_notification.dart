import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:aqd_ionbit/features/notifications/domain/entities/notification_type.dart';

part 'app_notification.freezed.dart';

/// One notification for the signed-in account. The server writes it and
/// scopes the list to its recipient; the app never creates one.
@freezed
abstract class AppNotification with _$AppNotification {
  const factory AppNotification({
    required String id,
    required NotificationType type,
    required DateTime createdAt,
    @Default(false) bool isRead,
    /// Id of the entity this notification is about (for now always a
    /// consultation) — the presentation layer maps `(type, relatedId)` to
    /// a route; this stays a plain id so it never needs to know about
    /// routing.
    String? relatedId,
    /// Values the text needs, e.g. `actorName` (who did it) and
    /// `scheduledAt` (ISO 8601).
    @Default(<String, String>{}) Map<String, String> params,
  }) = _AppNotification;
}
