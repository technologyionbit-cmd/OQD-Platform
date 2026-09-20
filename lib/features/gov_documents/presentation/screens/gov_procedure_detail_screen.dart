import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aqd_ionbit/core/localization/generated/app_localizations.dart';
import 'package:aqd_ionbit/core/theme/app_colors.dart';
import 'package:aqd_ionbit/core/theme/app_radii.dart';
import 'package:aqd_ionbit/core/theme/app_spacing.dart';
import 'package:aqd_ionbit/core/theme/app_status_colors.dart';
import 'package:aqd_ionbit/core/widgets/app_button.dart';
import 'package:aqd_ionbit/core/widgets/app_card.dart';
import 'package:aqd_ionbit/core/widgets/empty_state.dart';
import 'package:aqd_ionbit/core/widgets/error_view.dart';
import 'package:aqd_ionbit/core/widgets/icon_badge.dart';
import 'package:aqd_ionbit/core/widgets/loading_view.dart';
import 'package:aqd_ionbit/core/widgets/section_header.dart';
import 'package:aqd_ionbit/features/gov_documents/domain/entities/gov_procedure.dart';
import 'package:aqd_ionbit/features/gov_documents/presentation/providers/gov_procedures_provider.dart';
import 'package:aqd_ionbit/features/gov_documents/presentation/widgets/gov_procedure_type_x.dart';

class GovProcedureDetailScreen extends ConsumerWidget {
  const GovProcedureDetailScreen({super.key, required this.procedureTypeName});

  final String procedureTypeName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final proceduresState = ref.watch(govProceduresProvider);

    return switch (proceduresState) {
      AsyncData(value: final procedures) => _buildBody(
        context,
        ref,
        l10n,
        procedures.where((p) => p.type.name == procedureTypeName).firstOrNull,
      ),
      AsyncError() => Scaffold(
        appBar: AppBar(title: Text(l10n.govDocumentsTitle)),
        body: ErrorView(message: l10n.errorGeneric, onRetry: () => ref.read(govProceduresProvider.notifier).refresh()),
      ),
      _ => Scaffold(appBar: AppBar(title: Text(l10n.govDocumentsTitle)), body: const LoadingView()),
    };
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, AppLocalizations l10n, GovProcedure? procedure) {
    if (procedure == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.govDocumentsTitle)),
        body: EmptyState(icon: Icons.error_outline, message: l10n.errorGeneric),
      );
    }

    final progress =
        ref.watch(govProceduresProgressControllerProvider).value?[procedure.type] ?? const GovProcedureProgress();
    final type = procedure.type;
    final checkedCount = procedure.requiredDocuments.where((d) => progress.checkedDocumentIds.contains(d.id)).length;

    return Scaffold(
      appBar: AppBar(title: Text(type.title(l10n))),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          children: [
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconBadge(icon: type.icon, size: 56),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(type.title(l10n), style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: AppSpacing.xxs),
                            Text(type.category(l10n), style: Theme.of(context).textTheme.bodySmall),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.xs,
                    runSpacing: AppSpacing.xs,
                    children: [
                      Chip(avatar: const Icon(Icons.schedule, size: 14), label: Text(procedure.durationLabel)),
                      Chip(avatar: const Icon(Icons.checklist, size: 14), label: Text(l10n.govStepsCount(procedure.steps.length))),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      Icon(procedure.accessType.icon, size: 16, color: context.statusColors.success.foreground),
                      const SizedBox(width: AppSpacing.xxs),
                      Text(
                        procedure.accessType.label(l10n),
                        style: TextStyle(color: context.statusColors.success.foreground, fontWeight: FontWeight.w700),
                      ),
                      if (progress.started) ...[
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs, vertical: AppSpacing.xxs),
                          decoration: BoxDecoration(color: context.statusColors.info.background, borderRadius: AppRadii.smRadius),
                          child: Text(
                            l10n.govProcedureStatusInProgress,
                            style: TextStyle(color: context.statusColors.info.foreground, fontSize: 11, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            SectionHeader(
              title: l10n.govRequiredDocumentsTitle,
              actionLabel: l10n.govRequiredDocumentsProgress(checkedCount, procedure.requiredDocuments.length),
            ),
            const SizedBox(height: AppSpacing.xs),
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  for (var i = 0; i < procedure.requiredDocuments.length; i++) ...[
                    CheckboxListTile(
                      value: progress.checkedDocumentIds.contains(procedure.requiredDocuments[i].id),
                      title: Text(procedure.requiredDocuments[i].title, style: Theme.of(context).textTheme.bodyMedium),
                      controlAffinity: ListTileControlAffinity.leading,
                      onChanged: (_) => ref
                          .read(govProceduresProgressControllerProvider.notifier)
                          .toggleDocument(type, procedure.requiredDocuments[i].id),
                    ),
                    if (i != procedure.requiredDocuments.length - 1) const Divider(height: 1),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            SectionHeader(title: l10n.govProcedureStepsTitle),
            const SizedBox(height: AppSpacing.xs),
            for (var i = 0; i < procedure.steps.length; i++) ...[
              _StepRow(step: procedure.steps[i], isLast: i == procedure.steps.length - 1),
            ],
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: AppButton(
            label: l10n.govStartProcedure,
            onPressed: progress.started
                ? null
                : () {
                    ref.read(govProceduresProgressControllerProvider.notifier).start(type);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.govProcedureStartedMessage)));
                  },
          ),
        ),
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({required this.step, required this.isLast});

  final GovProcedureStep step;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 26,
                height: 26,
                alignment: Alignment.center,
                decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                child: Text('${step.order}', style: const TextStyle(color: AppColors.onPrimary, fontSize: 12, fontWeight: FontWeight.w700)),
              ),
              if (!isLast) const Expanded(child: VerticalDivider(width: 1, color: AppColors.border)),
            ],
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(step.title, style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(step.description, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
