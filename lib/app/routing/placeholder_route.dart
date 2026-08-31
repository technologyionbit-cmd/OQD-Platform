import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:aqd_ionbit/core/localization/generated/app_localizations.dart';
import 'package:aqd_ionbit/core/widgets/placeholder_screen.dart';

/// A `GoRoute` whose destination isn't built yet — every role's route file
/// has several of these, so the boilerplate (look up l10n, build the
/// screen) lives here once instead of being repeated per tab.
GoRoute placeholderRoute({required String path, required String Function(AppLocalizations) title, required IconData icon}) {
  return GoRoute(
    path: path,
    builder: (context, state) {
      final l10n = AppLocalizations.of(context)!;
      return PlaceholderScreen(title: title(l10n), icon: icon, message: l10n.placeholderComingSoonMessage);
    },
  );
}
