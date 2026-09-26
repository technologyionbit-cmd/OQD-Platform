import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:aqd_ionbit/core/localization/generated/app_localizations.dart';
import 'package:aqd_ionbit/core/providers/notifications_settings_controller.dart';
import 'package:aqd_ionbit/core/routing/route_paths.dart';
import 'package:aqd_ionbit/core/theme/app_spacing.dart';
import 'package:aqd_ionbit/core/widgets/empty_state.dart';
import 'package:aqd_ionbit/core/widgets/error_view.dart';
import 'package:aqd_ionbit/core/widgets/loading_view.dart';
import 'package:aqd_ionbit/features/auth/domain/entities/user_role.dart';
import 'package:aqd_ionbit/features/auth/presentation/providers/auth_controller.dart';
import 'package:aqd_ionbit/features/notifications/domain/entities/app_notification.dart';
import 'package:aqd_ionbit/features/notifications/domain/entities/notification_type.dart';
import 'package:aqd_ionbit/features/notifications/presentation/providers/notifications_controller.dart';
import 'package:aqd_ionbit/features/notifications/presentation/widgets/notification_tile.dart';

/// Shared by all three roles — each role's route file mounts this same
/// screen at its own `/<role>/notifications` path (guard-covered by that
/// role's base), since the underlying notification list isn't role-scoped
/// in this single-session mock backend.
class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  /// Maps a notification to where tapping it should go, based on the
  /// current role's route subtree. Returns null for types that don't have
  /// a destination yet — the tap still marks it read, it just doesn't
  /// navigate anywhere.
  String? _routeFor(AppNotification notification, UserRole role) {
    final id = notification.relatedId;
    switch (notification.type) {
      case NotificationType.contractCreated:
      case NotificationType.contractUpdated:
      case NotificationType.contractReady:
      case NotificationType.contractRequiresAction:
        if (id == null) return null;
        return switch (role) {
          UserRole.client => RoutePaths.clientContractDetails(id),
          UserRole.company => RoutePaths.companyContractDetails(id),
          // A lawyer only ever sees a client's contract read-only, but that
          // route does exist (lawyerContractDetailsPattern) — she should
          // land on it like everyone else, not hit a dead end.
          UserRole.lawyer => RoutePaths.lawyerContractDetails(id),
        };
      case NotificationType.consultationBooked:
      case NotificationType.consultationAccepted:
      case NotificationType.consultationRejected:
      case NotificationType.consultationCancelled:
      case NotificationType.consultationCompleted:
      case NotificationType.consultationReminder:
        if (id == null) return null;
        return switch (role) {
          UserRole.client => RoutePaths.clientConsultationDetails(id),
          UserRole.lawyer => RoutePaths.lawyerConsultationDetails(id),
          UserRole.company => RoutePaths.companyConsultationDetails(id),
        };
      case NotificationType.newMessage:
        // A "new chat message" notification should open the chat itself,
        // not a detour through the consultation details screen.
        if (id == null) return null;
        return switch (role) {
          UserRole.client => RoutePaths.chatRoomFor(RoutePaths.clientBase, id),
          UserRole.lawyer => RoutePaths.chatRoomFor(RoutePaths.lawyerBase, id),
          UserRole.company => RoutePaths.chatRoomFor(RoutePaths.companyBase, id),
        };
      case NotificationType.documentUploaded:
        return switch (role) {
          UserRole.client => RoutePaths.clientDocuments,
          UserRole.company => RoutePaths.companyDocuments,
          UserRole.lawyer => RoutePaths.lawyerDocuments,
        };
      case NotificationType.aiAnalysisCompleted:
        if (id == null) return null;
        return role == UserRole.client ? RoutePaths.clientAiAnalysisResult(id) : null;
    }
  }

  Future<void> _handleTap(BuildContext context, WidgetRef ref, AppNotification notification) async {
    await ref.read(notificationsControllerProvider.notifier).markAsRead(notification.id);
    if (!context.mounted) return;
    final role = ref.read(authControllerProvider).value?.role;
    if (role == null) return;
    final route = _routeFor(notification, role);
    if (route != null) {
      unawaited(context.push(route));
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.notificationUnavailableForRole)),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final notificationsState = ref.watch(notificationsControllerProvider);
    final hasUnread = notificationsState.value?.any((n) => !n.isRead) ?? false;
    final notificationsEnabled = ref.watch(notificationsSettingsControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.clientNotificationsTitle),
        actions: [
          if (hasUnread)
            TextButton(
              onPressed: () => ref.read(notificationsControllerProvider.notifier).markAllAsRead(),
              child: Text(l10n.notificationsMarkAllRead),
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            SwitchListTile(
              title: Text(l10n.accountNotificationsSetting),
              value: notificationsEnabled,
              onChanged: (value) => ref.read(notificationsSettingsControllerProvider.notifier).setEnabled(value),
            ),
            const Divider(height: 1),
            Expanded(
              child: switch (notificationsState) {
                AsyncData(value: final notifications) when notifications.isEmpty => EmptyState(
                  icon: Icons.notifications_none_outlined,
                  title: l10n.notificationsEmptyTitle,
                  message: l10n.notificationsEmptyMessage,
                ),
                AsyncData(value: final notifications) => RefreshIndicator(
                  onRefresh: () => ref.read(notificationsControllerProvider.notifier).refresh(),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    itemCount: notifications.length,
                    separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.xs),
                    itemBuilder: (context, index) {
                      final notification = notifications[index];
                      return NotificationTile(
                        notification: notification,
                        onTap: () => _handleTap(context, ref, notification),
                        onDismiss: () => ref.read(notificationsControllerProvider.notifier).deleteNotification(notification.id),
                      );
                    },
                  ),
                ),
                AsyncError() => ErrorView(
                  message: l10n.errorGeneric,
                  onRetry: () => ref.read(notificationsControllerProvider.notifier).refresh(),
                ),
                _ => const LoadingView(),
              },
            ),
          ],
        ),
      ),
    );
  }
}
