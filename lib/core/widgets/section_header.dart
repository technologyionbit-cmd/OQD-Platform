import 'package:flutter/material.dart';

/// Section title + optional trailing action ("عرض الكل"), as seen above
/// every list section on the home/vault/documents screens.
class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.actionLabel, this.onActionTap});

  final String title;
  final String? actionLabel;
  final VoidCallback? onActionTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        if (actionLabel != null) TextButton(onPressed: onActionTap, child: Text(actionLabel!)),
      ],
    );
  }
}
