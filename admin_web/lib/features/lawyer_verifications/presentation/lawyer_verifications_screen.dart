import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aqd_admin/core/localization/generated/app_localizations.dart';
import 'package:aqd_admin/features/auth/presentation/providers/access.dart';
import 'package:aqd_admin/core/utils/file_saver.dart';
import 'package:aqd_admin/core/utils/formatters.dart';
import 'package:aqd_admin/core/widgets/confirm_dialog.dart';
import 'package:aqd_admin/core/widgets/page_header.dart';
import 'package:aqd_admin/core/widgets/reason_dialog.dart';
import 'package:aqd_admin/core/widgets/snacks.dart';
import 'package:aqd_admin/core/widgets/state_views.dart';
import 'package:aqd_admin/features/lawyer_verifications/domain/pending_lawyer.dart';
import 'package:aqd_admin/features/lawyer_verifications/presentation/providers/verifications_providers.dart';

class LawyerVerificationsScreen extends ConsumerWidget {
  const LawyerVerificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final pending = ref.watch(pendingLawyersProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PageHeader(
          title: l10n.navLawyerVerifications,
          subtitle: pending.value == null ? l10n.verifSubtitle : '${l10n.verifSubtitle}  ·  ${l10n.verifPendingCount(pending.value!.length)}',
          actions: [
            IconButton(tooltip: l10n.retry, onPressed: () => ref.invalidate(pendingLawyersProvider), icon: const Icon(Icons.refresh)),
          ],
        ),
        Expanded(
          child: pending.when(
            loading: () => const LoadingView(),
            error: (error, _) => ErrorView(error: error, onRetry: () => ref.invalidate(pendingLawyersProvider)),
            data: (lawyers) => lawyers.isEmpty
                ? EmptyView(title: l10n.verifEmptyTitle, body: l10n.verifEmptyBody)
                : ListView.separated(
                    itemCount: lawyers.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 16),
                    itemBuilder: (_, i) => _PendingCard(lawyer: lawyers[i]),
                  ),
          ),
        ),
      ],
    );
  }
}

class _PendingCard extends ConsumerStatefulWidget {
  const _PendingCard({required this.lawyer});

  final PendingLawyer lawyer;

  @override
  ConsumerState<_PendingCard> createState() => _PendingCardState();
}

class _PendingCardState extends ConsumerState<_PendingCard> {
  bool _busy = false;

  Future<void> _decide({required bool approve}) async {
    final l10n = AppLocalizations.of(context);
    final lawyer = widget.lawyer;
    final repo = ref.read(verificationsRepositoryProvider);
    String? reason;
    if (approve) {
      final ok = await showConfirmDialog(context, title: l10n.verifApproveTitle, message: l10n.verifApproveBody(lawyer.fullName), confirmLabel: l10n.verifApprove);
      if (!ok) return;
    } else {
      reason = await showReasonDialog(context, title: l10n.verifRejectTitle, message: l10n.verifRejectBody(lawyer.fullName), confirmLabel: l10n.verifReject);
      if (reason == null) return;
    }
    if (!mounted) return;
    setState(() => _busy = true);
    try {
      if (approve) {
        await repo.approve(lawyer.lawyerProfileId);
      } else {
        await repo.reject(lawyer.lawyerProfileId, reason: reason!);
      }
      ref.invalidate(pendingLawyersProvider);
      if (mounted) showSuccessSnack(context, approve ? l10n.verifApprovedDone : l10n.verifRejectedDone);
    } on Object catch (error) {
      if (mounted) {
        setState(() => _busy = false);
        showFailureSnack(context, error);
      }
    }
  }

  Future<void> _download(VerificationDocument doc) async {
    try {
      final bytes = await ref.read(verificationsRepositoryProvider).document(widget.lawyer.lawyerProfileId, doc.id);
      await ref.read(fileSaverProvider)(doc.originalName, bytes, doc.mimeType);
    } on Object catch (error) {
      if (mounted) showFailureSnack(context, error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final lawyer = widget.lawyer;
    final muted = theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(lawyer.fullName, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 20,
                        runSpacing: 4,
                        children: [
                          Text(lawyer.email, style: muted),
                          if (lawyer.phone != null) Text(lawyer.phone!, style: muted, textDirection: TextDirection.ltr),
                          Text('${l10n.colBarLicense}: ${lawyer.barLicenseNumber}', style: muted),
                          if (lawyer.submittedAt != null) Text(l10n.verifSubmitted(formatDateTime(context, lawyer.submittedAt)), style: muted),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                if (!canManage(ref, 'lawyers'))
                  const SizedBox.shrink()
                else if (_busy)
                  const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                else
                  Wrap(
                    spacing: 8,
                    children: [
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(foregroundColor: theme.colorScheme.error),
                        onPressed: () => _decide(approve: false),
                        icon: const Icon(Icons.close, size: 18),
                        label: Text(l10n.verifReject),
                      ),
                      FilledButton.icon(onPressed: () => _decide(approve: true), icon: const Icon(Icons.check, size: 18), label: Text(l10n.verifApprove)),
                    ],
                  ),
              ],
            ),
            const Divider(height: 28),
            Text(l10n.verifDocuments, style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            if (lawyer.documents.isEmpty)
              Text(l10n.verifNoDocuments, style: muted)
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final doc in lawyer.documents)
                    ActionChip(
                      avatar: const Icon(Icons.download_outlined, size: 18),
                      label: Text('${doc.originalName}  (${_size(doc.sizeBytes)})'),
                      onPressed: () => _download(doc),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  static String _size(int bytes) => bytes < 1024 * 1024 ? '${(bytes / 1024).ceil()} KB' : '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
}
