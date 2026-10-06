import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aqd_ionbit/features/auth/presentation/providers/current_user_id_provider.dart';
import 'package:aqd_ionbit/features/notifications/data/repositories/notifications_repository_impl.dart';
import 'package:aqd_ionbit/features/notifications/domain/entities/app_notification.dart';
import 'package:aqd_ionbit/features/notifications/domain/repositories/notifications_repository.dart';

/// The notification center's list. The server creates notifications and
/// returns only the signed-in account's own, so this controller only
/// reads, marks and deletes.
class NotificationsController extends AsyncNotifier<List<AppNotification>> {
  NotificationsRepository get _repository => ref.read(notificationsRepositoryProvider);

  @override
  FutureOr<List<AppNotification>> build() async {
    ref.watch(notificationsRepositoryProvider);
    if (ref.watch(currentUserIdProvider) == null) return const []; // Signed out: no one's data.
    final result = await _repository.getNotifications();
    return result.fold((failure) => throw failure, (notifications) => notifications);
  }

  Future<void> refresh() async {
    final result = await _repository.getNotifications();
    state = result.fold((failure) => AsyncError(failure, StackTrace.current), AsyncData.new);
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
}

final notificationsControllerProvider = AsyncNotifierProvider<NotificationsController, List<AppNotification>>(NotificationsController.new);

/// Badge count for the bell icon on every role's home header — `0` while
/// loading or on error rather than showing a stale or wrong number.
final unreadNotificationsCountProvider = Provider<int>((ref) {
  final notifications = ref.watch(notificationsControllerProvider).value;
  if (notifications == null) return 0;
  return notifications.where((n) => !n.isRead).length;
});
