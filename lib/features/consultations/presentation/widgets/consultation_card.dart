import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' show DateFormat;

import 'package:aqd_ionbit/core/localization/generated/app_localizations.dart';
import 'package:aqd_ionbit/core/theme/app_colors.dart';
import 'package:aqd_ionbit/core/theme/app_spacing.dart';
import 'package:aqd_ionbit/core/theme/app_status_colors.dart';
import 'package:aqd_ionbit/core/widgets/app_card.dart';
import 'package:aqd_ionbit/core/widgets/icon_badge.dart';
import 'package:aqd_ionbit/core/widgets/status_badge.dart';
import 'package:aqd_ionbit/features/consultations/domain/entities/consultation.dart';
import 'package:aqd_ionbit/features/consultations/presentation/widgets/consultation_status_x.dart';
import 'package:aqd_ionbit/features/lawyers/presentation/widgets/consultation_type_x.dart';
import 'package:aqd_ionbit/features/messages/presentation/providers/chat_unread_controller.dart';

/// One row for a consultation/booking — shows the *other* party's name
/// ([showLawyerName] true for the client/company view, false for the
/// lawyer-side view where the client's name is the useful one instead).
/// Carries a small unread-chat-message badge (see `chatUnreadCountForProvider`)
/// next to the status pill when this consultation's written-chat thread has
/// unread messages from the other party.
class ConsultationCard extends ConsumerWidget {
  const ConsultationCard({super.key, required this.consultation, required this.onTap, this.showLawyerName = true});

  final Consultation consultation;
  final VoidCallback onTap;
  final bool showLawyerName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final unreadCount = ref.watch(chatUnreadCountForProvider(consultation.id));
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          IconBadge(icon: consultation.type.icon, size: 44),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  showLawyerName ? consultation.lawyerName : consultation.clientName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  '${consultation.type.label(l10n)} · ${DateFormat.yMMMd(locale).add_jm().format(consultation.scheduledAt)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          if (unreadCount > 0) ...[
            Container(
              padding: const EdgeInsets.all(AppSpacing.xxs),
              decoration: BoxDecoration(color: context.statusColors.error.foreground, shape: BoxShape.circle),
              constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
              alignment: Alignment.center,
              child: Text(
                unreadCount > 9 ? '9+' : '$unreadCount',
                style: const TextStyle(color: AppColors.onPrimary, fontSize: 11, fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
          ],
          Flexible(child: StatusBadge(label: consultation.status.label(l10n), tone: consultation.status.tone)),
        ],
      ),
    );
  }
}
