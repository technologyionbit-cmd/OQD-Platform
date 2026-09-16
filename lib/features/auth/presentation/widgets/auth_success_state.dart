import 'package:flutter/material.dart';

import 'package:aqd_ionbit/core/theme/app_colors.dart';
import 'package:aqd_ionbit/core/theme/app_spacing.dart';
import 'package:aqd_ionbit/core/theme/app_status_colors.dart';
import 'package:aqd_ionbit/core/widgets/app_button.dart';

/// The centered success panel shared by "code sent" and "password reset"
/// confirmations: a circular check, a title/subtitle, a primary action,
/// and an optional secondary text action.
class AuthSuccessState extends StatelessWidget {
  const AuthSuccessState({
    super.key,
    required this.title,
    required this.message,
    required this.primaryLabel,
    required this.onPrimary,
    this.secondaryLabel,
    this.onSecondary,
  });

  final String title;
  final String message;
  final String primaryLabel;
  final VoidCallback onPrimary;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;

  @override
  Widget build(BuildContext context) {
    final success = context.statusColors.success;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 88,
          height: 88,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: success.background, shape: BoxShape.circle),
          child: Icon(Icons.check_rounded, color: success.foreground, size: 40),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(title, textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: AppSpacing.xs),
        Text(
          message,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: AppSpacing.xl),
        AppButton(label: primaryLabel, onPressed: onPrimary),
        if (secondaryLabel != null && onSecondary != null) ...[
          const SizedBox(height: AppSpacing.xs),
          TextButton(onPressed: onSecondary, child: Text(secondaryLabel!)),
        ],
      ],
    );
  }
}
