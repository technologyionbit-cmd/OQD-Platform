import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:aqd_admin/core/localization/generated/app_localizations.dart';
import 'package:aqd_admin/core/routing/nav_items.dart';
import 'package:aqd_admin/core/routing/route_paths.dart';

/// Home > Module for the current location. Detail screens added in later
/// phases extend this with their own last crumb.
class Breadcrumbs extends StatelessWidget {
  const Breadcrumbs({required this.location, super.key});

  final String location;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final item = navItemFor(location);
    final isDetail = item != null && location != item.path;
    final muted = theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: () => context.go(RoutePaths.dashboard),
          child: Text(l10n.breadcrumbHome, style: muted),
        ),
        if (item != null) ...[
          const Padding(padding: EdgeInsets.symmetric(horizontal: 6), child: Icon(Icons.chevron_right, size: 16)),
          if (isDetail)
            InkWell(onTap: () => context.go(item.path), child: Text(item.label(l10n), style: muted))
          else
            Text(item.label(l10n), style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
          if (isDetail) ...[
            const Padding(padding: EdgeInsets.symmetric(horizontal: 6), child: Icon(Icons.chevron_right, size: 16)),
            Text(l10n.breadcrumbDetails, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
          ],
        ],
      ],
    );
  }
}
