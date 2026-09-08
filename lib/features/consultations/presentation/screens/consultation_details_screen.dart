import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' show DateFormat;

import 'package:aqd_ionbit/core/localization/generated/app_localizations.dart';
import 'package:aqd_ionbit/core/routing/route_paths.dart';
import 'package:aqd_ionbit/core/theme/app_colors.dart';
import 'package:aqd_ionbit/core/theme/app_spacing.dart';
import 'package:aqd_ionbit/core/widgets/app_bottom_sheet.dart';
import 'package:aqd_ionbit/core/widgets/app_button.dart';
import 'package:aqd_ionbit/core/widgets/app_card.dart';
import 'package:aqd_ionbit/core/widgets/confirmation_dialog.dart';
import 'package:aqd_ionbit/core/widgets/empty_state.dart';
import 'package:aqd_ionbit/core/widgets/error_view.dart';
import 'package:aqd_ionbit/core/widgets/loading_view.dart';
import 'package:aqd_ionbit/core/widgets/status_badge.dart';
import 'package:aqd_ionbit/core/errors/result.dart';
import 'package:aqd_ionbit/features/auth/domain/entities/user_role.dart';
import 'package:aqd_ionbit/features/auth/presentation/providers/auth_controller.dart';
import 'package:aqd_ionbit/features/consultations/domain/entities/consultation.dart';
import 'package:aqd_ionbit/features/consultations/domain/entities/consultation_status.dart';
import 'package:aqd_ionbit/features/consultations/presentation/providers/availability_provider.dart';
import 'package:aqd_ionbit/features/consultations/presentation/providers/consultation_by_id_provider.dart';
import 'package:aqd_ionbit/features/consultations/presentation/providers/consultations_controller.dart';
import 'package:aqd_ionbit/features/consultations/presentation/widgets/consultation_status_x.dart';
import 'package:aqd_ionbit/features/lawyers/domain/entities/consultation_type.dart';
import 'package:aqd_ionbit/features/lawyers/presentation/widgets/consultation_type_x.dart';

class ConsultationDetailsScreen extends ConsumerWidget {
  const ConsultationDetailsScreen({super.key, required this.consultationId, this.routeBase = RoutePaths.clientBase});

  final String consultationId;
  final String routeBase;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    // Same pattern as VoiceCallScreen/VideoCallScreen/ChatRoomScreen: the
    // controller is the source of truth for the whole list, watched once so
    // a cold deep link still resolves and an unknown id doesn't spin forever.
    final consultationsState = ref.watch(consultationsControllerProvider);
    final consultation = ref.watch(consultationByIdProvider(consultationId));

    if (consultation == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.consultationDetailsTitle)),
        body: switch (consultationsState) {
          AsyncError() => ErrorView(message: l10n.errorGeneric, onRetry: () => ref.read(consultationsControllerProvider.notifier).refresh()),
          AsyncData() => EmptyState(icon: Icons.error_outline, message: l10n.chatInvalidConsultationMessage),
          _ => const LoadingView(),
        },
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.consultationDetailsTitle)),
      body: _ConsultationDetailsBody(consultation: consultation, routeBase: routeBase),
    );
  }
}

class _ConsultationDetailsBody extends ConsumerStatefulWidget {
  const _ConsultationDetailsBody({required this.consultation, required this.routeBase});

  final Consultation consultation;
  final String routeBase;

  @override
  ConsumerState<_ConsultationDetailsBody> createState() => _ConsultationDetailsBodyState();
}

class _ConsultationDetailsBodyState extends ConsumerState<_ConsultationDetailsBody> {
  bool _isActionRunning = false;

  Future<void> _respondToRequest(AppLocalizations l10n, {required bool accept}) async {
    if (!accept) {
      final confirmed = await showConfirmationDialog(
        context,
        title: l10n.lawyerRequestRejectConfirmTitle,
        message: l10n.lawyerRequestRejectConfirmMessage,
        confirmLabel: l10n.lawyerRequestReject,
        cancelLabel: l10n.commonCancel,
        isDestructive: true,
      );
      if (!confirmed || !mounted) return;
    }
    final notifier = ref.read(consultationsControllerProvider.notifier);
    await _run(() => accept ? notifier.acceptRequest(widget.consultation.id) : notifier.rejectRequest(widget.consultation.id));
  }

  Future<void> _cancel(AppLocalizations l10n) async {
    final confirmed = await showConfirmationDialog(
      context,
      title: l10n.consultationCancelConfirmTitle,
      message: l10n.consultationCancelConfirmMessage,
      confirmLabel: l10n.commonConfirm,
      cancelLabel: l10n.commonCancel,
      isDestructive: true,
    );
    if (!confirmed || !mounted) return;
    await _run(() => ref.read(consultationsControllerProvider.notifier).cancel(widget.consultation.id));
  }

  Future<void> _complete(AppLocalizations l10n) async {
    await _run(() => ref.read(consultationsControllerProvider.notifier).complete(widget.consultation.id));
  }

  Future<void> _reschedule() async {
    final selected = await showAppBottomSheet<DateTime>(
      context,
      builder: (sheetContext) => _RescheduleSheet(lawyerId: widget.consultation.lawyerId),
    );
    if (selected == null || !mounted) return;
    await _run(
      () => ref.read(consultationsControllerProvider.notifier).reschedule(id: widget.consultation.id, newDateTime: selected),
    );
  }

