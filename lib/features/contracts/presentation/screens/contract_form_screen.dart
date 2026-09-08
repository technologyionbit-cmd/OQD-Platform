import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:aqd_ionbit/core/localization/generated/app_localizations.dart';
import 'package:aqd_ionbit/core/routing/route_paths.dart';
import 'package:aqd_ionbit/core/theme/app_spacing.dart';
import 'package:aqd_ionbit/core/widgets/app_button.dart';
import 'package:aqd_ionbit/core/widgets/empty_state.dart';
import 'package:aqd_ionbit/features/contracts/presentation/providers/contract_draft_controller.dart';
import 'package:aqd_ionbit/features/contracts/presentation/widgets/contract_field_widget.dart';

/// Purely field-driven: this screen has no idea what an "employment
/// contract" or "NDA" is — it just maps `template.fields` through
/// [ContractFieldWidget]. A new contract category never needs a new
/// screen, only a new [ContractTemplate] in the data source.
class ContractFormScreen extends ConsumerWidget {
  const ContractFormScreen({super.key, this.routeBase = RoutePaths.clientBase});

  final String routeBase;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final draft = ref.watch(contractDraftControllerProvider);
    final template = draft.template;

    if (template == null) {
      // No template selected — e.g. a stale deep link straight to the form
      // route. Send them back to pick one rather than rendering an empty
      // form that can't be submitted.
      return Scaffold(
        appBar: AppBar(title: Text(l10n.contractFormTitle)),
        body: EmptyState(
          icon: Icons.error_outline,
          message: l10n.errorGeneric,
          action: AppButton(label: l10n.commonContinue, onPressed: () => context.go(RoutePaths.contractsNewFor(routeBase))),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(template.title)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          children: [
            for (final field in template.fields) ...[
              ContractFieldWidget(field: field, initialValue: draft.fieldValues[field.id]),
              const SizedBox(height: AppSpacing.md),
            ],
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: AppButton(
            label: l10n.commonContinue,
            onPressed: () {
              if (ref.read(contractDraftControllerProvider.notifier).validate(l10n)) {
                context.push(RoutePaths.contractsNewPreviewFor(routeBase));
              }
            },
          ),
        ),
      ),
    );
  }
}
