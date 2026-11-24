import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aqd_admin/core/localization/generated/app_localizations.dart';
import 'package:aqd_admin/core/network/api_call.dart';
import 'package:aqd_admin/core/providers/core_providers.dart';
import 'package:aqd_admin/core/utils/file_picker.dart';
import 'package:aqd_admin/core/widgets/confirm_dialog.dart';
import 'package:aqd_admin/core/widgets/snacks.dart';

/// The optional official PDF of a contract template or a procedure: upload,
/// replace or remove it. The app gives users this file to download; with
/// none, the app builds a PDF from the data itself.
///
/// [path] is the resource, e.g. `/admin/gov-procedures/<id>`; the file goes
/// to `<path>/pdf`. [onChanged] runs after an upload or removal so the
/// screen can reload.
class PdfAttachmentCard extends ConsumerStatefulWidget {
  const PdfAttachmentCard({required this.path, required this.fileName, required this.canManage, required this.onChanged, super.key});

  final String path;
  final String? fileName;
  final bool canManage;
  final VoidCallback onChanged;

  @override
  ConsumerState<PdfAttachmentCard> createState() => _PdfAttachmentCardState();
}

class _PdfAttachmentCardState extends ConsumerState<PdfAttachmentCard> {
  bool _busy = false;

  Future<void> _upload() async {
    final l10n = AppLocalizations.of(context);
    final picked = await ref.read(filePickerProvider)(accept: 'application/pdf,.pdf');
    if (picked == null || !mounted) return;
    setState(() => _busy = true);
    try {
      final form = FormData.fromMap({'file': MultipartFile.fromBytes(picked.bytes, filename: picked.name, contentType: DioMediaType('application', 'pdf'))});
      await apiCall(() => ref.read(apiClientProvider).dio.post<void>('${widget.path}/pdf', data: form));
      widget.onChanged();
      if (mounted) showSuccessSnack(context, l10n.pdfUploaded);
    } on Object catch (error) {
      if (mounted) showFailureSnack(context, error);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _remove() async {
    final l10n = AppLocalizations.of(context);
    final ok = await showConfirmDialog(context, title: l10n.pdfRemoveTitle, message: l10n.pdfRemoveBody, confirmLabel: l10n.pdfRemove, destructive: true);
    if (!ok || !mounted) return;
    setState(() => _busy = true);
    try {
      await apiCall(() => ref.read(apiClientProvider).dio.delete<void>('${widget.path}/pdf'));
      widget.onChanged();
      if (mounted) showSuccessSnack(context, l10n.pdfRemoved);
    } on Object catch (error) {
      if (mounted) showFailureSnack(context, error);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final has = widget.fileName != null;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.pdfTitle, style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(l10n.pdfHelp, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(has ? Icons.picture_as_pdf : Icons.insert_drive_file_outlined, color: has ? theme.colorScheme.error : theme.colorScheme.onSurfaceVariant),
                const SizedBox(width: 8),
                Expanded(child: Text(has ? widget.fileName! : l10n.pdfNone, overflow: TextOverflow.ellipsis)),
                if (_busy)
                  const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                else if (widget.canManage) ...[
                  OutlinedButton.icon(onPressed: _upload, icon: const Icon(Icons.upload_file, size: 18), label: Text(has ? l10n.pdfReplace : l10n.pdfUpload)),
                  if (has) ...[
                    const SizedBox(width: 8),
                    IconButton(tooltip: l10n.pdfRemove, onPressed: _remove, color: theme.colorScheme.error, icon: const Icon(Icons.delete_outline)),
                  ],
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
