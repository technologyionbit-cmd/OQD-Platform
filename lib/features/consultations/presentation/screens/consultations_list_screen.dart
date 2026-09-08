import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:aqd_ionbit/core/localization/generated/app_localizations.dart';
import 'package:aqd_ionbit/core/routing/route_paths.dart';
import 'package:aqd_ionbit/core/theme/app_spacing.dart';
import 'package:aqd_ionbit/core/widgets/empty_state.dart';
import 'package:aqd_ionbit/core/widgets/error_view.dart';
import 'package:aqd_ionbit/core/widgets/loading_view.dart';
import 'package:aqd_ionbit/features/consultations/domain/entities/consultation.dart';
import 'package:aqd_ionbit/features/consultations/domain/entities/consultation_status.dart';
import 'package:aqd_ionbit/features/consultations/presentation/providers/consultations_controller.dart';
import 'package:aqd_ionbit/features/consultations/presentation/widgets/consultation_card.dart';
import 'package:aqd_ionbit/features/consultations/presentation/widgets/consultation_status_x.dart';

/// Shared by client, lawyer, and company — [showLawyerName] flips which
/// party's name each card shows, [includePendingTab] hides the "Pending"
/// tab on the lawyer side (which has its own dedicated Requests screen for
/// that), [routeBase] picks whose details route tapping a card pushes, and
/// [lawyerId] (set only from the lawyer-side route registration) scopes the
/// list to that lawyer's own bookings — the mock store holds more than one
/// lawyer's consultations, so without this a lawyer would see every other
/// lawyer's bookings too.
class ConsultationsListScreen extends ConsumerStatefulWidget {
  const ConsultationsListScreen({
    super.key,
    this.routeBase = RoutePaths.clientBase,
    this.showLawyerName = true,
    this.includePendingTab = true,
    this.lawyerId,
  });

  final String routeBase;
  final bool showLawyerName;
  final bool includePendingTab;
  final String? lawyerId;

  @override
  ConsumerState<ConsultationsListScreen> createState() => _ConsultationsListScreenState();
}

class _ConsultationsListScreenState extends ConsumerState<ConsultationsListScreen> {
  late List<ConsultationStatus> _tabStatuses;

  @override
  void initState() {
    super.initState();
    _tabStatuses = [
      if (widget.includePendingTab) ConsultationStatus.pendingApproval,
      ConsultationStatus.confirmed,
      ConsultationStatus.completed,
      ConsultationStatus.cancelled,
      ConsultationStatus.declined,
      // A consultation must never disappear from history just because its
      // outcome was missed/failed rather than cancelled/declined — these
      // two get their own tabs for the same reason cancelled/declined
      // already do (each is a distinct, meaningfully different outcome
      // worth telling apart at a glance, not just "didn't happen").
      ConsultationStatus.missed,
      ConsultationStatus.failed,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final consultationsState = ref.watch(consultationsControllerProvider);

    return DefaultTabController(
      length: _tabStatuses.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.navConsultations),
          bottom: TabBar(
            isScrollable: true,
            tabs: [for (final status in _tabStatuses) Tab(text: status.label(l10n))],
          ),
        ),
        body: switch (consultationsState) {
          AsyncData(value: final consultations) => TabBarView(
            children: [
              for (final status in _tabStatuses)
                _StatusTab(
                  consultations: consultations
                      .where((c) => c.status == status && (widget.lawyerId == null || c.lawyerId == widget.lawyerId))
                      .toList(),
                  routeBase: widget.routeBase,
                  showLawyerName: widget.showLawyerName,
                ),
            ],
          ),
          AsyncError() => ErrorView(message: l10n.errorGeneric, onRetry: () => ref.read(consultationsControllerProvider.notifier).refresh()),
          _ => const LoadingView(),
        },
      ),
    );
  }
}

class _StatusTab extends ConsumerWidget {
  const _StatusTab({required this.consultations, required this.routeBase, required this.showLawyerName});

  final List<Consultation> consultations;
  final String routeBase;
  final bool showLawyerName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    if (consultations.isEmpty) {
      return EmptyState(icon: Icons.event_note_outlined, title: l10n.consultationsEmptyTitle, message: l10n.consultationsEmptyMessage);
    }
    return RefreshIndicator(
      onRefresh: () => ref.read(consultationsControllerProvider.notifier).refresh(),
      child: ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.xl),
        itemCount: consultations.length,
        separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.sm),
        itemBuilder: (context, index) {
          final consultation = consultations[index];
          return ConsultationCard(
            consultation: consultation,
            showLawyerName: showLawyerName,
            onTap: () => context.push(RoutePaths.consultationDetailsFor(routeBase, consultation.id)),
          );
        },
      ),
    );
  }
}
