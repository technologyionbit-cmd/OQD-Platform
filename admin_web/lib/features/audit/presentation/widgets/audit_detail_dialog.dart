import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aqd_admin/core/localization/generated/app_localizations.dart';
import 'package:aqd_admin/core/utils/formatters.dart';
import 'package:aqd_admin/core/widgets/info_card.dart';
import 'package:aqd_admin/core/widgets/state_views.dart';
import 'package:aqd_admin/features/audit/domain/audit_entry.dart';
import 'package:aqd_admin/features/audit/presentation/providers/audit_providers.dart';

Future<void> showAuditDetail(BuildContext context, String id) {
  return showDialog<void>(context: context, builder: (_) => _AuditDetailDialog(id: id));
}

class _AuditDetailDialog extends ConsumerWidget {
  const _AuditDetailDialog({required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final detail = ref.watch(auditDetailProvider(id));
    return AlertDialog(
      title: Text(l10n.auditDetailTitle),
      content: SizedBox(
        width: 720,
        height: 560,
        child: detail.when(
          loading: () => const LoadingView(),
          error: (error, _) => ErrorView(error: error, onRetry: () => ref.invalidate(auditDetailProvider(id))),
          data: (entry) => SingleChildScrollView(child: _Body(entry: entry)),
        ),
      ),
      actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.close))],
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.entry});

  final AuditDetail entry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InfoCard(
          title: l10n.auditRequest,
          children: [
            InfoRow(label: l10n.colAction, text: entry.action),
            InfoRow(label: l10n.colActor, text: entry.actor == null ? '-' : '${entry.actor!.fullName} (${entry.actor!.email})'),
            InfoRow(label: l10n.colWhen, text: formatDateTime(context, entry.createdAt)),
            InfoRow(label: l10n.colEntity, text: [entry.entityType, entry.entityId].whereType<String>().join(' · ')),
            InfoRow(label: l10n.colOutcome, text: '${entry.method} ${entry.path} → ${entry.statusCode}'),
            InfoRow(label: l10n.colIp, text: entry.ipAddress),
            InfoRow(label: l10n.sessionDevice, text: entry.userAgent),
          ],
        ),
        const SizedBox(height: 12),
        _JsonBlock(title: l10n.auditBefore, value: entry.before),
        const SizedBox(height: 12),
        _JsonBlock(title: l10n.auditAfter, value: entry.after),
        const SizedBox(height: 12),
        _JsonBlock(title: l10n.auditMeta, value: entry.meta),
      ],
    );
  }
}

class _JsonBlock extends StatelessWidget {
  const _JsonBlock({required this.title, required this.value});

  final String title;
  final Object? value;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return InfoCard(
      title: title,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: scheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(8)),
          child: SelectableText(
            value == null ? l10n.auditNothing : const JsonEncoder.withIndent('  ').convert(value),
            textDirection: TextDirection.ltr,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 12.5, height: 1.5),
          ),
        ),
      ],
    );
  }
}
