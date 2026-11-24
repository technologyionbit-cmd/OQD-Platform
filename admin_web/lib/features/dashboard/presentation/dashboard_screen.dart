import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:aqd_admin/core/localization/generated/app_localizations.dart';
import 'package:aqd_admin/core/routing/route_paths.dart';
import 'package:aqd_admin/core/theme/app_colors.dart';
import 'package:aqd_admin/core/utils/formatters.dart';
import 'package:aqd_admin/core/widgets/page_header.dart';
import 'package:aqd_admin/core/widgets/state_views.dart';
import 'package:aqd_admin/features/dashboard/domain/dashboard_summary.dart';
import 'package:aqd_admin/features/dashboard/presentation/providers/dashboard_providers.dart';
import 'package:aqd_admin/features/users/presentation/widgets/user_labels.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final summary = ref.watch(dashboardSummaryProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PageHeader(
          title: l10n.navDashboard,
          subtitle: l10n.dashSubtitle,
          actions: [IconButton(tooltip: l10n.retry, onPressed: () => ref.invalidate(dashboardSummaryProvider), icon: const Icon(Icons.refresh))],
        ),
        Expanded(
          child: summary.when(
            loading: () => const LoadingView(),
            error: (error, _) => ErrorView(error: error, onRetry: () => ref.invalidate(dashboardSummaryProvider)),
            data: (data) => SingleChildScrollView(child: _Body(data: data)),
          ),
        ),
      ],
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.data});

  final DashboardSummary data;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _Kpi(icon: Icons.people_outline, label: l10n.kpiUsers, value: data.totalUsers, hint: '+${data.newUsers7d} ${l10n.kpiNewUsers}', onTap: () => context.go(RoutePaths.users)),
            _Kpi(
              icon: Icons.verified_user_outlined,
              label: l10n.kpiPendingLawyers,
              value: data.pendingLawyers,
              tone: data.pendingLawyers > 0 ? AppColors.warning : null,
              onTap: () => context.go(RoutePaths.lawyerVerifications),
            ),
            _Kpi(icon: Icons.video_camera_front_outlined, label: l10n.kpiUpcoming, value: data.upcomingConsultations, onTap: () => context.go(RoutePaths.consultations)),
            _Kpi(icon: Icons.description_outlined, label: l10n.kpiContracts, value: data.totalContracts, onTap: () => context.go(RoutePaths.contracts)),
            _Kpi(
              icon: Icons.business_outlined,
              label: l10n.kpiOrganizations,
              value: data.organizations,
              hint: data.pendingOrganizations > 0 ? l10n.kpiOrgsPending(data.pendingOrganizations) : null,
              onTap: () => context.go(RoutePaths.companies),
            ),
            _Kpi(icon: Icons.block, label: l10n.kpiSuspended, value: data.suspendedUsers, tone: data.suspendedUsers > 0 ? AppColors.error : null),
          ],
        ),
        const SizedBox(height: 16),
        _TwoUp(
          left: _Panel(title: l10n.chartSignups, child: BarSeries(values: data.signups, color: AppColors.primary)),
          right: _Panel(title: l10n.chartConsultations, child: BarSeries(values: data.consultationsSeries, color: AppColors.secondary)),
        ),
        const SizedBox(height: 16),
        _TwoUp(
          left: _Panel(
            title: l10n.secUsersByRole,
            child: _Breakdown(rows: {for (final e in data.usersByRole.entries) roleLabel(l10n, e.key): e.value}),
          ),
          right: _Panel(
            title: l10n.secConsultationsByStatus,
            child: _Breakdown(rows: {for (final e in data.consultationsByStatus.entries) _consultationLabel(l10n, e.key): e.value}),
          ),
        ),
        const SizedBox(height: 16),
        _TwoUp(
          left: _Panel(
            title: l10n.secContractsByStatus,
            child: _Breakdown(rows: {for (final e in data.contractsByStatus.entries) _contractLabel(l10n, e.key): e.value}),
          ),
          right: _Panel(title: l10n.secRecentActivity, child: _Activity(entries: data.recentActivity)),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

String _consultationLabel(AppLocalizations l10n, String s) => switch (s) {
      'pendingApproval' => l10n.csPendingApproval,
      'confirmed' => l10n.csConfirmed,
      'completed' => l10n.csCompleted,
      'cancelled' => l10n.csCancelled,
      'declined' => l10n.csDeclined,
      'missed' => l10n.csMissed,
      'failed' => l10n.csFailed,
      _ => s,
    };

String _contractLabel(AppLocalizations l10n, String s) => switch (s) {
      'draft' => l10n.ctDraft,
      'pendingSignature' => l10n.ctPendingSignature,
      'signed' => l10n.ctSigned,
      'completed' => l10n.ctCompleted,
      _ => s,
    };

class _Kpi extends StatelessWidget {
  const _Kpi({required this.icon, required this.label, required this.value, this.hint, this.tone, this.onTap});

  final IconData icon;
  final String label;
  final int value;
  final String? hint;
  final Color? tone;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = tone ?? AppColors.primary;
    return SizedBox(
      width: 240,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                CircleAvatar(backgroundColor: color.withValues(alpha: 0.12), foregroundColor: color, child: Icon(icon)),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('$value', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
                      Text(label, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                      if (hint != null) Text(hint!, style: theme.textTheme.bodySmall?.copyWith(color: color)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Two panels side by side on a wide screen, stacked on a narrow one.
class _TwoUp extends StatelessWidget {
  const _TwoUp({required this.left, required this.right});

  final Widget left;
  final Widget right;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 760) {
          return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [left, const SizedBox(height: 16), right]);
        }
        return IntrinsicHeight(
          child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [Expanded(child: left), const SizedBox(width: 16), Expanded(child: right)]),
        );
      },
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [Text(title, style: Theme.of(context).textTheme.titleMedium), const SizedBox(height: 16), child],
        ),
      ),
    );
  }
}

