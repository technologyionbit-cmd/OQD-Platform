import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

/// `2026-11-21 14:05` in the viewer's local time, digits always Latin so
/// numbers read the same in Arabic and English.
String formatDateTime(BuildContext context, DateTime? value) {
  if (value == null) return '-';
  return DateFormat('yyyy-MM-dd HH:mm', 'en').format(value.toLocal());
}

String formatDate(BuildContext context, DateTime? value) {
  if (value == null) return '-';
  return DateFormat('yyyy-MM-dd', 'en').format(value.toLocal());
}
