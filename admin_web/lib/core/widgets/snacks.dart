import 'package:flutter/material.dart';

import 'package:aqd_admin/core/errors/failure_message.dart';
import 'package:aqd_admin/core/localization/generated/app_localizations.dart';

void showSuccessSnack(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message), behavior: SnackBarBehavior.floating, width: 420));
}

void showFailureSnack(BuildContext context, Object error) {
  final scheme = Theme.of(context).colorScheme;
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(failureMessage(AppLocalizations.of(context), error)),
        backgroundColor: scheme.error,
        behavior: SnackBarBehavior.floating,
        width: 420,
      ),
    );
}
