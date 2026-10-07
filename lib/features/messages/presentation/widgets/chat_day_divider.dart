import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;

import 'package:aqd_ionbit/core/localization/generated/app_localizations.dart';
import 'package:aqd_ionbit/core/theme/app_colors.dart';
import 'package:aqd_ionbit/core/theme/app_radii.dart';
import 'package:aqd_ionbit/core/theme/app_spacing.dart';

/// A pill label grouping the messages below it by calendar date — "Today"/
/// "Yesterday" for the two most recent days, the full localized date
/// otherwise. [date] must already be normalized to midnight (year/month/day
/// only), which `ChatRoomScreen` does when it groups the transcript.
class ChatDayDivider extends StatelessWidget {
  const ChatDayDivider({super.key, required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    final label = date == today
        ? l10n.chatDayToday
        : date == yesterday
        ? l10n.chatDayYesterday
        : DateFormat.yMMMd(locale).format(date);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xxs),
          decoration: const BoxDecoration(color: AppColors.surfaceVariant, borderRadius: AppRadii.smRadius),
          child: Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }
}
