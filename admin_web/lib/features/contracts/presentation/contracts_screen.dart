import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aqd_admin/core/localization/generated/app_localizations.dart';
import 'package:aqd_admin/features/auth/presentation/providers/access.dart';
import 'package:aqd_admin/core/network/api_call.dart';
import 'package:aqd_admin/core/providers/core_providers.dart';
import 'package:aqd_admin/core/utils/formatters.dart';
import 'package:aqd_admin/core/widgets/admin_data_table.dart';
import 'package:aqd_admin/core/widgets/info_card.dart';
import 'package:aqd_admin/core/widgets/paged_list_screen.dart';
import 'package:aqd_admin/core/widgets/reason_dialog.dart';
import 'package:aqd_admin/core/widgets/snacks.dart';
import 'package:aqd_admin/core/widgets/state_views.dart';
import 'package:aqd_admin/core/widgets/status_chip.dart';

class ContractRow {
  const ContractRow({
    required this.id,
    required this.title,
    required this.category,
    required this.status,
    required this.ownerName,
    required this.ownerEmail,
    required this.signaturesCount,
    required this.updatedAt,
  });

  factory ContractRow.fromJson(Map<String, dynamic> json) {
    final owner = json['owner'] as Map<String, dynamic>;
    return ContractRow(
      id: json['id'] as String,
      title: json['title'] as String,
      category: json['category'] as String,
      status: json['status'] as String,
      ownerName: owner['fullName'] as String,
      ownerEmail: owner['email'] as String,
      signaturesCount: (json['signaturesCount'] as num).toInt(),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  final String id;
  final String title;
  final String category;
  final String status;
  final String ownerName;
  final String ownerEmail;
  final int signaturesCount;
  final DateTime updatedAt;
}

String contractStatusLabel(AppLocalizations l, String s) => switch (s) {
      'draft' => l.ctDraft,
      'pendingSignature' => l.ctPendingSignature,
      'signed' => l.ctSigned,
      'completed' => l.ctCompleted,
      'cancelled' => l.ctCancelled,
      _ => s,
    };

String contractCategoryLabel(AppLocalizations l, String s) => switch (s) {
      'employment' => l.catEmployment,
      'sale' => l.catSale,
      'rental' => l.catRental,
      'partnership' => l.catPartnership,
      'nda' => l.catNda,
      'serviceAgreement' => l.catServiceAgreement,
      'other' => l.catOther,
      _ => s,
    };

StatusTone _tone(String s) => switch (s) {
      'signed' || 'completed' => StatusTone.success,
      'pendingSignature' => StatusTone.warning,
      'cancelled' => StatusTone.error,
      _ => StatusTone.neutral,
    };

final _query = listQueryProvider('updatedAt');
final _page = pagedProvider('/admin/contracts', ContractRow.fromJson, _query);

class ContractsScreen extends StatelessWidget {
  const ContractsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return PagedListScreen<ContractRow>(
      title: l10n.navContracts,
      subtitle: l10n.contractsSubtitle,
      searchHint: l10n.searchContractsHint,
      query: _query,
      page: _page,
      onRowTap: (c) => showDialog<void>(context: context, builder: (_) => ContractDialog(id: c.id)),
      filters: [
        FilterSpec(key: 'status', label: (l) => l.filterStatus, options: (l) => {for (final s in ['draft', 'pendingSignature', 'signed', 'completed', 'cancelled']) s: contractStatusLabel(l, s)}),
        FilterSpec(
          key: 'category',
          label: (l) => l.filterCategory,
          options: (l) => {for (final s in ['employment', 'sale', 'rental', 'partnership', 'nda', 'serviceAgreement', 'other']) s: contractCategoryLabel(l, s)},
        ),
      ],
      columns: [
        AdminColumn(
          label: l10n.colTitle,
          sortKey: 'title',
          cell: (c) => ConstrainedBox(constraints: const BoxConstraints(maxWidth: 280), child: Text(c.title, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600))),
        ),
        AdminColumn(label: l10n.colCategory, cell: (c) => Text(contractCategoryLabel(l10n, c.category))),
        AdminColumn(label: l10n.colOwner, cell: (c) => Text(c.ownerName)),
        AdminColumn(label: l10n.colEmail, cell: (c) => Text(c.ownerEmail)),
        AdminColumn(label: l10n.colStatus, cell: (c) => StatusChip(label: contractStatusLabel(l10n, c.status), tone: _tone(c.status))),
        AdminColumn(label: l10n.colSignatures, numeric: true, cell: (c) => Text('${c.signaturesCount}')),
        AdminColumn(label: l10n.colUpdated, sortKey: 'updatedAt', cell: (c) => Text(formatDateTime(context, c.updatedAt))),
      ],
    );
  }
}

