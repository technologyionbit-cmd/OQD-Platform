import 'package:flutter/material.dart';

import 'package:aqd_admin/core/localization/generated/app_localizations.dart';

/// Asks the admin to confirm an action. Returns true only on confirm.
///
/// For destructive actions pass [destructive] (red button) and optionally
/// [confirmWord]: the confirm button stays disabled until that word is
/// typed, for things that cannot be undone.
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String? confirmLabel,
  bool destructive = false,
  String? confirmWord,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => _ConfirmDialog(
      title: title,
      message: message,
      confirmLabel: confirmLabel,
      destructive: destructive,
      confirmWord: confirmWord,
    ),
  );
  return result ?? false;
}

class _ConfirmDialog extends StatefulWidget {
  const _ConfirmDialog({
    required this.title,
    required this.message,
    required this.destructive,
    this.confirmLabel,
    this.confirmWord,
  });

  final String title;
  final String message;
  final String? confirmLabel;
  final bool destructive;
  final String? confirmWord;

  @override
  State<_ConfirmDialog> createState() => _ConfirmDialogState();
}

class _ConfirmDialogState extends State<_ConfirmDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _canConfirm => widget.confirmWord == null || _controller.text.trim() == widget.confirmWord;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return AlertDialog(
      title: Text(widget.title),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.message),
            if (widget.confirmWord != null) ...[
              const SizedBox(height: 16),
              Text(l10n.typeToConfirm(widget.confirmWord!)),
              const SizedBox(height: 8),
              TextField(
                controller: _controller,
                autofocus: true,
                onChanged: (_) => setState(() {}),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(l10n.cancel)),
        FilledButton(
          style: widget.destructive ? FilledButton.styleFrom(backgroundColor: scheme.error, foregroundColor: scheme.onError) : null,
          onPressed: _canConfirm ? () => Navigator.of(context).pop(true) : null,
          child: Text(widget.confirmLabel ?? l10n.confirm),
        ),
      ],
    );
  }
}
