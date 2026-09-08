import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:aqd_ionbit/core/localization/generated/app_localizations.dart';
import 'package:aqd_ionbit/core/routing/route_paths.dart';
import 'package:aqd_ionbit/core/theme/app_colors.dart';
import 'package:aqd_ionbit/core/theme/app_spacing.dart';
import 'package:aqd_ionbit/core/widgets/app_button.dart';
import 'package:aqd_ionbit/core/widgets/app_card.dart';
import 'package:aqd_ionbit/core/widgets/error_view.dart';
import 'package:aqd_ionbit/core/widgets/loading_view.dart';
import 'package:aqd_ionbit/features/lawyers/domain/entities/consultation_type.dart';
import 'package:aqd_ionbit/features/lawyers/presentation/providers/lawyer_by_id_provider.dart';
import 'package:aqd_ionbit/features/lawyers/presentation/widgets/consultation_type_x.dart';
import 'package:aqd_ionbit/features/consultations/presentation/providers/booking_controller.dart';

/// Step 1 of the booking wizard — select a consultation type from the ones
/// this lawyer actually offers. Reads the lawyer profile itself (rather
/// than requiring the caller to have it in hand) so this route works from
/// a cold deep link too.
class BookingTypeScreen extends ConsumerStatefulWidget {
  const BookingTypeScreen({super.key, required this.lawyerId, this.routeBase = RoutePaths.clientBase});

  final String lawyerId;
  final String routeBase;

  @override
  ConsumerState<BookingTypeScreen> createState() => _BookingTypeScreenState();
}

class _BookingTypeScreenState extends ConsumerState<BookingTypeScreen> {
  ConsultationType? _selected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final lawyerState = ref.watch(lawyerByIdProvider(widget.lawyerId));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.bookingSelectTypeTitle)),
      body: switch (lawyerState) {
        AsyncData(value: final lawyer) => SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  children: [
                    for (final type in lawyer.consultationTypes) ...[
                      _TypeOption(
                        type: type,
                        price: lawyer.pricing[type],
                        selected: _selected == type,
                        onTap: () => setState(() => _selected = type),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                    ],
                  ],
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: AppButton(
                    label: l10n.commonContinue,
                    onPressed: _selected == null
                        ? null
                        : () {
                            ref.read(bookingControllerProvider.notifier).startBooking(lawyerId: lawyer.id, lawyerName: lawyer.fullName);
                            ref.read(bookingControllerProvider.notifier).selectType(_selected!, lawyer.pricing[_selected!] ?? 0);
                            context.push(RoutePaths.lawyerBookingDateTimeFor(widget.routeBase, widget.lawyerId));
                          },
                  ),
                ),
              ),
            ],
          ),
        ),
        AsyncError() => ErrorView(message: l10n.errorGeneric, onRetry: () => ref.invalidate(lawyerByIdProvider(widget.lawyerId))),
        _ => const LoadingView(),
      },
    );
  }
}

class _TypeOption extends StatelessWidget {
  const _TypeOption({required this.type, required this.price, required this.selected, required this.onTap});

  final ConsultationType type;
  final double? price;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final primary = Theme.of(context).colorScheme.primary;
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          Icon(type.icon, color: selected ? primary : AppColors.textSecondary),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: Text(type.label(l10n), style: Theme.of(context).textTheme.titleSmall)),
          if (price != null) Text(l10n.lawyerPriceSar(price!.toStringAsFixed(0)), style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(width: AppSpacing.sm),
          Icon(selected ? Icons.radio_button_checked : Icons.radio_button_unchecked, color: selected ? primary : AppColors.textDisabled),
        ],
      ),
    );
  }
}
