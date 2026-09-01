import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:aqd_ionbit/core/localization/generated/app_localizations.dart';
import 'package:aqd_ionbit/core/routing/route_paths.dart';
import 'package:aqd_ionbit/core/theme/app_colors.dart';
import 'package:aqd_ionbit/core/theme/app_radii.dart';
import 'package:aqd_ionbit/core/theme/app_spacing.dart';
import 'package:aqd_ionbit/core/widgets/app_button.dart';
import 'package:aqd_ionbit/core/widgets/app_card.dart';
import 'package:aqd_ionbit/core/widgets/empty_state.dart';
import 'package:aqd_ionbit/core/widgets/error_view.dart';
import 'package:aqd_ionbit/core/widgets/loading_view.dart';
import 'package:aqd_ionbit/features/contracts/domain/entities/contract_template.dart';
import 'package:aqd_ionbit/features/contracts/presentation/providers/contract_draft_controller.dart';
import 'package:aqd_ionbit/features/contracts/presentation/providers/contract_templates_provider.dart';
import 'package:aqd_ionbit/features/contracts/presentation/widgets/contract_category_x.dart';

class ContractTypeSelectionScreen extends ConsumerStatefulWidget {
  const ContractTypeSelectionScreen({super.key});

  @override
  ConsumerState<ContractTypeSelectionScreen> createState() => _ContractTypeSelectionScreenState();
}

class _ContractTypeSelectionScreenState extends ConsumerState<ContractTypeSelectionScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  String? _selectedTemplateId;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _continue(List<ContractTemplate> templates) {
    final selected = templates.where((template) => template.id == _selectedTemplateId).firstOrNull;
    if (selected == null) return;
    ref.read(contractDraftControllerProvider.notifier).selectTemplate(selected);
    context.push(RoutePaths.clientContractsNewForm);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final templatesState = ref.watch(contractTemplatesProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.contractTypeSelectionTitle)),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.sm, AppSpacing.xl, AppSpacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.contractTypeSelectionSubtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextField(
                    controller: _searchController,
                    onChanged: (value) => setState(() => _query = value),
                    decoration: InputDecoration(hintText: l10n.contractTypeSearchHint, prefixIcon: const Icon(Icons.search)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: switch (templatesState) {
                AsyncData(value: final templates) => Builder(
                  builder: (context) {
                    final filtered = templates.where((t) => t.title.toLowerCase().contains(_query.toLowerCase())).toList();
                    if (filtered.isEmpty) {
                      return EmptyState(icon: Icons.search_off_outlined, message: l10n.contractTypeSearchEmptyMessage);
                    }
                    return GridView.builder(
                      padding: const EdgeInsets.fromLTRB(AppSpacing.xl, 0, AppSpacing.xl, AppSpacing.xl),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: AppSpacing.sm,
                        crossAxisSpacing: AppSpacing.sm,
                        childAspectRatio: 1.1,
                      ),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final template = filtered[index];
                        return _TemplateCard(
                          template: template,
                          selected: template.id == _selectedTemplateId,
                          onTap: () => setState(() => _selectedTemplateId = template.id),
                        );
                      },
                    );
                  },
                ),
                AsyncError() => ErrorView(message: l10n.errorGeneric, onRetry: () => ref.invalidate(contractTemplatesProvider)),
                _ => const LoadingView(),
              },
            ),
            if (templatesState.value != null)
              Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: AppButton(
                  label: l10n.commonContinue,
                  onPressed: _selectedTemplateId == null ? null : () => _continue(templatesState.value!),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _TemplateCard extends StatelessWidget {
  const _TemplateCard({required this.template, required this.selected, required this.onTap});

  final ContractTemplate template;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return AppCard(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected ? primary : primary.withValues(alpha: 0.1),
              borderRadius: AppRadii.mdRadius,
            ),
            child: Icon(template.category.icon, color: selected ? Colors.white : primary, size: 22),
          ),
          const SizedBox(height: AppSpacing.xs),
          Flexible(
            child: Text(
              template.title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.labelMedium?.copyWith(color: selected ? primary : null, fontWeight: selected ? FontWeight.w700 : null),
            ),
          ),
        ],
      ),
    );
  }
}
