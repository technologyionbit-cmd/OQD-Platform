import 'package:flutter/material.dart';

import 'package:aqd_ionbit/core/theme/app_radii.dart';

/// The rounded-square colored icon container reused across onboarding
/// illustrations, auth-screen headers, service cards, and notification
/// rows — background/icon color and size all overridable so one widget
/// covers every one of those contexts.
class IconBadge extends StatelessWidget {
  const IconBadge({super.key, required this.icon, this.size = 48, this.backgroundColor, this.iconColor, this.iconSize});

  final IconData icon;
  final double size;
  final Color? backgroundColor;
  final Color? iconColor;
  final double? iconSize;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final background = backgroundColor ?? colorScheme.primary.withValues(alpha: 0.1);
    final foreground = iconColor ?? colorScheme.primary;

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: background, borderRadius: AppRadii.mdRadius),
      child: Icon(icon, size: iconSize ?? size * 0.5, color: foreground),
    );
  }
}
