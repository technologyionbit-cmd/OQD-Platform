import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' show DateFormat;

import 'package:aqd_ionbit/core/localization/generated/app_localizations.dart';
import 'package:aqd_ionbit/core/routing/route_paths.dart';
import 'package:aqd_ionbit/core/theme/app_spacing.dart';
import 'package:aqd_ionbit/core/theme/app_status_colors.dart';
import 'package:aqd_ionbit/core/widgets/app_button.dart';
import 'package:aqd_ionbit/core/widgets/app_card.dart';
import 'package:aqd_ionbit/core/widgets/confirmation_dialog.dart';
import 'package:aqd_ionbit/core/widgets/error_view.dart';
import 'package:aqd_ionbit/core/widgets/loading_view.dart';
import 'package:aqd_ionbit/core/widgets/status_badge.dart';
import 'package:aqd_ionbit/features/contracts/domain/entities/contract.dart';
import 'package:aqd_ionbit/features/contracts/domain/entities/contract_status.dart';
import 'package:aqd_ionbit/features/contracts/presentation/providers/contract_by_id_provider.dart';
import 'package:aqd_ionbit/features/contracts/presentation/providers/contract_draft_controller.dart';
import 'package:aqd_ionbit/features/contracts/presentation/providers/contract_templates_provider.dart';
import 'package:aqd_ionbit/features/contracts/presentation/providers/contracts_controller.dart';
import 'package:aqd_ionbit/features/contracts/presentation/widgets/contract_category_x.dart';
import 'package:aqd_ionbit/features/contracts/presentation/widgets/contract_signature_sheet.dart';
import 'package:aqd_ionbit/features/contracts/presentation/widgets/contract_status_x.dart';

class ContractDetailsScreen extends ConsumerWidget {
  const ContractDetailsScreen({super.key, required this.contractId, this.routeBase = RoutePaths.clientBase});

  final String contractId;
  final String routeBase;

