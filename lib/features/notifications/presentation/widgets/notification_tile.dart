import 'package:flutter/material.dart';

import 'package:aqd_ionbit/core/localization/generated/app_localizations.dart';
import 'package:aqd_ionbit/core/theme/app_colors.dart';
import 'package:aqd_ionbit/core/theme/app_radii.dart';
import 'package:aqd_ionbit/core/theme/app_spacing.dart';
import 'package:aqd_ionbit/core/theme/app_status_colors.dart';
import 'package:aqd_ionbit/core/utils/time_ago.dart';
import 'package:aqd_ionbit/core/widgets/status_badge.dart';
import 'package:aqd_ionbit/features/notifications/domain/entities/app_notification.dart';
import 'package:aqd_ionbit/features/notifications/presentation/widgets/notification_type_x.dart';

/// One row in the notification center — unread rows get a tinted
/// background and a leading dot so the list communicates read state at a
/// glance, not just via the icon color.
class NotificationTile extends StatelessWidget {
  const NotificationTile({super.key, required this.notification, required this.onTap, required this.onDismiss});

  final AppNotification notification;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final tone = notification.type.tone.resolve(context);

    return Dismissible(
      key: ValueKey(notification.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismiss(),
      background: Container(
        alignment: AlignmentDirectional.centerEnd,
        padding: const EdgeInsetsDirectional.only(end: AppSpacing.lg),
        decoration: BoxDecoration(color: context.statusColors.error.background, borderRadius: AppRadii.mdRadius),
        child: Icon(Icons.delete_outline, color: context.statusColors.error.foreground),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.mdRadius,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: notification.isRead ? AppColors.surface : AppColors.primary.withValues(alpha: 0.05),
            borderRadius: AppRadii.mdRadius,
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: tone.background, borderRadius: AppRadii.mdRadius),
                child: Icon(notification.type.icon, color: tone.foreground, size: 22),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title(l10n),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.w700,
                            ),
                          ),
                        ),
                        if (!notification.isRead) ...[
                          const SizedBox(width: AppSpacing.xxs),
                          Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle)),
                        ],
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      notification.body(l10n),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      formatTimeAgo(notification.createdAt, l10n),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.textDisabled),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
