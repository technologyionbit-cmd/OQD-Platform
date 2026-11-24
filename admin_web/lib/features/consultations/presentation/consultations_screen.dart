import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aqd_admin/core/localization/generated/app_localizations.dart';
import 'package:aqd_admin/features/auth/presentation/providers/access.dart';
import 'package:aqd_admin/core/network/api_call.dart';
import 'package:aqd_admin/core/providers/core_providers.dart';
import 'package:aqd_admin/core/utils/formatters.dart';
import 'package:aqd_admin/core/widgets/admin_data_table.dart';
import 'package:aqd_admin/core/widgets/confirm_dialog.dart';
import 'package:aqd_admin/core/widgets/info_card.dart';
import 'package:aqd_admin/core/widgets/paged_list_screen.dart';
import 'package:aqd_admin/core/widgets/reason_dialog.dart';
import 'package:aqd_admin/core/widgets/snacks.dart';
import 'package:aqd_admin/core/widgets/state_views.dart';
import 'package:aqd_admin/core/widgets/status_chip.dart';

class Consultation {
  const Consultation({
    required this.id,
    required this.clientName,
    required this.lawyerName,
    required this.type,
    required this.status,
    required this.scheduledAt,
    required this.price,
    required this.createdAt,
  });

  factory Consultation.fromJson(Map<String, dynamic> json) => Consultation(
        id: json['id'] as String,
        clientName: json['clientName'] as String,
        lawyerName: json['lawyerName'] as String,
        type: json['type'] as String,
        status: json['status'] as String,
        scheduledAt: DateTime.parse(json['scheduledAt'] as String),
        price: (json['price'] as num).toDouble(),
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  final String id;
  final String clientName;
  final String lawyerName;
  final String type;
  final String status;
  final DateTime scheduledAt;
  final double price;
  final DateTime createdAt;
}

String consultationStatusLabel(AppLocalizations l, String s) => switch (s) {
      'pendingApproval' => l.csPendingApproval,
      'confirmed' => l.csConfirmed,
      'completed' => l.csCompleted,
      'cancelled' => l.csCancelled,
      'declined' => l.csDeclined,
      'missed' => l.csMissed,
      'failed' => l.csFailed,
      _ => s,
    };

String consultationTypeLabel(AppLocalizations l, String s) => switch (s) {
      'video' => l.ctypeVideo,
      'voice' => l.ctypeVoice,
      'written' => l.ctypeWritten,
      _ => s,
    };

StatusTone _tone(String s) => switch (s) {
      'confirmed' || 'completed' => StatusTone.success,
      'pendingApproval' => StatusTone.warning,
      'cancelled' || 'declined' || 'missed' || 'failed' => StatusTone.error,
      _ => StatusTone.neutral,
    };

final _query = listQueryProvider('scheduledAt');
final _page = pagedProvider('/admin/consultations', Consultation.fromJson, _query);

class ConsultationsScreen extends StatelessWidget {
  const ConsultationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return PagedListScreen<Consultation>(
      title: l10n.navConsultations,
      subtitle: l10n.consultationsSubtitle,
      searchHint: l10n.searchConsultationsHint,
      query: _query,
      page: _page,
      onRowTap: (c) => showDialog<void>(context: context, builder: (_) => ConsultationDialog(id: c.id)),
      filters: [
        FilterSpec(
          key: 'status',
          label: (l) => l.filterStatus,
          options: (l) => {for (final s in ['pendingApproval', 'confirmed', 'completed', 'cancelled', 'declined', 'missed', 'failed']) s: consultationStatusLabel(l, s)},
        ),
        FilterSpec(key: 'type', label: (l) => l.filterType, options: (l) => {for (final s in ['video', 'voice', 'written']) s: consultationTypeLabel(l, s)}),
      ],
      columns: [
        AdminColumn(label: l10n.colClient, cell: (c) => Text(c.clientName)),
        AdminColumn(label: l10n.colLawyer, cell: (c) => Text(c.lawyerName)),
        AdminColumn(label: l10n.colType, cell: (c) => Text(consultationTypeLabel(l10n, c.type))),
        AdminColumn(label: l10n.colScheduled, sortKey: 'scheduledAt', cell: (c) => Text(formatDateTime(context, c.scheduledAt))),
        AdminColumn(label: l10n.colPrice, sortKey: 'price', cell: (c) => Text(c.price.toStringAsFixed(2))),
        AdminColumn(label: l10n.colStatus, cell: (c) => StatusChip(label: consultationStatusLabel(l10n, c.status), tone: _tone(c.status))),
        AdminColumn(label: l10n.colCreated, sortKey: 'createdAt', cell: (c) => Text(formatDate(context, c.createdAt))),
      ],
    );
  }
}

