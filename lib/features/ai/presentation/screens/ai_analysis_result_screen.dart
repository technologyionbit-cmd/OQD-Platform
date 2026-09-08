import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:aqd_ionbit/core/localization/generated/app_localizations.dart';
import 'package:aqd_ionbit/core/routing/route_paths.dart';
import 'package:aqd_ionbit/core/theme/app_radii.dart';
import 'package:aqd_ionbit/core/theme/app_spacing.dart';
import 'package:aqd_ionbit/core/theme/app_status_colors.dart';
import 'package:aqd_ionbit/core/widgets/app_card.dart';
import 'package:aqd_ionbit/core/widgets/empty_state.dart';
import 'package:aqd_ionbit/core/widgets/error_view.dart';
import 'package:aqd_ionbit/core/widgets/loading_view.dart';
import 'package:aqd_ionbit/core/widgets/status_badge.dart';
import 'package:aqd_ionbit/features/ai/domain/entities/analysis_clause.dart';
import 'package:aqd_ionbit/features/ai/presentation/providers/ai_analyses_controller.dart';
import 'package:aqd_ionbit/features/ai/presentation/widgets/analysis_risk_level_x.dart';

class AiAnalysisResultScreen extends ConsumerWidget {
  const AiAnalysisResultScreen({super.key, required this.analysisId});

  final String analysisId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    // Analyses are created (and populate the controller's state) before
    // this route is ever pushed — see `AiAnalysisSelectScreen`. Still watch
    // the controller's own AsyncValue so an unknown id (e.g. a stale deep
    // link) shows a not-found state instead of spinning forever.
    final analysesState = ref.watch(aiAnalysesControllerProvider);
    final analysis = ref.watch(aiAnalysisByIdProvider(analysisId));

    if (analysis == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.analysisResultTitle)),
        body: switch (analysesState) {
          AsyncError() => ErrorView(message: l10n.errorGeneric, onRetry: () => ref.read(aiAnalysesControllerProvider.notifier).refresh()),
          AsyncData() => EmptyState(icon: Icons.error_outline, message: l10n.analysisInvalidMessage),
          _ => const LoadingView(),
        },
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.analysisResultTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          children: [
            Text(analysis.documentTitle, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: AppSpacing.sm),
            AppCard(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: Text(analysis.summary, style: Theme.of(context).textTheme.bodyMedium)),
                  const SizedBox(width: AppSpacing.sm),
                  StatusBadge(label: analysis.overallRisk.label(l10n), tone: analysis.overallRisk.tone),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(l10n.analysisClausesTitle, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: AppSpacing.xs),
            for (final clause in analysis.clauses) ...[
              _ClauseTile(clause: clause),
              const SizedBox(height: AppSpacing.sm),
            ],
          ],
        ),
      ),
    );
  }
}

class _ClauseTile extends StatelessWidget {
  const _ClauseTile({required this.clause});

  final AnalysisClause clause;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AppCard(
      padding: EdgeInsets.zero,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Row(
            children: [
              Expanded(child: Text(clause.title, style: Theme.of(context).textTheme.titleSmall)),
              StatusBadge(label: clause.riskLevel.label(l10n), tone: clause.riskLevel.tone),
            ],
          ),
          childrenPadding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.md),
          children: [
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(clause.content, style: Theme.of(context).textTheme.bodyMedium),
            ),
            const SizedBox(height: AppSpacing.sm),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(color: context.statusColors.info.background, borderRadius: AppRadii.smRadius),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.lightbulb_outline, color: context.statusColors.info.foreground, size: 18),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      clause.recommendation,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: context.statusColors.info.foreground),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: TextButton.icon(
                onPressed: () => context.push(
                  RoutePaths.clientAiChat,
                  extra: {'initialMessage': l10n.analysisAskAboutClause(clause.title)},
                ),
                icon: const Icon(Icons.smart_toy_outlined, size: 18),
                label: Text(l10n.analysisAskAi),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
