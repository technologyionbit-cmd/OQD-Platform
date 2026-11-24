import 'package:flutter/material.dart';

import 'package:aqd_admin/core/theme/app_colors.dart';

enum StatusTone { success, warning, error, info, neutral }

/// A small coloured pill for a status value (active, pending, suspended...).
class StatusChip extends StatelessWidget {
  const StatusChip({required this.label, super.key, this.tone = StatusTone.neutral});

  final String label;
  final StatusTone tone;

  @override
  Widget build(BuildContext context) {
    final (foreground, background) = switch (tone) {
      StatusTone.success => (AppColors.success, AppColors.successBackground),
      StatusTone.warning => (AppColors.warning, AppColors.warningBackground),
      StatusTone.error => (AppColors.error, AppColors.errorBackground),
      StatusTone.info => (AppColors.info, AppColors.infoBackground),
      StatusTone.neutral => (AppColors.neutral, AppColors.neutralBackground),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(999)),
      child: Text(
        label,
        style: TextStyle(color: foreground, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}
