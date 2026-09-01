import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:aqd_ionbit/core/localization/generated/app_localizations.dart';
import 'package:aqd_ionbit/core/routing/route_paths.dart';
import 'package:aqd_ionbit/core/theme/app_colors.dart';
import 'package:aqd_ionbit/core/theme/app_spacing.dart';
import 'package:aqd_ionbit/core/widgets/app_button.dart';
import 'package:aqd_ionbit/core/widgets/app_card.dart';
import 'package:aqd_ionbit/core/widgets/empty_state.dart';
import 'package:aqd_ionbit/features/contracts/domain/entities/contract_field.dart';
import 'package:aqd_ionbit/features/contracts/presentation/providers/contract_draft_controller.dart';

class ContractPreviewScreen extends ConsumerStatefulWidget {
  const ContractPreviewScreen({super.key});

  @override
  ConsumerState<ContractPreviewScreen> createState() => _ContractPreviewScreenState();
}

class _ContractPreviewScreenState extends ConsumerState<ContractPreviewScreen> {
  bool _isSubmitting = false;
  String? _generatedContractId;

  Future<void> _saveDraft() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _isSubmitting = true);
    final result = await ref.read(contractDraftControllerProvider.notifier).saveDraft();
    if (!mounted) return;
    setState(() => _isSubmitting = false);

    result.fold((failure) => _showError(l10n), (contract) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.contractDraftSavedMessage)));
      context.go(RoutePaths.clientContractDetails(contract.id));
    });
  }

  Future<void> _generate() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _isSubmitting = true);
    final result = await ref.read(contractDraftControllerProvider.notifier).generate();
    if (!mounted) return;
    setState(() => _isSubmitting = false);

    result.fold((failure) => _showError(l10n), (contract) => setState(() => _generatedContractId = contract.id));
  }

  void _showError(AppLocalizations l10n) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.errorGeneric)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (_generatedContractId != null) {
      return Scaffold(body: _GeneratedSuccessView(contractId: _generatedContractId!));
    }

    final draft = ref.watch(contractDraftControllerProvider);
    final template = draft.template;
    if (template == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.contractPreviewTitle)),
        body: EmptyState(icon: Icons.error_outline, message: l10n.errorGeneric),
      );
    }

    final partyFields = template.fields.where((field) => field.id == 'partyA' || field.id == 'partyB');
    final detailFields = template.fields.where((field) => field.id != 'partyA' && field.id != 'partyB');

    return Scaffold(
      appBar: AppBar(title: Text(l10n.contractPreviewTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          children: [
            Text(template.title, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: AppSpacing.lg),
            if (partyFields.isNotEmpty) ...[
              Text(l10n.contractPreviewParties, style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: AppSpacing.xs),
              AppCard(child: _FieldValueList(fields: partyFields, values: draft.fieldValues)),
              const SizedBox(height: AppSpacing.lg),
            ],
            if (detailFields.isNotEmpty) ...[
              Text(l10n.contractPreviewDetails, style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: AppSpacing.xs),
              AppCard(child: _FieldValueList(fields: detailFields, values: draft.fieldValues)),
            ],
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.sm, AppSpacing.xl, AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Primary CTA gets the success-green treatment and full
              // width, matching how the reference screenshots emphasize
              // the sign/generate action over the secondary ones below it.
              AppButton(
                label: l10n.contractPreviewGenerate,
                variant: AppButtonVariant.success,
                isLoading: _isSubmitting,
                onPressed: _isSubmitting ? null : _generate,
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: l10n.commonEdit,
                      variant: AppButtonVariant.outlined,
                      onPressed: _isSubmitting ? null : () => context.pop(),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: AppButton(
                      label: l10n.contractPreviewSaveDraft,
                      variant: AppButtonVariant.outlined,
                      onPressed: _isSubmitting ? null : _saveDraft,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FieldValueList extends StatelessWidget {
  const _FieldValueList({required this.fields, required this.values});

  final Iterable<ContractField> fields;
  final Map<String, String> values;

  @override
  Widget build(BuildContext context) {
    final entries = fields.where((field) => (values[field.id] ?? '').isNotEmpty).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < entries.length; i++) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(entries[i].label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  values[entries[i].id]!,
                  textAlign: TextAlign.end,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ),
          if (i != entries.length - 1) const Padding(padding: EdgeInsets.symmetric(vertical: AppSpacing.xs), child: Divider(height: 1)),
        ],
      ],
    );
  }
}

class _GeneratedSuccessView extends StatelessWidget {
  const _GeneratedSuccessView({required this.contractId});

  final String contractId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 88,
                height: 88,
                alignment: Alignment.center,
                decoration: const BoxDecoration(color: AppColors.successBackground, shape: BoxShape.circle),
                child: const Icon(Icons.check, color: AppColors.success, size: 40),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(l10n.contractGeneratedSuccessTitle, textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: AppSpacing.xs),
              Text(
                l10n.contractGeneratedSuccessMessage,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.xl),
              AppButton(
                label: l10n.contractViewDetails,
                onPressed: () => context.go(RoutePaths.clientContractDetails(contractId)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
