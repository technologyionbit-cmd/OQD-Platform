import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:aqd_ionbit/core/localization/generated/app_localizations.dart';
import 'package:aqd_ionbit/core/routing/route_paths.dart';
import 'package:aqd_ionbit/core/theme/app_colors.dart';
import 'package:aqd_ionbit/core/theme/app_gradients.dart';
import 'package:aqd_ionbit/core/theme/app_radii.dart';
import 'package:aqd_ionbit/core/theme/app_spacing.dart';
import 'package:aqd_ionbit/core/theme/app_status_colors.dart';
import 'package:aqd_ionbit/core/widgets/app_button.dart';
import 'package:aqd_ionbit/core/widgets/app_card.dart';
import 'package:aqd_ionbit/core/widgets/empty_state.dart';
import 'package:aqd_ionbit/core/widgets/error_view.dart';
import 'package:aqd_ionbit/core/widgets/home_greeting_header.dart';
import 'package:aqd_ionbit/core/widgets/loading_view.dart';
import 'package:aqd_ionbit/core/widgets/section_header.dart';
import 'package:aqd_ionbit/features/auth/presentation/providers/auth_controller.dart';
import 'package:aqd_ionbit/features/consultations/domain/entities/consultation.dart';
import 'package:aqd_ionbit/features/consultations/domain/entities/consultation_status.dart';
import 'package:aqd_ionbit/features/consultations/presentation/providers/consultations_controller.dart';
import 'package:aqd_ionbit/features/consultations/presentation/widgets/consultation_card.dart';
import 'package:aqd_ionbit/features/lawyers/domain/entities/lawyer_profile.dart';
import 'package:aqd_ionbit/features/lawyers/presentation/widgets/consultation_type_x.dart';
import 'package:aqd_ionbit/features/notifications/presentation/providers/notifications_controller.dart';

class LawyerDashboardScreen extends ConsumerWidget {
  const LawyerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final user = ref.watch(authControllerProvider).value;
    final consultationsState = ref.watch(consultationsControllerProvider);
    final unreadCount = ref.watch(unreadNotificationsCountProvider);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => ref.read(consultationsControllerProvider.notifier).refresh(),
        child: ListView(
          children: [
            HomeGreetingHeader(
              greeting: user != null ? l10n.homeWelcome(user.fullName) : l10n.navLawyerDashboard,
              icon: Icons.gavel_outlined,
              trailing: Badge(
                isLabelVisible: unreadCount > 0,
                label: Text('$unreadCount'),
                child: IconButton(
                  icon: const Icon(Icons.notifications_outlined, color: AppColors.onPrimary),
                  onPressed: () => context.push(RoutePaths.lawyerNotifications),
                ),
              ),
            ),
            switch (consultationsState) {
              AsyncData(value: final consultations) => _DashboardBody(consultations: consultations.where((c) => c.lawyerId == kDemoLawyerId).toList()),
              AsyncError() => ErrorView(message: l10n.errorGeneric, onRetry: () => ref.read(consultationsControllerProvider.notifier).refresh()),
              _ => const Padding(padding: EdgeInsets.all(AppSpacing.xxl), child: LoadingView()),
            },
          ],
        ),
      ),
    );
  }
}

class _DashboardBody extends StatelessWidget {
  const _DashboardBody({required this.consultations});

