import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' show DateFormat;

import 'package:aqd_ionbit/core/localization/generated/app_localizations.dart';
import 'package:aqd_ionbit/core/theme/app_spacing.dart';
import 'package:aqd_ionbit/core/widgets/app_card.dart';
import 'package:aqd_ionbit/core/widgets/empty_state.dart';
import 'package:aqd_ionbit/core/widgets/icon_badge.dart';
import 'package:aqd_ionbit/core/widgets/status_badge.dart';
import 'package:aqd_ionbit/features/billing/domain/entities/invoice.dart';
import 'package:aqd_ionbit/features/billing/presentation/providers/invoices_controller.dart';

class InvoicesScreen extends ConsumerWidget {
  const InvoicesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final invoices = ref.watch(invoicesControllerProvider);
    final locale = Localizations.localeOf(context).toLanguageTag();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.invoicesTitle)),
      body: SafeArea(
        child: invoices.isEmpty
            ? EmptyState(icon: Icons.receipt_long_outlined, title: l10n.invoicesEmptyTitle, message: l10n.invoicesEmptyMessage)
            : ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.xl),
                itemCount: invoices.length,
                separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.sm),
                itemBuilder: (context, index) {
                  final invoice = invoices[index];
                  return AppCard(
                    child: Row(
                      children: [
                        const IconBadge(icon: Icons.receipt_long_outlined, size: 44),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(invoice.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.titleSmall),
                              const SizedBox(height: AppSpacing.xxs),
                              Text(
                                DateFormat.yMMMd(locale).format(invoice.date),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(l10n.lawyerPriceSar(invoice.amount.toStringAsFixed(2)), style: Theme.of(context).textTheme.titleSmall),
                            const SizedBox(height: AppSpacing.xxs),
                            StatusBadge(
                              label: invoice.status == InvoiceStatus.paid ? l10n.invoiceStatusPaid : l10n.invoiceStatusPending,
                              tone: invoice.status == InvoiceStatus.paid ? AppStatusTone.success : AppStatusTone.warning,
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}
