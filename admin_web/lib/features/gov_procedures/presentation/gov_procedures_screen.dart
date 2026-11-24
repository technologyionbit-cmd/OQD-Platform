import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:aqd_admin/core/errors/failure.dart';
import 'package:aqd_admin/core/localization/generated/app_localizations.dart';
import 'package:aqd_admin/core/providers/core_providers.dart';
import 'package:aqd_admin/core/routing/route_paths.dart';
import 'package:aqd_admin/core/widgets/page_header.dart';
import 'package:aqd_admin/core/widgets/state_views.dart';

class GovProcedureRow {
  const GovProcedureRow({required this.id, required this.type, required this.accessType, required this.duration, required this.documents, required this.steps, required this.startedBy, this.hasPdf = false});

  /// [locale] picks the language of the `{ar, en}` duration label.
  factory GovProcedureRow.fromJson(Map<String, dynamic> json) => GovProcedureRow(
        id: json['id'] as String,
        type: json['type'] as String,
        accessType: json['accessType'] as String,
        duration: Map<String, String>.from(json['durationLabel'] as Map),
        documents: (json['documentsCount'] as num).toInt(),
        steps: (json['stepsCount'] as num).toInt(),
        startedBy: (json['startedByCount'] as num).toInt(),
        hasPdf: json['hasPdf'] == true,
      );

  final String id;
  final String type;
  final String accessType;
  final Map<String, String> duration;
  final int documents;
  final int steps;
  final int startedBy;
  final bool hasPdf;
}

String govTypeLabel(AppLocalizations l, String s) => switch (s) {
      'companyRegistration' => l.gpCompanyRegistration,
      'propertyRegistration' => l.gpPropertyRegistration,
      'contractNotarization' => l.gpContractNotarization,
      'lawsuitFiling' => l.gpLawsuitFiling,
      _ => s,
    };

final govProceduresProvider = FutureProvider.autoDispose<List<GovProcedureRow>>((ref) async {
  try {
    final response = await ref.watch(apiClientProvider).dio.get<Map<String, dynamic>>('/admin/gov-procedures');
    return [for (final r in response.data!['data'] as List<dynamic>) GovProcedureRow.fromJson(r as Map<String, dynamic>)];
  } on DioException catch (error) {
    throw mapToFailure(error);
  }
});

class GovProceduresScreen extends ConsumerWidget {
  const GovProceduresScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final rows = ref.watch(govProceduresProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PageHeader(title: l10n.navGovProcedures, subtitle: l10n.govSubtitle),
        Expanded(
          child: rows.when(
            loading: () => const LoadingView(),
            error: (e, _) => ErrorView(error: e, onRetry: () => ref.invalidate(govProceduresProvider)),
            data: (list) => list.isEmpty
                ? const EmptyView()
                : SingleChildScrollView(
                    child: Card(
                      child: SizedBox(
                        width: double.infinity,
                        child: DataTable(
                          columns: [
                            DataColumn(label: Text(l10n.colProcedure)),
                            DataColumn(label: Text(l10n.colAccess)),
                            DataColumn(label: Text(l10n.colDuration)),
                            DataColumn(label: Text(l10n.colDocuments), numeric: true),
                            DataColumn(label: Text(l10n.colSteps), numeric: true),
                            DataColumn(label: Text(l10n.colStarted), numeric: true),
                            DataColumn(label: Text(l10n.colPdf)),
                            const DataColumn(label: SizedBox.shrink()),
                          ],
                          rows: [
                            for (final r in list)
                              DataRow(onSelectChanged: (_) => context.go('${RoutePaths.govProcedures}/${r.id}'), cells: [
                                DataCell(Text(govTypeLabel(l10n, r.type), style: const TextStyle(fontWeight: FontWeight.w600))),
                                DataCell(Text(r.accessType == 'guide' ? l10n.accessGuide : l10n.accessDirectLink)),
                                DataCell(Text(r.duration[lang] ?? r.duration['en'] ?? '-')),
                                DataCell(Text('${r.documents}')),
                                DataCell(Text('${r.steps}')),
                                DataCell(Text('${r.startedBy}')),
                                DataCell(Icon(r.hasPdf ? Icons.picture_as_pdf : Icons.remove, size: 18, color: r.hasPdf ? Theme.of(context).colorScheme.error : null)),
                                DataCell(IconButton(tooltip: l10n.edit, icon: const Icon(Icons.edit_outlined, size: 18), onPressed: () => context.go('${RoutePaths.govProcedures}/${r.id}'))),
                              ]),
                          ],
                        ),
                      ),
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
