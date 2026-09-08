import 'package:flutter/material.dart';

import 'package:aqd_ionbit/core/theme/app_radii.dart';
import 'package:aqd_ionbit/core/theme/app_spacing.dart';
import 'package:aqd_ionbit/core/theme/app_status_colors.dart';

/// The pill badge used everywhere a contract/document/booking/request has a
/// state — "مكتمل" (green), "بانتظار التوقيع" (amber), "مسودة" (gray), a
/// verified-lawyer checkmark, an analysis-risk alert label, etc. One widget,
/// five tones — never a bespoke colored `Container` per screen.
enum AppStatusTone { success, warning, error, info, neutral }

extension AppStatusToneX on AppStatusTone {
  /// Resolves this tone against the current theme — shared by [StatusBadge]
  /// and any widget that needs the same foreground/background pair outside
  /// a badge (e.g. a tinted icon container).
  StatusTone resolve(BuildContext context) {
    final colors = context.statusColors;
    return switch (this) {
      AppStatusTone.success => colors.success,
      AppStatusTone.warning => colors.warning,
      AppStatusTone.error => colors.error,
      AppStatusTone.info => colors.info,
      AppStatusTone.neutral => colors.neutral,
    };
  }
}

class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.label, required this.tone, this.icon});

  final String label;
  final AppStatusTone tone;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final statusTone = tone.resolve(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs, vertical: 4),
      decoration: BoxDecoration(color: statusTone.background, borderRadius: AppRadii.smRadius),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: statusTone.foreground),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: statusTone.foreground, fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
