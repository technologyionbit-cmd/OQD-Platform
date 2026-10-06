import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' show DateFormat;

import 'package:aqd_ionbit/core/localization/generated/app_localizations.dart';
import 'package:aqd_ionbit/core/routing/route_paths.dart';
import 'package:aqd_ionbit/core/theme/app_colors.dart';
import 'package:aqd_ionbit/core/theme/app_radii.dart';
import 'package:aqd_ionbit/core/theme/app_status_colors.dart';
import 'package:aqd_ionbit/core/theme/app_spacing.dart';
import 'package:aqd_ionbit/core/widgets/app_bottom_sheet.dart';
import 'package:aqd_ionbit/core/widgets/app_button.dart';
import 'package:aqd_ionbit/core/widgets/confirmation_dialog.dart';
import 'package:aqd_ionbit/core/widgets/empty_state.dart';
import 'package:aqd_ionbit/core/widgets/error_view.dart';
import 'package:aqd_ionbit/core/widgets/loading_view.dart';
import 'package:aqd_ionbit/features/consultations/data/repositories/consultations_repository_impl.dart';
import 'package:aqd_ionbit/features/consultations/domain/entities/availability_slot.dart';
import 'package:aqd_ionbit/features/consultations/presentation/providers/availability_provider.dart';
import 'package:aqd_ionbit/features/lawyers/presentation/providers/my_lawyer_profile_provider.dart';

/// The demo lawyer's own availability calendar — day view, add/remove
/// slots. Slots already consumed by a booking ([AvailabilitySlot.isBooked])
/// link through to that consultation instead of being removable directly;
/// cancelling the booking (client side) or rejecting it (requests screen)
/// is what frees the slot.
class LawyerScheduleScreen extends ConsumerStatefulWidget {
  const LawyerScheduleScreen({super.key});

  @override
  ConsumerState<LawyerScheduleScreen> createState() => _LawyerScheduleScreenState();
}

class _LawyerScheduleScreenState extends ConsumerState<LawyerScheduleScreen> {
  DateTime? _selectedDay;