  Future<void> _edit(BuildContext context, WidgetRef ref, Contract contract) async {
    final templates = await ref.read(contractTemplatesProvider.future);
    final template = templates.where((t) => t.id == contract.templateId).firstOrNull;
    if (template == null || !context.mounted) return;

    ref.read(contractDraftControllerProvider.notifier).startEditing(contract: contract, template: template);
    if (!context.mounted) return;
    context.push(RoutePaths.contractsNewFormFor(routeBase));
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showConfirmationDialog(
      context,
      title: l10n.contractDetailsDeleteConfirmTitle,
      message: l10n.contractDetailsDeleteConfirmMessage,
      confirmLabel: l10n.commonDelete,
      cancelLabel: l10n.commonCancel,
      isDestructive: true,
    );
    if (!confirmed || !context.mounted) return;

    final result = await ref.read(contractsControllerProvider.notifier).delete(contractId);
    if (!context.mounted) return;
    result.fold((failure) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.errorGeneric))), (_) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.contractDetailsDeletedMessage)));
      // Guard against a deep-linked details screen with no back-stack
      // (e.g. a future notification tap) rather than assuming a caller
      // always pushed this screen.
      if (context.canPop()) {
        context.pop();
      } else {
        context.go(RoutePaths.contractsRootFor(routeBase));
      }
    });
  }

  void _copyContent(BuildContext context, Contract contract) {
    final l10n = AppLocalizations.of(context)!;
    Clipboard.setData(ClipboardData(text: contract.generatedContent));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.contractContentCopiedMessage)));
  }

  Future<void> _sign(BuildContext context, WidgetRef ref, String contractId) async {
    final confirmed = await showContractSignatureSheet(context);
    if (confirmed != true || !context.mounted) return;

    final l10n = AppLocalizations.of(context)!;
    final result = await ref.read(contractsControllerProvider.notifier).sign(contractId);
    if (!context.mounted) return;

    result.fold((failure) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.errorGeneric))), (_) {
      // The details screen watches contractByIdProvider, a separate fetch
      // from contractsControllerProvider's list (which sign() already
      // refreshes) — without this it keeps showing the pre-sign status
      // until the provider is invalidated some other way.
      ref.invalidate(contractByIdProvider(contractId));
      return showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: dialogContext.statusColors.success.background, shape: BoxShape.circle),
                child: Icon(Icons.check, color: dialogContext.statusColors.success.foreground, size: 36),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(l10n.contractSignedSuccessTitle, textAlign: TextAlign.center, style: Theme.of(dialogContext).textTheme.titleMedium),
              const SizedBox(height: AppSpacing.xs),
              Text(
                l10n.contractSignedSuccessMessage,
                textAlign: TextAlign.center,
                style: Theme.of(dialogContext).textTheme.bodySmall,
              ),
            ],
          ),
          actions: [TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: Text(l10n.commonConfirm))],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final contractState = ref.watch(contractByIdProvider(contractId));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.contractDetailsTitle)),
      body: switch (contractState) {
        AsyncData(value: final contract) => SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            children: [
              Row(
                children: [
                  Expanded(child: Text(contract.title, style: Theme.of(context).textTheme.headlineSmall)),
                  StatusBadge(label: contract.status.label(l10n), tone: contract.status.tone),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _DetailRow(label: l10n.contractDetailsType, value: contract.category.label(l10n)),
                    const Divider(height: AppSpacing.lg),
                    _DetailRow(label: l10n.contractDetailsStatus, value: contract.status.label(l10n)),
                    const Divider(height: AppSpacing.lg),
                    _DetailRow(
                      label: l10n.contractDetailsCreated,
                      value: DateFormat.yMMMd(Localizations.localeOf(context).toLanguageTag()).format(contract.createdAt),
                    ),
                    const Divider(height: AppSpacing.lg),
                    _DetailRow(
                      label: l10n.contractDetailsUpdated,
                      value: DateFormat.yMMMd(Localizations.localeOf(context).toLanguageTag()).format(contract.updatedAt),
                    ),
                    if (contract.parties.isNotEmpty) ...[
                      const Divider(height: AppSpacing.lg),
                      _DetailRow(label: l10n.contractPreviewParties, value: contract.parties.join(' — ')),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(l10n.contractDetailsContent, style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: AppSpacing.xs),
              AppCard(
                child: Text(contract.generatedContent, style: Theme.of(context).textTheme.bodyMedium),
              ),
              const SizedBox(height: AppSpacing.lg),
              AppButton(
                label: l10n.commonCopy,
                icon: Icons.copy_outlined,
                variant: AppButtonVariant.outlined,
                onPressed: () => _copyContent(context, contract),
              ),
              if (contract.status == ContractStatus.pendingSignature) ...[
                const SizedBox(height: AppSpacing.sm),
                AppButton(
                  label: l10n.contractSignButton,
                  icon: Icons.draw_outlined,
                  variant: AppButtonVariant.success,
                  onPressed: () => _sign(context, ref, contract.id),
                ),
              ],
              if (contract.status == ContractStatus.draft && routeBase != RoutePaths.lawyerBase) ...[
                const SizedBox(height: AppSpacing.sm),
                AppButton(label: l10n.commonEdit, icon: Icons.edit_outlined, onPressed: () => _edit(context, ref, contract)),
                const SizedBox(height: AppSpacing.sm),
                AppButton(
                  label: l10n.commonDelete,
                  icon: Icons.delete_outline,
                  variant: AppButtonVariant.destructive,
                  onPressed: () => _delete(context, ref),
                ),
              ],
            ],
          ),
        ),
        AsyncError() => ErrorView(message: l10n.errorGeneric, onRetry: () => ref.invalidate(contractByIdProvider(contractId))),
        _ => const LoadingView(),
      },
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(label, style: Theme.of(context).textTheme.bodySmall)),
        const SizedBox(width: AppSpacing.sm),
        Expanded(child: Text(value, textAlign: TextAlign.end, style: Theme.of(context).textTheme.bodyMedium)),
      ],
    );
  }
}