final _detail = FutureProvider.autoDispose.family<Map<String, dynamic>, String>((ref, id) async {
  final response = await apiCall(() => ref.watch(apiClientProvider).dio.get<Map<String, dynamic>>('/admin/contracts/$id'));
  return dataOf(response);
});

/// One contract's details and signatures (never its text), and cancel.
class ContractDialog extends ConsumerWidget {
  const ContractDialog({required this.id, super.key});

  final String id;

  Future<void> _cancel(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final reason = await showReasonDialog(context, title: l10n.contractCancelTitle, message: l10n.contractCancelBody, confirmLabel: l10n.contractCancel);
    if (reason == null || !context.mounted) return;
    try {
      await apiCall(() => ref.read(apiClientProvider).dio.post<void>('/admin/contracts/$id/cancel', data: {'reason': reason}));
      ref.invalidate(_page);
      if (context.mounted) {
        Navigator.of(context).pop();
        showSuccessSnack(context, l10n.contractCancelledDone);
      }
    } on Object catch (error) {
      if (context.mounted) showFailureSnack(context, error);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final detail = ref.watch(_detail(id));

    return AlertDialog(
      title: Text(l10n.contractDetailTitle),
      content: SizedBox(
        width: 560,
        child: detail.when(
          loading: () => const SizedBox(height: 160, child: LoadingView()),
          error: (e, _) => ErrorView(error: e, onRetry: () => ref.invalidate(_detail(id))),
          data: (d) {
            final owner = d['owner'] as Map<String, dynamic>;
            final signatures = (d['signatures'] as List<dynamic>).cast<Map<String, dynamic>>();
            final status = d['status'] as String;
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  InfoRow(label: l10n.colTitle, text: d['title'] as String),
                  InfoRow(label: l10n.colCategory, text: contractCategoryLabel(l10n, d['category'] as String)),
                  InfoRow(label: l10n.colOwner, text: '${owner['fullName']}  ·  ${owner['email']}'),
                  InfoRow(
                    label: l10n.colStatus,
                    child: Align(alignment: AlignmentDirectional.centerStart, child: StatusChip(label: contractStatusLabel(l10n, status), tone: _tone(status))),
                  ),
                  InfoRow(label: l10n.contractTemplate, text: '${d['templateKey']}  v${d['templateVersion']}'),
                  InfoRow(label: l10n.contractParties, text: (d['parties'] as List<dynamic>).join('  ·  ')),
                  InfoRow(label: l10n.colCreated, text: formatDateTime(context, DateTime.parse(d['createdAt'] as String))),
                  const Divider(height: 24),
                  Text(l10n.colSignatures, style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 8),
                  if (signatures.isEmpty)
                    Text(l10n.contractNoSignatures)
                  else
                    for (final s in signatures)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text('${(s['user'] as Map<String, dynamic>)['fullName']}  ·  ${formatDateTime(context, DateTime.parse(s['signedAt'] as String))}  ·  ${s['ipAddress'] ?? '-'}'),
                      ),
                ],
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.close)),
        if (canManage(ref, 'contracts') && detail.value?['canCancel'] == true)
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: scheme.error, foregroundColor: scheme.onError),
            onPressed: () => _cancel(context, ref),
            child: Text(l10n.contractCancel),
          ),
      ],
    );
  }
}
