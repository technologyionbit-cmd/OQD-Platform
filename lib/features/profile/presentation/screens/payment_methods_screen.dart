import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aqd_ionbit/core/localization/generated/app_localizations.dart';
import 'package:aqd_ionbit/core/theme/app_colors.dart';
import 'package:aqd_ionbit/core/theme/app_spacing.dart';
import 'package:aqd_ionbit/core/utils/validators.dart';
import 'package:aqd_ionbit/core/widgets/app_bottom_sheet.dart';
import 'package:aqd_ionbit/core/widgets/app_button.dart';
import 'package:aqd_ionbit/core/widgets/app_card.dart';
import 'package:aqd_ionbit/core/widgets/app_text_field.dart';
import 'package:aqd_ionbit/core/widgets/confirmation_dialog.dart';
import 'package:aqd_ionbit/core/widgets/empty_state.dart';
import 'package:aqd_ionbit/core/widgets/icon_badge.dart';
import 'package:aqd_ionbit/core/widgets/status_badge.dart';
import 'package:aqd_ionbit/features/billing/domain/entities/payment_method.dart';
import 'package:aqd_ionbit/features/billing/presentation/providers/payment_methods_controller.dart';

class PaymentMethodsScreen extends ConsumerWidget {
  const PaymentMethodsScreen({super.key});

  Future<void> _addCard(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final last4Controller = TextEditingController();
    final holderController = TextEditingController();

    final confirmed = await showAppBottomSheet<bool>(
      context,
      builder: (sheetContext) {
        String? last4Error;
        String? holderError;
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            void save() {
              final validLast4 = Validators.isValidLast4(last4Controller.text);
              final validHolder = Validators.isRequired(holderController.text);
              if (validLast4 && validHolder) {
                Navigator.of(sheetContext).pop(true);
                return;
              }
              setSheetState(() {
                last4Error = validLast4 ? null : l10n.paymentMethodsLast4Invalid;
                holderError = validHolder ? null : l10n.paymentMethodsHolderRequired;
              });
            }

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(l10n.paymentMethodsAddCard, style: Theme.of(sheetContext).textTheme.titleMedium),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  controller: last4Controller,
                  label: l10n.paymentMethodsLast4Label,
                  keyboardType: TextInputType.number,
                  hintText: '4242',
                  errorText: last4Error,
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(controller: holderController, label: l10n.paymentMethodsHolderLabel, errorText: holderError),
                const SizedBox(height: AppSpacing.lg),
                AppButton(label: l10n.commonSave, onPressed: save),
              ],
            );
          },
        );
      },
    );
    if (confirmed != true || !context.mounted) return;

    await ref
        .read(paymentMethodsControllerProvider.notifier)
        .addCard(brand: 'visa', last4: last4Controller.text.trim(), holderName: holderController.text.trim());
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.paymentMethodsAddedMessage)));
  }

  Future<void> _remove(BuildContext context, WidgetRef ref, String id) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showConfirmationDialog(
      context,
      title: l10n.paymentMethodsRemoveConfirmTitle,
      message: l10n.paymentMethodsRemoveConfirmMessage,
      confirmLabel: l10n.commonDelete,
      cancelLabel: l10n.commonCancel,
      isDestructive: true,
    );
    if (confirmed) ref.read(paymentMethodsControllerProvider.notifier).remove(id);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final cards = ref.watch(paymentMethodsControllerProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.paymentMethodsTitle)),
      floatingActionButton: FloatingActionButton(onPressed: () => _addCard(context, ref), child: const Icon(Icons.add)),
      body: SafeArea(
        child: cards.isEmpty
            ? EmptyState(icon: Icons.credit_card_outlined, title: l10n.paymentMethodsEmptyTitle, message: l10n.paymentMethodsEmptyMessage)
            : ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.xl),
                itemCount: cards.length,
                separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.sm),
                itemBuilder: (context, index) => _CardRow(
                  card: cards[index],
                  onSetDefault: () => ref.read(paymentMethodsControllerProvider.notifier).setDefault(cards[index].id),
                  onRemove: () => _remove(context, ref, cards[index].id),
                ),
              ),
      ),
    );
  }
}

class _CardRow extends StatelessWidget {
  const _CardRow({required this.card, required this.onSetDefault, required this.onRemove});

  final PaymentMethod card;
  final VoidCallback onSetDefault;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AppCard(
      child: Row(
        children: [
          const IconBadge(icon: Icons.credit_card, size: 44),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('•••• ${card.last4}', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: AppSpacing.xxs),
                Text(card.holderName, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          if (card.isDefault)
            StatusBadge(label: l10n.paymentMethodsDefaultBadge, tone: AppStatusTone.success)
          else
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: AppColors.textSecondary),
              onSelected: (value) {
                if (value == 'default') onSetDefault();
                if (value == 'remove') onRemove();
              },
              itemBuilder: (context) => [
                PopupMenuItem(value: 'default', child: Text(l10n.paymentMethodsSetDefault)),
                PopupMenuItem(value: 'remove', child: Text(l10n.commonDelete)),
              ],
            ),
        ],
      ),
    );
  }
}
