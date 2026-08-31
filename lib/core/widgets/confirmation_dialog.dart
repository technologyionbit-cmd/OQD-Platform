import 'package:flutter/material.dart';

/// Shows a confirm/cancel dialog and resolves `true` only if the user
/// confirmed. Used before destructive or hard-to-undo actions (logout
/// today; delete/cancel flows later) instead of acting immediately on tap.
Future<bool> showConfirmationDialog(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  required String cancelLabel,
  bool isDestructive = false,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(cancelLabel)),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: isDestructive ? TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error) : null,
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}
