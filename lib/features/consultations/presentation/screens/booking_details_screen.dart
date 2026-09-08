import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' show DateFormat;

import 'package:aqd_ionbit/core/localization/generated/app_localizations.dart';
import 'package:aqd_ionbit/core/routing/route_paths.dart';
import 'package:aqd_ionbit/core/theme/app_colors.dart';
import 'package:aqd_ionbit/core/theme/app_spacing.dart';
import 'package:aqd_ionbit/core/theme/app_status_colors.dart';
import 'package:aqd_ionbit/core/widgets/app_button.dart';
import 'package:aqd_ionbit/core/widgets/app_card.dart';
import 'package:aqd_ionbit/core/widgets/app_text_field.dart';
import 'package:aqd_ionbit/core/widgets/empty_state.dart';
import 'package:aqd_ionbit/features/billing/domain/entities/invoice.dart';
import 'package:aqd_ionbit/features/billing/presentation/providers/invoices_controller.dart';
import 'package:aqd_ionbit/features/billing/presentation/widgets/payment_panel.dart';
import 'package:aqd_ionbit/features/consultations/presentation/providers/booking_controller.dart';
import 'package:aqd_ionbit/features/lawyers/presentation/widgets/consultation_type_x.dart';

/// Step 3 — a free-text intake note, then payment, then confirm. Shows the
/// payment step and the generated booking's success state inline (mirrors
/// `ContractPreviewScreen`'s `_GeneratedSuccessView`) rather than as
/// separate routes, since there's nothing left to navigate back to mid-flow
/// once it's booked.
class BookingDetailsScreen extends ConsumerStatefulWidget {
  const BookingDetailsScreen({super.key, required this.lawyerId, this.routeBase = RoutePaths.clientBase});

  final String lawyerId;
  final String routeBase;

  @override
  ConsumerState<BookingDetailsScreen> createState() => _BookingDetailsScreenState();
}

class _BookingDetailsScreenState extends ConsumerState<BookingDetailsScreen> {
  final _notesController = TextEditingController();
  bool _showPayment = false;
  String? _confirmedConsultationId;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<bool> _confirmAndPay() async {
    final l10n = AppLocalizations.of(context)!;
    final booking = ref.read(bookingControllerProvider);
    final result = await ref.read(bookingControllerProvider.notifier).confirm();
    if (!mounted) return false;

    return result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.errorGeneric)));
        return false;
      },
      (consultation) {
        ref
            .read(invoicesControllerProvider.notifier)
            .add(
              Invoice(
                id: 'inv_${consultation.id}',
                title: booking.lawyerName != null ? '${booking.type?.label(l10n) ?? ''} — ${booking.lawyerName}' : consultation.id,
                amount: booking.price ?? 0,
                date: DateTime.now(),
                status: InvoiceStatus.paid,
              ),
            );
        setState(() => _confirmedConsultationId = consultation.id);
        return true;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (_confirmedConsultationId != null) {
      return Scaffold(body: _BookingSuccessView(consultationId: _confirmedConsultationId!, routeBase: widget.routeBase));
    }

    final booking = ref.watch(bookingControllerProvider);
    final locale = Localizations.localeOf(context).toLanguageTag();

    if (_showPayment) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.paymentTitle), leading: BackButton(onPressed: () => setState(() => _showPayment = false))),
        body: SafeArea(
          child: PaymentPanel(
            summaryLines: [
              PaymentSummaryLine(label: booking.lawyerName ?? '', value: booking.type?.label(l10n) ?? ''),
              if (booking.scheduledAt != null)
                PaymentSummaryLine(label: l10n.bookingSelectDateTimeTitle, value: DateFormat.yMMMd(locale).add_jm().format(booking.scheduledAt!)),
            ],
            totalAmount: booking.price ?? 0,
            onPay: _confirmAndPay,
          ),
        ),
      );
    }

    if (booking.type == null || booking.scheduledAt == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.bookingDetailsTitle)),
        body: EmptyState(icon: Icons.error_outline, message: l10n.errorGeneric),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.bookingDetailsTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          children: [
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _SummaryRow(icon: Icons.person_outline, label: booking.lawyerName ?? ''),
                  const Divider(height: AppSpacing.lg),
                  _SummaryRow(icon: booking.type!.icon, label: booking.type!.label(l10n)),
                  const Divider(height: AppSpacing.lg),
                  _SummaryRow(
                    icon: Icons.calendar_today_outlined,
                    label: DateFormat.yMMMd(locale).add_jm().format(booking.scheduledAt!),
                  ),
                  const Divider(height: AppSpacing.lg),
                  _SummaryRow(icon: Icons.payments_outlined, label: l10n.lawyerPriceSar((booking.price ?? 0).toStringAsFixed(0))),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(
              controller: _notesController,
              label: l10n.bookingNotesLabel,
              hintText: l10n.bookingNotesHint,
              maxLines: 4,
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: AppButton(
            label: l10n.bookingConfirm,
            onPressed: () {
              ref.read(bookingControllerProvider.notifier).setNotes(_notesController.text.trim());
              setState(() => _showPayment = true);
            },
          ),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.icon, required this.label});

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

class _BookingSuccessView extends StatelessWidget {
  const _BookingSuccessView({required this.consultationId, required this.routeBase});

  final String consultationId;
  final String routeBase;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 88,
                height: 88,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: context.statusColors.success.background, shape: BoxShape.circle),
                child: Icon(Icons.check, color: context.statusColors.success.foreground, size: 40),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(l10n.bookingSuccessTitle, textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: AppSpacing.xs),
              Text(
                l10n.bookingSuccessMessage,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.xl),
              AppButton(
                label: l10n.bookingViewDetails,
                onPressed: () => context.go(RoutePaths.consultationDetailsFor(routeBase, consultationId)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