class _Breakdown extends StatelessWidget {
  const _Breakdown({required this.rows});

  final Map<String, int> rows;

  @override
  Widget build(BuildContext context) {
    final total = rows.values.fold<int>(0, (a, b) => a + b);
    return Column(
      children: [
        for (final entry in rows.entries)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              children: [
                SizedBox(width: 130, child: Text(entry.key)),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(value: total == 0 ? 0 : entry.value / total, minHeight: 8, backgroundColor: AppColors.surfaceVariant),
                  ),
                ),
                SizedBox(width: 44, child: Text('${entry.value}', textAlign: TextAlign.end, style: const TextStyle(fontWeight: FontWeight.w600))),
              ],
            ),
          ),
      ],
    );
  }
}

class _Activity extends StatelessWidget {
  const _Activity({required this.entries});

  final List<ActivityEntry> entries;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    if (entries.isEmpty) return Text(l10n.noActivity, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant));
    return Column(
      children: [
        for (final e in entries)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              children: [
                Expanded(
                  child: Text.rich(
                    TextSpan(children: [
                      TextSpan(text: e.actorName ?? '-', style: const TextStyle(fontWeight: FontWeight.w600)),
                      TextSpan(text: '  ${e.action}'),
                    ]),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(formatDateTime(context, e.createdAt), style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
      ],
    );
  }
}

/// A small bar chart of a daily series, oldest day first.
class BarSeries extends StatelessWidget {
  const BarSeries({required this.values, required this.color, super.key});

  final List<int> values;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final max = values.fold<int>(0, (a, b) => a > b ? a : b);
    return SizedBox(
      height: 140,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (final v in values)
            Expanded(
              child: Tooltip(
                message: '$v',
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 1),
                  child: FractionallySizedBox(
                    heightFactor: max == 0 ? 0.02 : (v / max).clamp(0.02, 1.0),
                    child: DecoratedBox(
                      decoration: BoxDecoration(color: v == 0 ? color.withValues(alpha: 0.2) : color, borderRadius: const BorderRadius.vertical(top: Radius.circular(2))),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
