import 'package:flutter/material.dart';

import 'package:aqd_ionbit/core/theme/app_colors.dart';
import 'package:aqd_ionbit/core/theme/app_radii.dart';
import 'package:aqd_ionbit/core/theme/app_spacing.dart';

/// Selectable pill: account-type selector, category/specialty filters, day
/// pickers. Built in "logical" child order everywhere it's used in a
/// `Row`/`Wrap` — RTL mirroring is Flutter's job, not this widget's.
class AppChip extends StatelessWidget {
  const AppChip({super.key, required this.label, required this.selected, this.onTap, this.icon});

  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return InkWell(
      onTap: onTap,
      borderRadius: AppRadii.mdRadius,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
        decoration: BoxDecoration(
          color: selected ? primary.withValues(alpha: 0.08) : Colors.transparent,
          borderRadius: AppRadii.mdRadius,
          border: Border.all(color: selected ? primary : AppColors.border, width: selected ? 1.5 : 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: selected ? primary : AppColors.textSecondary),
              const SizedBox(width: 6),
            ],
            // Flexible + ellipsis: this widget is frequently given a tight
            // width (e.g. Expanded in a 3-way selector row) — a plain Text
            // here would overflow instead of truncating on narrow screens
            // or longer translated labels.
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: TextStyle(color: selected ? primary : AppColors.textSecondary, fontWeight: selected ? FontWeight.w600 : FontWeight.w400),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
