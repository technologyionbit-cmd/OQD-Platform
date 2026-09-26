import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aqd_ionbit/features/auth/presentation/providers/auth_controller.dart';
import 'package:aqd_ionbit/features/notifications/data/repositories/notifications_repository_impl.dart';
import 'package:aqd_ionbit/features/notifications/domain/entities/app_notification.dart';
import 'package:aqd_ionbit/features/notifications/domain/entities/notification_type.dart';
import 'package:aqd_ionbit/features/notifications/domain/repositories/notifications_repository.dart';

/// The notification center's list — every other feature that wants to
/// notify the user calls [create] on this (via
/// `ref.read(notificationsControllerProvider.notifier)`) once its own
/// mutation succeeds, instead of talking to the repository directly.
///
/// The underlying mock data source is a single global, unscoped list (see
/// its own doc) — this controller is what turns that into a per-role view,
/// filtering to notifications meant for the current user (or with no
/// recipient at all, i.e. legacy/broadcast) so a lawyer never sees a
/// client-only notification and vice versa.
class NotificationsController extends AsyncNotifier<List<AppNotification>> {
  late final NotificationsRepository _repository;

  @override
  FutureOr<List<AppNotification>> build() async {
    _repository = ref.watch(notificationsRepositoryProvider);
    final result = await _repository.getNotifications();
    return result.fold((failure) => throw failure, _scopedToCurrentUser);
  }

  Future<void> refresh() async {
    final result = await _repository.getNotifications();
    state = result.fold(
      (failure) => AsyncError(failure, StackTrace.current),
      (notifications) => AsyncData(_scopedToCurrentUser(notifications)),
    );
  }

  List<AppNotification> _scopedToCurrentUser(List<AppNotification> notifications) {
    final currentUserId = ref.read(authControllerProvider).value?.id;
    return [for (final n in notifications) if (n.recipientUserId == null || n.recipientUserId == currentUserId) n];
  }

  Future<void> markAsRead(String id) async {
    final current = state.value;
    if (current == null) return;
    // Optimistic local update — a full refresh() round-trip for something
    // this minor would make every notification tap feel laggy.
    state = AsyncData([for (final n in current) if (n.id == id) n.copyWith(isRead: true) else n]);
    final result = await _repository.markAsRead(id);
    if (result.isFailure) await refresh();
  }

  Future<void> markAllAsRead() async {
    final current = state.value;
    if (current == null) return;
    state = AsyncData([for (final n in current) n.copyWith(isRead: true)]);
    final result = await _repository.markAllAsRead();
    if (result.isFailure) await refresh();
  }

  Future<void> deleteNotification(String id) async {
    final current = state.value;
    if (current == null) return;
    state = AsyncData([for (final n in current) if (n.id != id) n]);
    final result = await _repository.deleteNotification(id);
    if (result.isFailure) await refresh();
  }

  Future<void> create({
    required NotificationType type,
    required String title,
    required String body,
    String? relatedId,
    String? recipientUserId,
  }) async {
    final result = await _repository.create(type: type, title: title, body: body, relatedId: relatedId, recipientUserId: recipientUserId);
    // Prepend locally instead of a full refresh() round-trip — every other
    // feature that calls this already waited out its own mutation's
    // latency, so a second full re-fetch here would just double the delay
    // the caller (and, for the call-ending flows, the session/timer
    // choreography built around it) has to sit through for no benefit: the
    // repository already handed back the created notification in full.
    //
    // Only prepend into *this* controller's own state if the notification
    // is actually meant for the currently signed-in user — e.g. a lawyer
    // accepting a request creates a notification for the *client*, and the
    // lawyer's own list must not locally show it just because her own
    // `create()` call is the one that produced it.
    final current = state.value;
    final currentUserId = ref.read(authControllerProvider).value?.id;
    result.fold((failure) => null, (notification) {
      final isForCurrentUser = notification.recipientUserId == null || notification.recipientUserId == currentUserId;
      if (current != null && isForCurrentUser) state = AsyncData([notification, ...current]);
    });
    if (result.isFailure || current == null) await refresh();
  }
}

final notificationsControllerProvider = AsyncNotifierProvider<NotificationsController, List<AppNotification>>(NotificationsController.new);

/// Dynamic badge count for the bell icon on every role's home header —
/// `0` while loading/on error rather than showing a stale or wrong number.
final unreadNotificationsCountProvider = Provider<int>((ref) {
  final notifications = ref.watch(notificationsControllerProvider).value;
  if (notifications == null) return 0;
  return notifications.where((n) => !n.isRead).length;
});
