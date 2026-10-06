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
import 'package:aqd_ionbit/features/lawyers/presentation/providers/my_lawyer_profile_provider.dart';
import 'package:aqd_ionbit/features/notifications/domain/entities/app_notification.dart';
import 'package:aqd_ionbit/features/notifications/domain/entities/notification_type.dart';
import 'package:aqd_ionbit/features/notifications/presentation/providers/notifications_controller.dart';
import 'package:aqd_ionbit/features/notifications/presentation/widgets/notification_tile.dart';

/// Shared by all three roles — each role's route file mounts this same
/// screen at its own `/<role>/notifications` path (guard-covered by that
/// role's base). The server returns only the signed-in account's list.
class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  /// Where tapping a notification goes in the current role's route
  /// subtree. Null when there is nothing to open — the tap still marks it
  /// read.
  String? _routeFor(AppNotification notification, UserRole role) {
    final type = notification.type;
    if (type == NotificationType.lawyerVerificationApproved || type == NotificationType.lawyerVerificationRejected) {
      return role == UserRole.lawyer ? RoutePaths.lawyerProfileEdit : null;
    }
    final id = notification.relatedId;
    if (id == null) return null;
    return switch (type) {
      NotificationType.consultationRequested ||
      NotificationType.consultationAccepted ||
      NotificationType.consultationRejected ||
      NotificationType.consultationCancelled ||
      NotificationType.consultationCompleted ||
      NotificationType.consultationRescheduled => switch (role) {
        UserRole.client => RoutePaths.clientConsultationDetails(id),
        UserRole.lawyer => RoutePaths.lawyerConsultationDetails(id),
        UserRole.company => RoutePaths.companyConsultationDetails(id),
      },
      NotificationType.lawyerVerificationApproved || NotificationType.lawyerVerificationRejected => null,
    };
  }

  Future<void> _handleTap(BuildContext context, WidgetRef ref, AppNotification notification) async {
    await ref.read(notificationsControllerProvider.notifier).markAsRead(notification.id);
    if (!context.mounted) return;
    final role = ref.read(authControllerProvider).value?.role;
    if (role == null) return;
    final route = _routeFor(notification, role);
    // A verification result changes the lawyer's own profile: reload it so
    // the screen it opens shows the new status.
    if (notification.type == NotificationType.lawyerVerificationApproved ||
        notification.type == NotificationType.lawyerVerificationRejected) {
      ref.invalidate(myLawyerProfileProvider);
    }
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