  Future<void> _run(Future<dynamic> Function() action) async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _isActionRunning = true);
    final result = await action();
    if (!mounted) return;
    setState(() => _isActionRunning = false);
    if (result is Result && result.isFailure) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.errorGeneric)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final role = ref.watch(authControllerProvider).value?.role;
    final isLawyerView = role == UserRole.lawyer;
    final consultation = widget.consultation;
    final canEnterRoom = consultation.status == ConsultationStatus.confirmed;
    final canMessage = consultation.status == ConsultationStatus.confirmed || consultation.status == ConsultationStatus.completed;

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(isLawyerView ? consultation.clientName : consultation.lawyerName, style: Theme.of(context).textTheme.headlineSmall),
                  ),
                  StatusBadge(label: consultation.status.label(l10n), tone: consultation.status.tone),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _DetailRow(icon: consultation.type.icon, label: consultation.type.label(l10n)),
                    const Divider(height: AppSpacing.lg),
                    _DetailRow(
                      icon: Icons.calendar_today_outlined,
                      label: DateFormat.yMMMd(locale).add_jm().format(consultation.scheduledAt),
                    ),
                    const Divider(height: AppSpacing.lg),
                    _DetailRow(icon: Icons.payments_outlined, label: l10n.lawyerPriceSar(consultation.price.toStringAsFixed(0))),
                  ],
                ),
              ),
              if (consultation.notes.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.lg),
                Text(l10n.bookingNotesLabel, style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: AppSpacing.xs),
                AppCard(child: Text(consultation.notes, style: Theme.of(context).textTheme.bodyMedium)),
              ],
            ],
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.xl, 0, AppSpacing.xl, AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // A confirmed (not-yet-live) consultation of any type goes
                // through the shared waiting/lobby screen first; a completed
                // written consultation keeps going straight to its
                // read-only transcript (no live session left to wait for).
                if (canEnterRoom) ...[
                  AppButton(
                    label: l10n.consultationRoomEnterAction,
                    icon: consultation.type.icon,
                    onPressed: () => context.push(RoutePaths.consultationRoomFor(widget.routeBase, consultation.id)),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                ] else if (consultation.type == ConsultationType.written && canMessage) ...[
                  AppButton(
                    label: l10n.chatOpenAction,
                    icon: Icons.chat_bubble_outline,
                    onPressed: () => context.push(RoutePaths.chatRoomFor(widget.routeBase, consultation.id)),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                ],
                if (isLawyerView && consultation.status == ConsultationStatus.pendingApproval) ...[
                  Row(
                    children: [
                      Expanded(
                        child: AppButton(
                          label: l10n.lawyerRequestReject,
                          variant: AppButtonVariant.outlined,
                          onPressed: _isActionRunning ? null : () => _respondToRequest(l10n, accept: false),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: AppButton(
                          label: l10n.lawyerRequestAccept,
                          variant: AppButtonVariant.success,
                          isLoading: _isActionRunning,
                          onPressed: _isActionRunning ? null : () => _respondToRequest(l10n, accept: true),
                        ),
                      ),
                    ],
                  ),
                ],
                if (isLawyerView && consultation.status == ConsultationStatus.confirmed) ...[
                  AppButton(
                    label: l10n.consultationEnd,
                    variant: AppButtonVariant.success,
                    isLoading: _isActionRunning,
                    onPressed: _isActionRunning ? null : () => _complete(l10n),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  AppButton(
                    label: l10n.consultationCancel,
                    variant: AppButtonVariant.destructive,
                    isLoading: _isActionRunning,
                    onPressed: _isActionRunning ? null : () => _cancel(l10n),
                  ),
                ],
                if (!isLawyerView && consultation.status == ConsultationStatus.confirmed) ...[
                  AppButton(
                    label: l10n.consultationReschedule,
                    variant: AppButtonVariant.outlined,
                    onPressed: _isActionRunning ? null : _reschedule,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                ],
                if (!isLawyerView &&
                    (consultation.status == ConsultationStatus.confirmed || consultation.status == ConsultationStatus.pendingApproval))
                  AppButton(
                    label: l10n.consultationCancel,
                    variant: AppButtonVariant.destructive,
                    isLoading: _isActionRunning,
                    onPressed: _isActionRunning ? null : () => _cancel(l10n),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: AppSpacing.sm),
        Expanded(child: Text(label, style: Theme.of(context).textTheme.bodyMedium)),
      ],
    );
  }
}

class _RescheduleSheet extends ConsumerWidget {
  const _RescheduleSheet({required this.lawyerId});

  final String lawyerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final availabilityState = ref.watch(availabilityProvider(lawyerId));
    final locale = Localizations.localeOf(context).toLanguageTag();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.consultationReschedule, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          height: 320,
          child: switch (availabilityState) {
            AsyncData(value: final slots) => Builder(
              builder: (context) {
                final open = slots.where((s) => !s.isBooked).take(20).toList();
                if (open.isEmpty) {
                  return EmptyState(icon: Icons.event_busy_outlined, message: l10n.bookingNoSlotsMessage);
                }
                return ListView.separated(
                  itemCount: open.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final slot = open[index];
                    return ListTile(
                      leading: const Icon(Icons.schedule_outlined),
                      title: Text(DateFormat.yMMMd(locale).add_jm().format(slot.start)),
                      onTap: () => Navigator.of(context).pop(slot.start),
                    );
                  },
                );
              },
            ),
            AsyncError() => EmptyState(icon: Icons.error_outline, message: l10n.errorGeneric),
            _ => const LoadingView(),
          },
        ),
      ],
    );
  }
}
