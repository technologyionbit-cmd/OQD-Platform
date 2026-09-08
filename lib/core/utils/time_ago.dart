import 'package:aqd_ionbit/core/localization/generated/app_localizations.dart';

/// Relative "5m ago" / "قبل 5 دقائق" formatting shared by notifications,
/// consultation messages, and activity feeds — one place instead of each
/// screen hand-rolling its own duration math.
String formatTimeAgo(DateTime dateTime, AppLocalizations l10n) {
  final difference = DateTime.now().difference(dateTime);
  if (difference.inMinutes < 1) return l10n.commonJustNow;
  if (difference.inMinutes < 60) return l10n.commonMinutesAgo(difference.inMinutes);
  if (difference.inHours < 24) return l10n.commonHoursAgo(difference.inHours);
  return l10n.commonDaysAgo(difference.inDays);
}
