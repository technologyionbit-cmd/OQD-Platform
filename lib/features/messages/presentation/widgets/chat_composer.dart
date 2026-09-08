import 'package:flutter/material.dart';

import 'package:aqd_ionbit/core/localization/generated/app_localizations.dart';
import 'package:aqd_ionbit/core/theme/app_spacing.dart';
import 'package:aqd_ionbit/core/widgets/app_bottom_sheet.dart';

/// The message-composer row: attachment button (opens the image/file mock
/// picker sheet), text field, send button. [enabled] false covers both the
/// pre-consultation lobby (nothing to send yet) and the post-end state
/// (nothing more to send) — callers swap this out entirely for the ended
/// static message instead of just disabling it there, per the blueprint.
class ChatComposer extends StatelessWidget {
  const ChatComposer({
    super.key,
    required this.controller,
    required this.enabled,
    this.isSending = false,
    required this.onSend,
    required this.onPickImage,
    required this.onAttachFile,
  });

  final TextEditingController controller;
  final bool enabled;

  /// True for the brief mock-latency window between tapping send and the
  /// message actually landing — shows a spinner in place of the send icon
  /// and blocks a second send/attachment from racing the first, without
  /// locking the whole composer (the user can keep typing their next
  /// message while the current one is still in flight).
  final bool isSending;
  final VoidCallback onSend;
  final VoidCallback onPickImage;
  final VoidCallback onAttachFile;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final canSubmit = enabled && !isSending;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(AppSpacing.sm, AppSpacing.xs, AppSpacing.sm, AppSpacing.sm),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            IconButton(
              onPressed: canSubmit ? () => _showAttachMenu(context, l10n) : null,
              icon: const Icon(Icons.attach_file_outlined),
              tooltip: l10n.chatAttachmentTooltip,
            ),
            Expanded(
              child: TextField(
                controller: controller,
                enabled: enabled,
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.send,
                onSubmitted: canSubmit ? (_) => onSend() : null,
                decoration: InputDecoration(hintText: l10n.consultationMessageHint),
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            IconButton.filled(
              onPressed: canSubmit ? onSend : null,
              icon: isSending
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.send),
            ),
          ],
        ),
      ),
    );
  }

  void _showAttachMenu(BuildContext context, AppLocalizations l10n) {
    showAppBottomSheet<void>(
      context,
      isScrollControlled: false,
      builder: (sheetContext) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.image_outlined),
              title: Text(l10n.chatAttachImage),
              onTap: () {
                Navigator.of(sheetContext).pop();
                onPickImage();
              },
            ),
            ListTile(
              leading: const Icon(Icons.insert_drive_file_outlined),
              title: Text(l10n.chatAttachFile),
              onTap: () {
                Navigator.of(sheetContext).pop();
                onAttachFile();
              },
            ),
          ],
        );
      },
    );
  }
}
