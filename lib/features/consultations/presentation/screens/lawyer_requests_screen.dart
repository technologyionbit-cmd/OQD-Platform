import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' show DateFormat;

import 'package:aqd_ionbit/core/localization/generated/app_localizations.dart';
import 'package:aqd_ionbit/core/routing/route_paths.dart';
import 'package:aqd_ionbit/core/theme/app_spacing.dart';
import 'package:aqd_ionbit/core/widgets/app_button.dart';
import 'package:aqd_ionbit/core/widgets/app_card.dart';
import 'package:aqd_ionbit/core/widgets/confirmation_dialog.dart';
import 'package:aqd_ionbit/core/widgets/empty_state.dart';
import 'package:aqd_ionbit/core/widgets/error_view.dart';
import 'package:aqd_ionbit/core/widgets/icon_badge.dart';
import 'package:aqd_ionbit/core/widgets/loading_view.dart';
import 'package:aqd_ionbit/features/consultations/domain/entities/consultation.dart';
import 'package:aqd_ionbit/features/consultations/domain/entities/consultation_status.dart';
import 'package:aqd_ionbit/features/consultations/presentation/providers/consultations_controller.dart';
import 'package:aqd_ionbit/features/lawyers/domain/entities/lawyer_profile.dart';
import 'package:aqd_ionbit/features/lawyers/presentation/widgets/consultation_type_x.dart';

/// Pending consultation requests awaiting the demo lawyer's Accept/Reject
/// — a distinct screen from `ConsultationsListScreen` per the product
/// brief's own split between "requests" and "consultations".
class LawyerRequestsScreen extends ConsumerWidget {
  const LawyerRequestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final consultationsState = ref.watch(consultationsControllerProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.lawyerRequestsTitle)),
      body: switch (consultationsState) {
        AsyncData(value: final consultations) => Builder(
          builder: (context) {
            final pending = consultations
                .where((c) => c.lawyerId == kDemoLawyerId && c.status == ConsultationStatus.pendingApproval)
                .toList();
            if (pending.isEmpty) {
              return EmptyState(title: l10n.lawyerRequestsEmptyTitle, message: l10n.lawyerRequestsEmptyMessage);
            }
            return RefreshIndicator(
              onRefresh: () => ref.read(consultationsControllerProvider.notifier).refresh(),
              child: ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.xl),
                itemCount: pending.length,
                separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.sm),
                itemBuilder: (context, index) => _RequestCard(consultation: pending[index]),
              ),
            );
          },
        ),
        AsyncError() => ErrorView(message: l10n.errorGeneric, onRetry: () => ref.read(consultationsControllerProvider.notifier).refresh()),
        _ => const LoadingView(),
      },
    );
  }
}

class _RequestCard extends ConsumerStatefulWidget {
  const _RequestCard({required this.consultation});

  final Consultation consultation;

  @override
  ConsumerState<_RequestCard> createState() => _RequestCardState();
}

class _RequestCardState extends ConsumerState<_RequestCard> {
  bool _isProcessing = false;

  Future<void> _respond({required bool accept}) async {
    final l10n = AppLocalizations.of(context)!;
    if (!accept) {
      final confirmed = await showConfirmationDialog(
        context,
        title: l10n.lawyerRequestRejectConfirmTitle,
        message: l10n.lawyerRequestRejectConfirmMessage,
        confirmLabel: l10n.lawyerRequestReject,
        cancelLabel: l10n.commonCancel,
        isDestructive: true,
      );
      if (!confirmed || !mounted) return;
    }

    setState(() => _isProcessing = true);
    final notifier = ref.read(consultationsControllerProvider.notifier);
    final result = accept ? await notifier.acceptRequest(widget.consultation.id) : await notifier.rejectRequest(widget.consultation.id);
    if (!mounted) return;
    setState(() => _isProcessing = false);

    result.fold(
      (failure) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.errorGeneric))),
      (_) => ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(accept ? l10n.lawyerRequestAcceptedMessage : l10n.lawyerRequestRejectedMessage))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final consultation = widget.consultation;

    return AppCard(
      onTap: () => context.push(RoutePaths.lawyerConsultationDetails(consultation.id)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconBadge(icon: consultation.type.icon, size: 44),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(consultation.clientName, style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      '${consultation.type.label(l10n)} · ${DateFormat.yMMMd(locale).add_jm().format(consultation.scheduledAt)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (consultation.notes.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(consultation.notes, maxLines: 2, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodySmall),
          ],
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: l10n.lawyerRequestReject,
                  variant: AppButtonVariant.outlined,
                  onPressed: _isProcessing ? null : () => _respond(accept: false),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: AppButton(
                  label: l10n.lawyerRequestAccept,
                  variant: AppButtonVariant.success,
                  isLoading: _isProcessing,
                  onPressed: _isProcessing ? null : () => _respond(accept: true),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
