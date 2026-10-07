import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:aqd_ionbit/core/localization/generated/app_localizations.dart';
import 'package:aqd_ionbit/core/routing/route_paths.dart';
import 'package:aqd_ionbit/core/theme/app_colors.dart';
import 'package:aqd_ionbit/core/theme/app_radii.dart';
import 'package:aqd_ionbit/core/theme/app_spacing.dart';
import 'package:aqd_ionbit/core/theme/app_status_colors.dart';
import 'package:aqd_ionbit/core/widgets/app_card.dart';
import 'package:aqd_ionbit/core/widgets/empty_state.dart';
import 'package:aqd_ionbit/core/widgets/error_view.dart';
import 'package:aqd_ionbit/core/widgets/icon_badge.dart';
import 'package:aqd_ionbit/core/widgets/loading_view.dart';
import 'package:aqd_ionbit/features/gov_documents/domain/entities/gov_procedure.dart';
import 'package:aqd_ionbit/features/gov_documents/presentation/providers/gov_procedures_provider.dart';
import 'package:aqd_ionbit/features/gov_documents/presentation/widgets/gov_procedure_type_x.dart';

/// The reference's "المستندات الحكومية" hub — a searchable list of the
/// four government-document procedures, each opening its own detail flow.
class GovDocumentsHubScreen extends ConsumerStatefulWidget {
  const GovDocumentsHubScreen({super.key});

  @override
  ConsumerState<GovDocumentsHubScreen> createState() => _GovDocumentsHubScreenState();
}

class _GovDocumentsHubScreenState extends ConsumerState<GovDocumentsHubScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final proceduresState = ref.watch(govProceduresProvider);
    final query = _query.trim().toLowerCase();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.govDocumentsTitle)),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.md, AppSpacing.xl, AppSpacing.sm),
              child: TextField(
                controller: _searchController,
                onChanged: (value) => setState(() => _query = value),
                decoration: InputDecoration(hintText: l10n.govDocumentsSearchHint, prefixIcon: const Icon(Icons.search)),
              ),
            ),
            Expanded(
              child: switch (proceduresState) {
                AsyncData(value: final procedures) => Builder(
                  builder: (context) {
                    final filtered = query.isEmpty
                        ? procedures
                        : procedures.where((p) => p.type.title(l10n).toLowerCase().contains(query)).toList();
                    if (filtered.isEmpty) {
                      return EmptyState(icon: Icons.search_off_outlined, message: l10n.documentsSearchEmptyMessage);
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.fromLTRB(AppSpacing.xl, 0, AppSpacing.xl, AppSpacing.xl),
                      itemCount: filtered.length,
                      separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.sm),
                      itemBuilder: (context, index) => _ProcedureCard(procedure: filtered[index]),
                    );
                  },
                ),
                AsyncError() => ErrorView(
                  message: l10n.errorGeneric,
                  onRetry: () => ref.read(govProceduresProvider.notifier).refresh(),
                ),
                _ => const LoadingView(),
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ProcedureCard extends StatelessWidget {
  const _ProcedureCard({required this.procedure});

  final GovProcedure procedure;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final type = procedure.type;

    return AppCard(
      onTap: () => context.push(RoutePaths.clientGovDocumentDetails(type.name)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconBadge(icon: type.icon),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(type.title(l10n), style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: AppSpacing.xxs),
                Wrap(
                  spacing: AppSpacing.xxs,
                  runSpacing: 4,
                  children: [
                    _MiniTag(label: type.category(l10n)),
                    _MiniTag(icon: Icons.schedule, label: procedure.durationLabel),
                    _MiniTag(icon: Icons.checklist, label: l10n.govStepsCount(procedure.steps.length)),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    Icon(procedure.accessType.icon, size: 14, color: context.statusColors.success.foreground),
                    const SizedBox(width: AppSpacing.xxs),
                    Text(
                      procedure.accessType.label(l10n),
                      style: Theme.of(
                        context,
                      ).textTheme.labelSmall?.copyWith(color: context.statusColors.success.foreground, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Icon(
            Directionality.of(context) == TextDirection.rtl ? Icons.chevron_left : Icons.chevron_right,
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }
}

class _MiniTag extends StatelessWidget {
  const _MiniTag({required this.label, this.icon});

  final String label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxs, vertical: AppSpacing.xxs),
      decoration: BoxDecoration(color: context.statusColors.neutral.background, borderRadius: AppRadii.smRadius),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: 11, color: AppColors.neutral), const SizedBox(width: AppSpacing.xxs)],
          Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
