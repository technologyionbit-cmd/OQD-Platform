import 'package:flutter/material.dart';

import 'package:aqd_ionbit/core/theme/app_spacing.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.message, this.icon = Icons.inbox_outlined, this.title, this.action});

  final String message;
  final IconData icon;

  /// Optional heading above [message] — e.g. "No contracts yet" with
  /// [message] as the supporting line. Omit for the plain single-line form
  /// most placeholder screens use.
  final String? title;

  /// Optional primary action (e.g. "Create Contract") shown below the
  /// message — an empty state that's also the natural place to act.
  final Widget? action;

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
            if (title != null) ...[
              Text(title!, textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: AppSpacing.xxs),
            ],
            Text(message, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium),
            if (action != null) ...[const SizedBox(height: AppSpacing.lg), action!],
          ],
        ),
      ),
    );
  }
}