  final List<Consultation> consultations;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final today = consultations
        .where(
          (c) =>
              c.status == ConsultationStatus.confirmed &&
              c.scheduledAt.year == now.year &&
              c.scheduledAt.month == now.month &&
              c.scheduledAt.day == now.day,
        )
        .toList()
      ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
    final pendingRequests = consultations.where((c) => c.status == ConsultationStatus.pendingApproval).toList();
    final upcoming = consultations.where((c) => c.status == ConsultationStatus.confirmed).toList()
      ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
    final completed = consultations.where((c) => c.status == ConsultationStatus.completed);
    final monthEarnings = completed
        .where((c) => c.scheduledAt.year == now.year && c.scheduledAt.month == now.month)
        .fold<double>(0, (sum, c) => sum + c.price);
    // "Active now" — the nearest upcoming consultation starting within the
    // next half hour (or already due), matching the reference's prominent
    // urgent-session banner. Outside that window, nothing is shown.
    final activeSession = upcoming
        .where((c) => c.scheduledAt.isAfter(now.subtract(const Duration(minutes: 15))) && c.scheduledAt.isBefore(now.add(const Duration(minutes: 30))))
        .firstOrNull;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (activeSession != null) ...[_ActiveSessionBanner(consultation: activeSession), const SizedBox(height: AppSpacing.lg)],
          Row(
            children: [
              Expanded(child: _StatCard(icon: Icons.today_outlined, label: l10n.dashboardTodayAppointments, value: '${today.length}')),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _StatCard(
                  icon: Icons.pending_actions_outlined,
                  label: l10n.dashboardPendingRequests,
                  value: '${pendingRequests.length}',
                  onTap: () => context.push(RoutePaths.lawyerRequests),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _StatCard(
                  icon: Icons.payments_outlined,
                  label: l10n.dashboardMonthEarnings,
                  value: l10n.lawyerPriceSar(monthEarnings.toStringAsFixed(0)),
                  onTap: () => context.push(RoutePaths.lawyerEarnings),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          SectionHeader(title: l10n.dashboardQuickActions),
          const SizedBox(height: AppSpacing.sm),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 4,
            mainAxisSpacing: AppSpacing.sm,
            crossAxisSpacing: AppSpacing.sm,
            childAspectRatio: 0.85,
            children: [
              _QuickAction(icon: Icons.calendar_today_outlined, label: l10n.navSchedule, onTap: () => context.push(RoutePaths.lawyerSchedule)),
              _QuickAction(icon: Icons.people_outline, label: l10n.navClients, onTap: () => context.push(RoutePaths.lawyerClients)),
              _QuickAction(icon: Icons.event_note_outlined, label: l10n.navConsultations, onTap: () => context.push(RoutePaths.lawyerConsultations)),
              _QuickAction(icon: Icons.inbox_outlined, label: l10n.lawyerRequestsTitle, onTap: () => context.push(RoutePaths.lawyerRequests)),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          SectionHeader(title: l10n.dashboardTodayAppointments),
          const SizedBox(height: AppSpacing.sm),
          if (today.isEmpty)
            EmptyState(icon: Icons.event_available_outlined, message: l10n.dashboardNoAppointmentsToday)
          else
            Column(
              children: [
                for (final c in today) ...[
                  ConsultationCard(consultation: c, showLawyerName: false, onTap: () => context.push(RoutePaths.lawyerConsultationDetails(c.id))),
                  const SizedBox(height: AppSpacing.sm),
                ],
              ],
            ),
          if (pendingRequests.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            SectionHeader(
              title: l10n.lawyerRequestsTitle,
              actionLabel: l10n.commonViewAll,
              onActionTap: () => context.push(RoutePaths.lawyerRequests),
            ),
            const SizedBox(height: AppSpacing.sm),
            Column(
              children: [
                for (final c in pendingRequests.take(3)) ...[
                  ConsultationCard(consultation: c, showLawyerName: false, onTap: () => context.push(RoutePaths.lawyerRequests)),
                  const SizedBox(height: AppSpacing.sm),
                ],
              ],
            ),
          ],
          if (upcoming.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            SectionHeader(
              title: l10n.consultationStatusUpcoming,
              actionLabel: l10n.commonViewAll,
              onActionTap: () => context.push(RoutePaths.lawyerConsultations),
            ),
            const SizedBox(height: AppSpacing.sm),
            Column(
              children: [
                for (final c in upcoming.take(3)) ...[
                  ConsultationCard(consultation: c, showLawyerName: false, onTap: () => context.push(RoutePaths.lawyerConsultationDetails(c.id))),
                  const SizedBox(height: AppSpacing.sm),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _ActiveSessionBanner extends StatelessWidget {
  const _ActiveSessionBanner({required this.consultation});

  final Consultation consultation;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final minutesUntil = consultation.scheduledAt.difference(now).inMinutes;
    final isReady = minutesUntil <= 0;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: const BoxDecoration(gradient: AppGradients.navyHeader, borderRadius: AppRadii.lgRadius),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: context.statusColors.error.foreground, shape: BoxShape.circle),
              ),
              const SizedBox(width: AppSpacing.xs),
              Flexible(
                child: Text(
                  l10n.dashboardActiveSessionBadge,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppColors.onPrimary, fontWeight: FontWeight.w700),
                ),
              ),
              const Spacer(),
              Icon(consultation.type.icon, color: AppColors.onPrimary.withValues(alpha: 0.7), size: 16),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  consultation.type.label(l10n),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppColors.onPrimary.withValues(alpha: 0.7)),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            consultation.clientName,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.onPrimary, fontWeight: FontWeight.w700),
          ),
          if (consultation.notes.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xxs),
            Text(
              consultation.notes,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.onPrimary.withValues(alpha: 0.7)),
            ),
          ],
          const SizedBox(height: AppSpacing.xxs),
          Text(
            isReady ? l10n.dashboardActiveSessionReady : l10n.dashboardActiveSessionStartingIn(minutesUntil),
            style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppColors.onPrimary.withValues(alpha: 0.85)),
          ),
          const SizedBox(height: AppSpacing.md),
          AppButton(
            label: l10n.dashboardStartSession,
            icon: consultation.type.icon,
            onPressed: () => context.push(RoutePaths.lawyerConsultationDetails(consultation.id)),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.icon, required this.label, required this.value, this.onTap});

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(height: AppSpacing.xs),
          Text(value, style: Theme.of(context).textTheme.titleMedium),
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.primary, size: 22),
          const SizedBox(height: AppSpacing.xxs),
          Flexible(
            child: Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ),
        ],
      ),
    );
  }
}
