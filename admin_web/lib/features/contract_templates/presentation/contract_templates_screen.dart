import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:aqd_admin/core/localization/generated/app_localizations.dart';
import 'package:aqd_admin/features/auth/presentation/providers/access.dart';
import 'package:aqd_admin/core/network/api_call.dart';
import 'package:aqd_admin/core/providers/core_providers.dart';
import 'package:aqd_admin/core/routing/route_paths.dart';
import 'package:aqd_admin/core/widgets/page_header.dart';
import 'package:aqd_admin/core/widgets/state_views.dart';
import 'package:aqd_admin/core/widgets/status_chip.dart';
import 'package:aqd_admin/features/contracts/presentation/contracts_screen.dart' show contractCategoryLabel;

final contractTemplatesProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final response = await apiCall(() => ref.watch(apiClientProvider).dio.get<Map<String, dynamic>>('/admin/contract-templates'));
  return (response.data!['data'] as List<dynamic>).cast<Map<String, dynamic>>();
});

/// The contract templates the app offers. Staff add and edit them here;
/// changes show in the app at once.
class ContractTemplatesScreen extends ConsumerWidget {
  const ContractTemplatesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final templates = ref.watch(contractTemplatesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PageHeader(
          title: l10n.navContractTemplates,
          subtitle: l10n.templatesSubtitle,
          actions: [
            if (canManage(ref, 'contractTemplates'))
              FilledButton.icon(onPressed: () => context.go('${RoutePaths.contractTemplates}/new'), icon: const Icon(Icons.add), label: Text(l10n.templateNew)),
          ],
        ),
        Expanded(
          child: templates.when(
            loading: () => const LoadingView(),
            error: (e, _) => ErrorView(error: e, onRetry: () => ref.invalidate(contractTemplatesProvider)),
            data: (rows) => rows.isEmpty
                ? const EmptyView()
                : SingleChildScrollView(
                    child: Card(
                      child: SizedBox(
                        width: double.infinity,
                        child: DataTable(
                          showCheckboxColumn: false,
                          columns: [
                            DataColumn(label: Text(l10n.colTitle)),
                            DataColumn(label: Text(l10n.templateKey)),
                            DataColumn(label: Text(l10n.colCategory)),
                            DataColumn(label: Text(l10n.templateVersion), numeric: true),
                            DataColumn(label: Text(l10n.templateFields), numeric: true),
                            DataColumn(label: Text(l10n.navContracts), numeric: true),
                            DataColumn(label: Text(l10n.colPdf)),
                            DataColumn(label: Text(l10n.colStatus)),
                          ],
                          rows: [
                            for (final r in rows)
                              DataRow(
                                onSelectChanged: (_) => context.go('${RoutePaths.contractTemplates}/${r['id']}'),
                                cells: [
                                  DataCell(Text((r['title'] as Map<String, dynamic>)[lang] as String? ?? '-', style: const TextStyle(fontWeight: FontWeight.w600))),
                                  DataCell(Text(r['key'] as String, textDirection: TextDirection.ltr)),
                                  DataCell(Text(contractCategoryLabel(l10n, r['category'] as String))),
                                  DataCell(Text('${r['version']}')),
                                  DataCell(Text('${r['fieldsCount']}')),
                                  DataCell(Text('${r['contractsCount']}')),
                                  DataCell(Icon(r['hasPdf'] == true ? Icons.picture_as_pdf : Icons.remove, size: 18, color: r['hasPdf'] == true ? Theme.of(context).colorScheme.error : null)),
                                  DataCell(StatusChip(label: r['isActive'] == true ? l10n.templateActive : l10n.templateInactive, tone: r['isActive'] == true ? StatusTone.success : StatusTone.neutral)),
                                ],
                              ),
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