final _detail = FutureProvider.autoDispose.family<Map<String, dynamic>, String>((ref, id) async {
  final response = await apiCall(() => ref.watch(apiClientProvider).dio.get<Map<String, dynamic>>('/admin/consultations/$id'));
  return dataOf(response);
});

/// One booking: who, when, the room history, and the staff actions.
class ConsultationDialog extends ConsumerWidget {
  const ConsultationDialog({required this.id, super.key});

  final String id;

  Future<void> _act(BuildContext context, WidgetRef ref, {required bool cancel}) async {
    final l10n = AppLocalizations.of(context);
    String? reason;
    if (cancel) {
      reason = await showReasonDialog(context, title: l10n.consCancelTitle, message: l10n.consCancelBody, confirmLabel: l10n.consCancel);
      if (reason == null) return;
    } else {
      final ok = await showConfirmDialog(context, title: l10n.consCompleteTitle, message: l10n.consCompleteBody, confirmLabel: l10n.consComplete);
      if (!ok) return;
    }
    if (!context.mounted) return;
    try {
      await apiCall(
        () => ref.read(apiClientProvider).dio.post<void>('/admin/consultations/$id/${cancel ? 'cancel' : 'complete'}', data: cancel ? {'reason': reason} : null),
      );
      ref.invalidate(_page);
      if (context.mounted) {
        Navigator.of(context).pop();
        showSuccessSnack(context, cancel ? l10n.consCancelledDone : l10n.consCompletedDone);
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
    final d = detail.value;
    final manage = canManage(ref, 'consultations');

    return AlertDialog(
      title: Text(l10n.consDetailTitle),
      content: SizedBox(
        width: 560,
        child: detail.when(
          loading: () => const SizedBox(height: 160, child: LoadingView()),
          error: (e, _) => ErrorView(error: e, onRetry: () => ref.invalidate(_detail(id))),
          data: (d) {
            final client = d['client'] as Map<String, dynamic>;
            final lawyer = d['lawyer'] as Map<String, dynamic>;
            final room = d['room'] as Map<String, dynamic>?;
            final status = d['status'] as String;
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  InfoRow(label: l10n.colClient, text: '${client['name']}  ·  ${client['email']}  ·  ${client['phone'] ?? '-'}'),
                  InfoRow(label: l10n.colLawyer, text: '${lawyer['name']}  ·  ${lawyer['email']}  ·  ${lawyer['phone'] ?? '-'}'),
                  InfoRow(label: l10n.colType, text: consultationTypeLabel(l10n, d['type'] as String)),
                  InfoRow(
                    label: l10n.colStatus,
                    child: Align(alignment: AlignmentDirectional.centerStart, child: StatusChip(label: consultationStatusLabel(l10n, status), tone: _tone(status))),
                  ),
                  InfoRow(label: l10n.colScheduled, text: formatDateTime(context, DateTime.parse(d['scheduledAt'] as String))),
                  InfoRow(label: l10n.colPrice, text: (d['price'] as num).toStringAsFixed(2)),
                  if ((d['notes'] as String).isNotEmpty) InfoRow(label: l10n.consNotes, text: d['notes'] as String),
                  if (d['cancellationReason'] != null) InfoRow(label: l10n.consCancelReason, text: d['cancellationReason'] as String),
                  const Divider(height: 24),
                  Text(l10n.consRoom, style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 8),
                  if (room == null)
                    Text(l10n.consRoomNone)
                  else ...[
                    Text('${l10n.colStatus}: ${room['state']}  ·  ${l10n.consReconnects}: ${room['reconnectAttempts']}'),
                    for (final e in (room['events'] as List<dynamic>).cast<Map<String, dynamic>>())
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text('${formatDateTime(context, DateTime.parse(e['at'] as String))}   ${e['type']}'),
                      ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.close)),
        if (manage && d?['canComplete'] == true) OutlinedButton(onPressed: () => _act(context, ref, cancel: false), child: Text(l10n.consComplete)),
        if (manage && d?['canCancel'] == true)
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: scheme.error, foregroundColor: scheme.onError),
            onPressed: () => _act(context, ref, cancel: true),
            child: Text(l10n.consCancel),
          ),
      ],
    );
  }
}
