import 'package:flutter/material.dart';

import 'package:aqd_ionbit/core/theme/app_radii.dart';
import 'package:aqd_ionbit/core/theme/app_spacing.dart';
import 'package:aqd_ionbit/core/theme/app_status_colors.dart';

/// The pill badge used everywhere a contract/document/booking/request has a
/// state — "مكتمل" (green), "بانتظار التوقيع" (amber), "مسودة" (gray), a
/// verified-lawyer checkmark, an analysis-risk alert label, etc. One widget,
/// five tones — never a bespoke colored `Container` per screen.
enum AppStatusTone { success, warning, error, info, neutral }

class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.label, required this.tone, this.icon});

  final String label;
  final AppStatusTone tone;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final colors = context.statusColors;
    final statusTone = switch (tone) {
      AppStatusTone.success => colors.success,
      AppStatusTone.warning => colors.warning,
      AppStatusTone.error => colors.error,
      AppStatusTone.info => colors.info,
      AppStatusTone.neutral => colors.neutral,
    };

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
          Text(
            label,
            style: TextStyle(color: statusTone.foreground, fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
