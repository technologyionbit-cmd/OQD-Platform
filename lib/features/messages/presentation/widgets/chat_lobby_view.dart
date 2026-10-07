import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;

import 'package:aqd_ionbit/core/localization/generated/app_localizations.dart';
import 'package:aqd_ionbit/core/theme/app_colors.dart';
import 'package:aqd_ionbit/core/theme/app_spacing.dart';
import 'package:aqd_ionbit/core/widgets/app_card.dart';
import 'package:aqd_ionbit/core/widgets/icon_badge.dart';
import 'package:aqd_ionbit/features/consultations/domain/entities/consultation.dart';
import 'package:aqd_ionbit/features/lawyers/presentation/widgets/consultation_type_x.dart';

/// The chat-specific minimum pre-consultation state — NOT the full shared
/// waiting/lobby screen (that's a later phase): just enough for a written
/// consultation opened before its join window (lawyer/client info,
/// scheduled time, a countdown, disabled composer above/below this) that a
/// tester can see instead of an empty chat room.
class ChatLobbyView extends StatelessWidget {
  const ChatLobbyView({super.key, required this.consultation, required this.isLawyerView});

  final Consultation consultation;
  final bool isLawyerView;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final otherPartyName = isLawyerView ? consultation.clientName : consultation.lawyerName;
    final timeLabel = DateFormat.jm(locale).format(consultation.scheduledAt);
    final dateLabel = DateFormat.yMMMd(locale).format(consultation.scheduledAt);
    final remaining = consultation.scheduledAt.difference(DateTime.now());

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: AppCard(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const IconBadge(icon: Icons.person_outline, size: 56),
              const SizedBox(height: AppSpacing.md),
              Text(otherPartyName, style: Theme.of(context).textTheme.titleMedium, textAlign: TextAlign.center),
              const SizedBox(height: AppSpacing.xxs),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(consultation.type.icon, size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: AppSpacing.xxs),
                  Text(consultation.type.label(l10n), style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              const Divider(),
              const SizedBox(height: AppSpacing.md),
              Text(l10n.chatOpensAt(timeLabel), style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center),
              const SizedBox(height: AppSpacing.xxs),
              Text(dateLabel, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
              if (remaining.inSeconds > 0) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  l10n.chatStartsIn(_remainingLabel(l10n, remaining)),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _remainingLabel(AppLocalizations l10n, Duration remaining) {
    if (remaining.inDays >= 1) return l10n.chatCountdownDays(remaining.inDays);
    if (remaining.inHours >= 1) return l10n.chatCountdownHours(remaining.inHours);
    return l10n.chatCountdownMinutes(remaining.inMinutes.clamp(1, 59));
  }
}
