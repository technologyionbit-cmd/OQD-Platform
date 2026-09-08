import 'package:intl/intl.dart' show DateFormat;

import 'package:aqd_ionbit/core/localization/generated/app_localizations.dart';
import 'package:aqd_ionbit/core/utils/time_ago.dart';

/// A message bubble's timestamp label. The default (`absolute: false`)
/// follows the chat convention: under an hour old shows relative time
/// ("5m ago"), older-but-same-day shows the clock time, anything older
/// shows the full date. Tapping the timestamp flips [absolute] to true,
/// which always shows the full date + time regardless of age.
String formatMessageTimestamp(DateTime sentAt, {required AppLocalizations l10n, required String locale, required bool absolute}) {
  if (absolute) {
    return DateFormat.yMMMd(locale).add_jm().format(sentAt);
  }
  final now = DateTime.now();
  final difference = now.difference(sentAt);
  final isSameDay = sentAt.year == now.year && sentAt.month == now.month && sentAt.day == now.day;
  if (difference.inMinutes < 60) return formatTimeAgo(sentAt, l10n);
  if (isSameDay) return DateFormat.jm(locale).format(sentAt);
  return DateFormat.yMMMd(locale).add_jm().format(sentAt);
}
