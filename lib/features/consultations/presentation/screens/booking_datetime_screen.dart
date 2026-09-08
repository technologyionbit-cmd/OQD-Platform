import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' show DateFormat;

import 'package:aqd_ionbit/core/localization/generated/app_localizations.dart';
import 'package:aqd_ionbit/core/routing/route_paths.dart';
import 'package:aqd_ionbit/core/theme/app_colors.dart';
import 'package:aqd_ionbit/core/theme/app_radii.dart';
import 'package:aqd_ionbit/core/theme/app_spacing.dart';
import 'package:aqd_ionbit/core/widgets/app_button.dart';
import 'package:aqd_ionbit/core/widgets/empty_state.dart';
import 'package:aqd_ionbit/core/widgets/error_view.dart';
import 'package:aqd_ionbit/core/widgets/loading_view.dart';
import 'package:aqd_ionbit/features/consultations/domain/entities/availability_slot.dart';
import 'package:aqd_ionbit/features/consultations/presentation/providers/availability_provider.dart';
import 'package:aqd_ionbit/features/consultations/presentation/providers/booking_controller.dart';

/// Step 2 of the booking wizard — pick a day, then an open hourly slot
/// from that lawyer's real (mock) availability calendar.
class BookingDateTimeScreen extends ConsumerStatefulWidget {
  const BookingDateTimeScreen({super.key, required this.lawyerId, this.routeBase = RoutePaths.clientBase});

  final String lawyerId;
  final String routeBase;

  @override
  ConsumerState<BookingDateTimeScreen> createState() => _BookingDateTimeScreenState();
}

class _BookingDateTimeScreenState extends ConsumerState<BookingDateTimeScreen> {
  DateTime? _selectedDay;
  AvailabilitySlot? _selectedSlot;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final availabilityState = ref.watch(availabilityProvider(widget.lawyerId));
    final locale = Localizations.localeOf(context).toLanguageTag();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.bookingSelectDateTimeTitle)),
      body: switch (availabilityState) {
        AsyncData(value: final slots) => Builder(
          builder: (context) {
            final days = <DateTime>{};
            for (final slot in slots) {
              days.add(DateTime(slot.start.year, slot.start.month, slot.start.day));
            }
            final sortedDays = days.toList()..sort();
            _selectedDay ??= sortedDays.firstOrNull;

            final daySlots = slots.where((slot) {
              final day = _selectedDay;
              return day != null && slot.start.year == day.year && slot.start.month == day.month && slot.start.day == day.day;
            }).toList();

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
                        return _DayChip(
                          day: day,
                          selected: selected,
                          locale: locale,
                          onTap: () => setState(() {
                            _selectedDay = day;
                            _selectedSlot = null;
                          }),
                        );
                      },
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: daySlots.isEmpty
                        ? EmptyState(icon: Icons.event_busy_outlined, message: l10n.bookingNoSlotsMessage)
                        : GridView.builder(
                            padding: const EdgeInsets.all(AppSpacing.xl),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              mainAxisSpacing: AppSpacing.sm,
                              crossAxisSpacing: AppSpacing.sm,
                              childAspectRatio: 2.2,
                            ),
                            itemCount: daySlots.length,
                            itemBuilder: (context, index) {
                              final slot = daySlots[index];
                              final selected = _selectedSlot?.id == slot.id;
                              return _SlotChip(
                                slot: slot,
                                selected: selected,
                                onTap: slot.isBooked ? null : () => setState(() => _selectedSlot = slot),
                              );
                            },
                          ),
                  ),
                  SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      child: AppButton(
                        label: l10n.commonContinue,
                        onPressed: _selectedSlot == null
                            ? null
                            : () {
                                ref.read(bookingControllerProvider.notifier).selectSlot(_selectedSlot!.start);
                                context.push(RoutePaths.lawyerBookingDetailsFor(widget.routeBase, widget.lawyerId));
                              },
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        AsyncError() => ErrorView(message: l10n.errorGeneric, onRetry: () => ref.invalidate(availabilityProvider(widget.lawyerId))),
        _ => const LoadingView(),
      },
    );
  }
}

class _DayChip extends StatelessWidget {
  const _DayChip({required this.day, required this.selected, required this.locale, required this.onTap});

  final DateTime day;
  final bool selected;
  final String locale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return InkWell(
      onTap: onTap,
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
              style: Theme.of(
                context,
              ).textTheme.labelMedium?.copyWith(color: selected ? AppColors.onPrimary : AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              DateFormat.d(locale).format(day),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: selected ? AppColors.onPrimary : AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SlotChip extends StatelessWidget {
  const _SlotChip({required this.slot, required this.selected, required this.onTap});

  final AvailabilitySlot slot;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final disabled = onTap == null;
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadii.smRadius,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? primary : (disabled ? AppColors.surfaceVariant : AppColors.surface),
          borderRadius: AppRadii.smRadius,
          border: Border.all(color: selected ? primary : AppColors.border),
        ),
        child: Text(
          DateFormat.jm().format(slot.start),
          style: TextStyle(
            color: selected ? AppColors.onPrimary : (disabled ? AppColors.textDisabled : AppColors.textPrimary),
            fontSize: 13,
            fontWeight: FontWeight.w600,
            decoration: disabled ? TextDecoration.lineThrough : null,
          ),
        ),
      ),
    );
  }
}
