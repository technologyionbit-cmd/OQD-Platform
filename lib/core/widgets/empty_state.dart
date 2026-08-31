import 'package:flutter/material.dart';

import 'package:aqd_ionbit/core/theme/app_spacing.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.message, this.icon = Icons.inbox_outlined});

  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 40, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4)),
            const SizedBox(height: AppSpacing.md),
            Text(message, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
