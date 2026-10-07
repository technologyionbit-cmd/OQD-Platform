import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' show DateFormat;

import 'package:aqd_ionbit/core/errors/failure.dart';
import 'package:aqd_ionbit/core/errors/failure_message.dart';
import 'package:aqd_ionbit/core/localization/generated/app_localizations.dart';
import 'package:aqd_ionbit/core/routing/route_paths.dart';
import 'package:aqd_ionbit/core/theme/app_spacing.dart';
import 'package:aqd_ionbit/core/theme/app_status_colors.dart';
import 'package:aqd_ionbit/core/widgets/app_button.dart';
import 'package:aqd_ionbit/core/widgets/app_card.dart';
import 'package:aqd_ionbit/core/widgets/empty_state.dart';
import 'package:aqd_ionbit/features/contracts/domain/entities/contract_field.dart';
import 'package:aqd_ionbit/features/contracts/domain/entities/contract_field_type.dart';
import 'package:aqd_ionbit/features/contracts/presentation/providers/contract_draft_controller.dart';

class ContractPreviewScreen extends ConsumerStatefulWidget {
  const ContractPreviewScreen({super.key, this.routeBase = RoutePaths.clientBase});

  final String routeBase;

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

    result.fold((failure) => _showError(failure, l10n), (contract) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.contractDraftSavedMessage)));
      context.go(RoutePaths.contractDetailsFor(widget.routeBase, contract.id));
    });
  }

  Future<void> _generate() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _isSubmitting = true);
    final result = await ref.read(contractDraftControllerProvider.notifier).generate();
    if (!mounted) return;
    setState(() => _isSubmitting = false);

    result.fold((failure) => _showError(failure, l10n), (contract) => setState(() => _generatedContractId = contract.id));
  }

  void _showError(Failure failure, AppLocalizations l10n) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(failure.localizedMessage(l10n))));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (_generatedContractId != null) {
      return Scaffold(body: _GeneratedSuccessView(contractId: _generatedContractId!, routeBase: widget.routeBase));
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
                child: Text(entries[i].label, style: Theme.of(context).textTheme.bodySmall),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  _display(context, entries[i], values[entries[i].id]!),
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

  /// Dropdowns store a language-independent value and dates an ISO string;
  /// show the option's label and a readable date instead.
  String _display(BuildContext context, ContractField field, String value) {
    return switch (field.type) {
      ContractFieldType.dropdown => field.options.where((option) => option.value == value).firstOrNull?.label ?? value,
      ContractFieldType.date => switch (DateTime.tryParse(value)) {
        final date? => DateFormat.yMMMd(Localizations.localeOf(context).toLanguageTag()).format(date),
        null => value,
      },
      _ => value,
    };
  }
}

class _GeneratedSuccessView extends StatelessWidget {
  const _GeneratedSuccessView({required this.contractId, required this.routeBase});

  final String contractId;
  final String routeBase;

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
                decoration: BoxDecoration(color: context.statusColors.success.background, shape: BoxShape.circle),
                child: Icon(Icons.check, color: context.statusColors.success.foreground, size: 40),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(l10n.contractGeneratedSuccessTitle, textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: AppSpacing.xs),
              Text(
                l10n.contractGeneratedSuccessMessage,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.xl),
              AppButton(
                label: l10n.contractViewDetails,
                onPressed: () => context.go(RoutePaths.contractDetailsFor(routeBase, contractId)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
