import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' show DateFormat;

import 'package:aqd_ionbit/core/localization/generated/app_localizations.dart';
import 'package:aqd_ionbit/core/routing/route_paths.dart';
import 'package:aqd_ionbit/core/theme/app_colors.dart';
import 'package:aqd_ionbit/core/theme/app_gradients.dart';
import 'package:aqd_ionbit/core/theme/app_radii.dart';
import 'package:aqd_ionbit/core/theme/app_spacing.dart';
import 'package:aqd_ionbit/core/theme/app_status_colors.dart';
import 'package:aqd_ionbit/core/widgets/app_card.dart';
import 'package:aqd_ionbit/core/widgets/empty_state.dart';
import 'package:aqd_ionbit/core/widgets/error_view.dart';
import 'package:aqd_ionbit/core/widgets/loading_view.dart';
import 'package:aqd_ionbit/core/widgets/section_header.dart';
import 'package:aqd_ionbit/features/consultations/domain/entities/consultation.dart';
import 'package:aqd_ionbit/features/consultations/domain/entities/consultation_status.dart';
import 'package:aqd_ionbit/features/consultations/presentation/providers/consultations_controller.dart';
import 'package:aqd_ionbit/features/lawyers/domain/entities/lawyer_profile.dart';
import 'package:aqd_ionbit/features/lawyers/presentation/widgets/consultation_type_x.dart';

/// Earnings are derived entirely from the consultations feature's own
/// data (completed = earned, upcoming = pending) rather than a separate
/// mock ledger — ending a consultation is what actually moves money here,
/// so the numbers stay honest instead of being a second, disconnected
/// source of truth.
class LawyerEarningsScreen extends ConsumerWidget {
  const LawyerEarningsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final consultationsState = ref.watch(consultationsControllerProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.navEarnings)),
      body: switch (consultationsState) {
        AsyncData(value: final consultations) => _EarningsBody(
          consultations: consultations.where((c) => c.lawyerId == kDemoLawyerId).toList(),
        ),
        AsyncError() => ErrorView(message: l10n.errorGeneric, onRetry: () => ref.read(consultationsControllerProvider.notifier).refresh()),
        _ => const LoadingView(),
      },
    );
  }
}

class _EarningsBody extends StatelessWidget {
  const _EarningsBody({required this.consultations});

  final List<Consultation> consultations;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final completed = consultations.where((c) => c.status == ConsultationStatus.completed).toList()
      ..sort((a, b) => b.scheduledAt.compareTo(a.scheduledAt));
    final pending = consultations.where((c) => c.status == ConsultationStatus.confirmed);
    final totalEarned = completed.fold<double>(0, (sum, c) => sum + c.price);
    final totalPending = pending.fold<double>(0, (sum, c) => sum + c.price);

    final monthly = <String, double>{};
    for (final c in completed) {
      final key = DateFormat.yMMM(Localizations.localeOf(context).toLanguageTag()).format(c.scheduledAt);
      monthly[key] = (monthly[key] ?? 0) + c.price;
    }

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: const BoxDecoration(gradient: AppGradients.navyHeader, borderRadius: AppRadii.lgRadius),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.earningsBalance, style: TextStyle(color: AppColors.onPrimary.withValues(alpha: 0.7), fontSize: 13)),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                l10n.lawyerPriceSar(totalEarned.toStringAsFixed(0)),
                style: Theme.of(context).textTheme.displaySmall?.copyWith(color: AppColors.onPrimary),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                l10n.earningsPending(l10n.lawyerPriceSar(totalPending.toStringAsFixed(0))),
                style: TextStyle(color: AppColors.onPrimary.withValues(alpha: 0.7), fontSize: 13),
              ),
            ],
          ),
        ),
        if (monthly.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.lg),
          SectionHeader(title: l10n.earningsMonthlySummary),
          const SizedBox(height: AppSpacing.sm),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final entry in monthly.entries) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(entry.key, style: Theme.of(context).textTheme.bodyMedium),
                      Text(l10n.lawyerPriceSar(entry.value.toStringAsFixed(0)), style: Theme.of(context).textTheme.titleSmall),
                    ],
                  ),
                  if (entry.key != monthly.keys.last) const Divider(height: AppSpacing.lg),
                ],
              ],
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.lg),
        SectionHeader(title: l10n.earningsHistoryTitle),
        const SizedBox(height: AppSpacing.sm),
        if (completed.isEmpty)
          EmptyState(icon: Icons.receipt_long_outlined, message: l10n.earningsEmptyMessage)
        else
          Column(
            children: [
              for (final c in completed) ...[
                AppCard(
                  onTap: () => context.push(RoutePaths.lawyerConsultationDetails(c.id)),
                  child: Row(
                    children: [
                      Icon(c.type.icon, color: context.statusColors.success.foreground),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(c.clientName, style: Theme.of(context).textTheme.titleSmall),
                            Text(
                              DateFormat.yMMMd(Localizations.localeOf(context).toLanguageTag()).format(c.scheduledAt),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '+ ${l10n.lawyerPriceSar(c.price.toStringAsFixed(0))}',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(color: context.statusColors.success.foreground),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
              ],
            ],
          ),
      ],
    );
  }
}
