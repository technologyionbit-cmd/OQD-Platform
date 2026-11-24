import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aqd_admin/core/localization/generated/app_localizations.dart';
import 'package:aqd_admin/features/auth/presentation/providers/access.dart';
import 'package:aqd_admin/core/utils/formatters.dart';
import 'package:aqd_admin/core/widgets/admin_data_table.dart';
import 'package:aqd_admin/core/widgets/paged_list_screen.dart';
import 'package:aqd_admin/core/widgets/status_chip.dart';
import 'package:aqd_admin/features/notifications/presentation/send_notification_dialog.dart';

class SentNotification {
  const SentNotification({required this.type, required this.recipientName, required this.recipientEmail, required this.createdAt, this.readAt});

  factory SentNotification.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>;
    return SentNotification(
      type: json['type'] as String,
      recipientName: user['fullName'] as String,
      recipientEmail: user['email'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      readAt: json['readAt'] == null ? null : DateTime.parse(json['readAt'] as String),
    );
  }

  final String type;
  final String recipientName;
  final String recipientEmail;
  final DateTime createdAt;
  final DateTime? readAt;
}

String notificationTypeLabel(AppLocalizations l, String s) => switch (s) {
      'consultationRequested' => l.ntConsultationRequested,
      'consultationAccepted' => l.ntConsultationAccepted,
      'consultationRejected' => l.ntConsultationRejected,
      'consultationCancelled' => l.ntConsultationCancelled,
      'consultationCompleted' => l.ntConsultationCompleted,
      'consultationRescheduled' => l.ntConsultationRescheduled,
      'lawyerVerificationApproved' => l.ntLawyerVerificationApproved,
      'lawyerVerificationRejected' => l.ntLawyerVerificationRejected,
      'adminMessage' => l.ntAdminMessage,
      _ => s,
    };

final _query = listQueryProvider('createdAt');
final _page = pagedProvider('/admin/notifications', SentNotification.fromJson, _query);

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return PagedListScreen<SentNotification>(
      actions: [
        if (canManage(ref, 'notifications'))
          FilledButton.icon(onPressed: () => showSendNotificationDialog(context), icon: const Icon(Icons.send_outlined), label: Text(l10n.notifSendTitle)),
      ],
      title: l10n.navNotifications,
      subtitle: l10n.notificationsSubtitle,
      searchHint: l10n.searchNotificationsHint,
      query: _query,
      page: _page,
      filters: [
        FilterSpec(
          key: 'type',
          label: (l) => l.filterType,
          options: (l) => {
            for (final s in [
              'consultationRequested',
              'consultationAccepted',
              'consultationRejected',
              'consultationCancelled',
              'consultationCompleted',
              'consultationRescheduled',
              'lawyerVerificationApproved',
              'lawyerVerificationRejected',
              'adminMessage',
            ])
              s: notificationTypeLabel(l, s),
          },
        ),
        FilterSpec(key: 'read', label: (l) => l.filterRead, options: (l) => {'true': l.readYes, 'false': l.readNo}),
      ],
      columns: [
        AdminColumn(label: l10n.colType, cell: (n) => Text(notificationTypeLabel(l10n, n.type))),
        AdminColumn(label: l10n.colRecipient, cell: (n) => Text(n.recipientName)),
        AdminColumn(label: l10n.colEmail, cell: (n) => Text(n.recipientEmail)),
        AdminColumn(label: l10n.colRead, cell: (n) => StatusChip(label: n.readAt == null ? l10n.readNo : l10n.readYes, tone: n.readAt == null ? StatusTone.neutral : StatusTone.success)),
        AdminColumn(label: l10n.colSent, sortKey: 'createdAt', cell: (n) => Text(formatDateTime(context, n.createdAt))),
      ],
    );
  }
}