  Future<void> _removeSlot(AvailabilitySlot slot) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showConfirmationDialog(
      context,
      title: l10n.scheduleRemoveSlotTitle,
      message: l10n.scheduleRemoveSlotMessage,
      confirmLabel: l10n.commonDelete,
      cancelLabel: l10n.commonCancel,
      isDestructive: true,
    );
    if (!confirmed || !mounted) return;
    final repository = ref.read(consultationsRepositoryProvider);
    final result = await repository.removeAvailabilitySlot(slot.id);
    if (!mounted) return;
    result.fold(
      (failure) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.scheduleActionFailedMessage))),
      (_) => ref.invalidate(availabilityProvider),
    );
  }

  Future<void> _addSlot(DateTime day) async {
    final l10n = AppLocalizations.of(context)!;
    final hour = await showAppBottomSheet<int>(
      context,
      builder: (sheetContext) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.scheduleAddSlotTitle, style: Theme.of(sheetContext).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: [
                for (var h = 8; h <= 20; h++)
                  ActionChip(label: Text(DateFormat.j().format(DateTime(2024, 1, 1, h))), onPressed: () => Navigator.of(sheetContext).pop(h)),
              ],
            ),
          ],
        );
      },
    );
    if (hour == null || !mounted) return;
    final start = DateTime(day.year, day.month, day.day, hour);
    final lawyerId = ref.read(myLawyerProfileProvider).value?.id;
    if (lawyerId == null) return;
    final repository = ref.read(consultationsRepositoryProvider);
    final result = await repository.addAvailabilitySlot(lawyerId: lawyerId, start: start, end: start.add(const Duration(hours: 1)));
    if (!mounted) return;
    result.fold(
      (failure) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.scheduleActionFailedMessage))),
      (_) => ref.invalidate(availabilityProvider),
    );
  }

  void _openBookedSlot(AvailabilitySlot slot) {
    final l10n = AppLocalizations.of(context)!;
    final consultationId = slot.consultationId;
    if (consultationId != null) {
      context.push(RoutePaths.consultationDetailsFor(RoutePaths.lawyerBase, consultationId));
      return;
    }
    // Legacy/unlinked booking (no consultationId on the slot) — fall back
    // to the full list rather than a dead end, with a brief explanation.
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.scheduleSlotLinkedConsultationMissing)));
    context.push(RoutePaths.lawyerConsultations);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final availabilityState = ref.watch(myAvailabilityProvider);
    final locale = Localizations.localeOf(context).toLanguageTag();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.navSchedule)),
      body: switch (availabilityState) {
        AsyncData(value: final slots) => Builder(
          builder: (context) {
            final today = DateTime.now();
            final todayDate = DateTime(today.year, today.month, today.day);
            final days = <DateTime>{};
            for (final slot in slots) {
              days.add(DateTime(slot.start.year, slot.start.month, slot.start.day));
            }
            // Always offer today plus the next two weeks as selectable days,
            // even before any slot exists on them — otherwise a lawyer with
            // zero availability slots (new account, or all slots removed)
            // would have no day chip to tap and the "Add" button below would
            // stay permanently disabled with no way to create a first slot.
            for (var i = 0; i < 14; i++) {
              days.add(todayDate.add(Duration(days: i)));
            }
            final sortedDays = days.toList()..sort();
            _selectedDay ??= todayDate;
            final daySlots = slots.where((slot) {
              final day = _selectedDay;
              return day != null && slot.start.year == day.year && slot.start.month == day.month && slot.start.day == day.day;
            }).toList()..sort((a, b) => a.start.compareTo(b.start));

            return SafeArea(
              child: Column(
                children: [
                  SizedBox(
                    height: 96,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.xs),
                      itemCount: sortedDays.length,
                      separatorBuilder: (context, index) => const SizedBox(width: AppSpacing.xs),
                      itemBuilder: (context, index) {
                        final day = sortedDays[index];
                        final selected = _selectedDay == day;
                        final primary = Theme.of(context).colorScheme.primary;
                        return InkWell(
                          onTap: () => setState(() => _selectedDay = day),
                          borderRadius: AppRadii.mdRadius,
                          child: Container(
                            width: 56,
                            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                            decoration: BoxDecoration(
                              color: selected ? primary : AppColors.surfaceVariant,
                              borderRadius: AppRadii.mdRadius,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  DateFormat.E(locale).format(day),
                                  style: TextStyle(color: selected ? AppColors.onPrimary : AppColors.textSecondary, fontSize: 12),
                                ),
                                const SizedBox(height: AppSpacing.xxs),
                                Text(
                                  DateFormat.d(locale).format(day),
                                  style: TextStyle(
                                    color: selected ? AppColors.onPrimary : AppColors.textPrimary,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: daySlots.isEmpty
                        ? EmptyState(icon: Icons.event_available_outlined, message: l10n.scheduleEmptyDayMessage)
                        : ListView.separated(
                            padding: const EdgeInsets.all(AppSpacing.xl),
                            itemCount: daySlots.length,
                            separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.xs),
                            itemBuilder: (context, index) {
                              final slot = daySlots[index];
                              return ListTile(
                                tileColor: slot.isBooked ? context.statusColors.info.background : context.statusColors.success.background,
                                shape: const RoundedRectangleBorder(borderRadius: AppRadii.mdRadius),
                                leading: Icon(
                                  slot.isBooked ? Icons.event_busy_outlined : Icons.event_available_outlined,
                                  color: slot.isBooked ? context.statusColors.info.foreground : context.statusColors.success.foreground,
                                ),
                                title: Text(DateFormat.jm().format(slot.start)),
                                subtitle: Text(slot.isBooked ? l10n.scheduleSlotBooked : l10n.scheduleSlotOpen),
                                trailing: slot.isBooked
                                    ? const Icon(Icons.chevron_right)
                                    : IconButton(icon: const Icon(Icons.close), onPressed: () => _removeSlot(slot)),
                                onTap: slot.isBooked ? () => _openBookedSlot(slot) : null,
                              );
                            },
                          ),
                  ),
                  SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      child: AppButton(
                        label: l10n.scheduleAddSlotTitle,
                        icon: Icons.add,
                        variant: AppButtonVariant.outlined,
                        onPressed: _selectedDay == null ? null : () => _addSlot(_selectedDay!),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        AsyncError() => ErrorView(message: l10n.errorGeneric, onRetry: () => ref.invalidate(availabilityProvider)),
        _ => const LoadingView(),
      },
    );
  }
}
