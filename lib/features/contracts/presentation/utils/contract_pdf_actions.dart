import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aqd_ionbit/core/errors/failure.dart';
import 'package:aqd_ionbit/core/errors/failure_message.dart';
import 'package:aqd_ionbit/core/localization/generated/app_localizations.dart';
import 'package:aqd_ionbit/core/pdf/pdf_documents.dart';
import 'package:aqd_ionbit/core/pdf/pdf_providers.dart';
import 'package:aqd_ionbit/features/contracts/domain/entities/contract.dart';

/// Builds the contract as a PDF (in its own language: Arabic text is laid
/// out right to left) and hands it to the share sheet / save dialog.
Future<void> downloadContractPdf(BuildContext context, WidgetRef ref, Contract contract) async {
  final l10n = AppLocalizations.of(context)!;
  final rtl = Directionality.of(context) == TextDirection.rtl;
  try {
    final fonts = await ref.read(pdfFontsProvider.future);
    final bytes = await buildContractPdf(
      fonts: fonts,
      title: contract.title,
      content: contract.generatedContent,
      parties: contract.parties,
      rtl: rtl,
      footer: l10n.pdfFooter,
    );
    await ref.read(pdfSharerProvider)(bytes, pdfFileName(contract.title));
  } on Object catch (error) {
    if (context.mounted) _showError(context, l10n, error);
  }
}

/// Downloads the official PDF staff uploaded for the contract's template.
Future<void> downloadOfficialContractPdf(BuildContext context, WidgetRef ref, {required String templateId, required String title}) async {
  final l10n = AppLocalizations.of(context)!;
  try {
    final bytes = await ref.read(officialPdfLoaderProvider).load('/contract-templates/$templateId/pdf');
    await ref.read(pdfSharerProvider)(bytes, pdfFileName(title));
  } on Object catch (error) {
    if (context.mounted) _showError(context, l10n, error);
  }
}

void _showError(BuildContext context, AppLocalizations l10n, Object error) {
  final message = error is Failure ? error.localizedMessage(l10n) : l10n.pdfFailed;
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}
