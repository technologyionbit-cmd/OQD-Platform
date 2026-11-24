import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aqd_ionbit/core/errors/failure.dart';
import 'package:aqd_ionbit/core/errors/failure_message.dart';
import 'package:aqd_ionbit/core/localization/generated/app_localizations.dart';
import 'package:aqd_ionbit/core/pdf/pdf_documents.dart';
import 'package:aqd_ionbit/core/pdf/pdf_providers.dart';
import 'package:aqd_ionbit/features/gov_documents/domain/entities/gov_procedure.dart';
import 'package:aqd_ionbit/features/gov_documents/presentation/widgets/gov_procedure_type_x.dart';

/// The procedure's PDF: the official file staff uploaded if there is one,
/// otherwise a checklist built from the procedure's own data.
Future<void> downloadProcedurePdf(BuildContext context, WidgetRef ref, GovProcedure procedure) async {
  final l10n = AppLocalizations.of(context)!;
  final rtl = Directionality.of(context) == TextDirection.rtl;
  final title = procedure.type.title(l10n);
  try {
    final Uint8List bytes;
    if (procedure.hasPdf) {
      bytes = await ref.read(officialPdfLoaderProvider).load('/gov-procedures/${procedure.id}/pdf');
    } else {
      final fonts = await ref.read(pdfFontsProvider.future);
      bytes = await buildProcedurePdf(
        fonts: fonts,
        title: title,
        rtl: rtl,
        durationHeading: l10n.pdfDuration,
        duration: procedure.durationLabel,
        documentsHeading: l10n.govRequiredDocumentsTitle,
        documents: [for (final d in procedure.requiredDocuments) d.title],
        stepsHeading: l10n.govProcedureStepsTitle,
        steps: [for (final s in procedure.steps) (title: s.title, description: s.description)],
        footer: l10n.pdfFooter,
      );
    }
    await ref.read(pdfSharerProvider)(bytes, pdfFileName(title));
  } on Object catch (error) {
    if (context.mounted) {
      final message = error is Failure ? error.localizedMessage(l10n) : l10n.pdfFailed;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }
  }
}
