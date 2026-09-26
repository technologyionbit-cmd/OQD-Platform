import 'package:flutter/material.dart';

import 'package:aqd_ionbit/core/localization/generated/app_localizations.dart';
import 'package:aqd_ionbit/core/theme/app_colors.dart';
import 'package:aqd_ionbit/core/theme/app_gradients.dart';
import 'package:aqd_ionbit/core/theme/app_radii.dart';
import 'package:aqd_ionbit/core/theme/app_spacing.dart';
import 'package:aqd_ionbit/core/utils/validators.dart';
import 'package:aqd_ionbit/core/widgets/app_button.dart';
import 'package:aqd_ionbit/core/widgets/app_card.dart';
import 'package:aqd_ionbit/core/widgets/app_text_field.dart';

enum _PaymentMethod { card, digitalWallet }

/// One line in the invoice summary card — e.g. ("استشارة مع أ. سامر", "35 د.أ").
class PaymentSummaryLine {
  const PaymentSummaryLine({required this.label, required this.value});
  final String label;
  final String value;
}

/// The reference's payment screen (invoice summary, card-vs-Apple/Google-Pay
/// tabs, card form, pay button) as a self-contained mock panel — reused by
/// both the consultation-booking flow and the subscription checkout flow so
/// neither hand-rolls its own card form. No real payment processor: [onPay]
/// just simulates a short delay and reports success.
class PaymentPanel extends StatefulWidget {
  const PaymentPanel({
    super.key,
    required this.summaryLines,
    required this.totalAmount,
    required this.onPay,
  });

  final List<PaymentSummaryLine> summaryLines;
  final double totalAmount;
  final Future<bool> Function() onPay;

  @override
  State<PaymentPanel> createState() => _PaymentPanelState();
}

class _PaymentPanelState extends State<PaymentPanel> {
  _PaymentMethod _method = _PaymentMethod.card;
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  bool _isPaying = false;
  String? _cardNumberError;
  String? _expiryError;
  String? _cvvError;
  String? _firstNameError;
  String? _lastNameError;

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  bool _validateCardForm() {
    final l10n = AppLocalizations.of(context)!;
    final cardNumberError = Validators.isValidCardNumber(_cardNumberController.text) ? null : l10n.paymentCardNumberInvalid;
    final expiryError = Validators.isValidExpiry(_expiryController.text) ? null : l10n.paymentExpiryInvalid;
    final cvvError = Validators.isValidCvv(_cvvController.text) ? null : l10n.paymentCvvInvalid;
    final firstNameError = Validators.isRequired(_firstNameController.text) ? null : l10n.paymentFirstNameRequired;
    final lastNameError = Validators.isRequired(_lastNameController.text) ? null : l10n.paymentLastNameRequired;
    setState(() {
      _cardNumberError = cardNumberError;
      _expiryError = expiryError;
      _cvvError = cvvError;
      _firstNameError = firstNameError;
      _lastNameError = lastNameError;
    });
    return cardNumberError == null && expiryError == null && cvvError == null && firstNameError == null && lastNameError == null;
  }

  Future<void> _pay() async {
    if (_method == _PaymentMethod.card && !_validateCardForm()) return;
    setState(() => _isPaying = true);
    final success = await widget.onPay();
    if (!mounted) return;
    setState(() => _isPaying = false);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.paymentSuccessMessage)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final amountLabel = widget.totalAmount.toStringAsFixed(2);

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      children: [
        Text(l10n.paymentSummaryTitle, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: AppSpacing.xs),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final line in widget.summaryLines) ...[
                _SummaryRow(label: line.label, value: line.value),
                const SizedBox(height: AppSpacing.xs),
              ],
              const Divider(height: AppSpacing.lg),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(l10n.paymentTotalLabel, style: Theme.of(context).textTheme.titleSmall),
                  Text(
                    l10n.lawyerPriceSar(amountLabel),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.primary),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            Expanded(
              child: _MethodTab(
                label: l10n.paymentMethodDigitalWallet,
                selected: _method == _PaymentMethod.digitalWallet,
                onTap: () => setState(() => _method = _PaymentMethod.digitalWallet),
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: _MethodTab(
                label: l10n.paymentMethodCard,
                selected: _method == _PaymentMethod.card,
                onTap: () => setState(() => _method = _PaymentMethod.card),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        if (_method == _PaymentMethod.card) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: const BoxDecoration(gradient: AppGradients.navyHeader, borderRadius: AppRadii.lgRadius),
            child: Row(
              children: [
                Icon(Icons.credit_card, color: AppColors.onPrimary.withValues(alpha: 0.7)),
                const Spacer(),
                Text(
                  l10n.paymentCardTypeLabel,
                  style: Theme.of(
                    context,
                  ).textTheme.labelSmall?.copyWith(color: AppColors.onPrimary.withValues(alpha: 0.6), letterSpacing: 1),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            controller: _cardNumberController,
            label: l10n.paymentCardNumberLabel,
            keyboardType: TextInputType.number,
            hintText: '1234 5678 9012 3456',
            errorText: _cardNumberError,
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(child: AppTextField(controller: _expiryController, label: l10n.paymentExpiryLabel, hintText: 'MM/YY', errorText: _expiryError)),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: AppTextField(
                  controller: _cvvController,
                  label: l10n.paymentCvvLabel,
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  errorText: _cvvError,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(child: AppTextField(controller: _firstNameController, label: l10n.paymentFirstNameLabel, errorText: _firstNameError)),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: AppTextField(controller: _lastNameController, label: l10n.paymentLastNameLabel, errorText: _lastNameError)),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          AppButton(label: l10n.paymentPayNow(amountLabel), isLoading: _isPaying, onPressed: _isPaying ? null : _pay),
        ] else ...[
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: const BoxDecoration(color: AppColors.surfaceVariant, borderRadius: AppRadii.lgRadius),
            child: Column(
              children: [
                const Icon(Icons.apple, size: 40),
                const SizedBox(height: AppSpacing.sm),
                Text(l10n.paymentApplePayTitle, style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  l10n.paymentApplePaySubtitle,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.xs,
                  alignment: WrapAlignment.center,
                  children: [
                    Chip(avatar: const Icon(Icons.lock_outline, size: 14), label: Text(l10n.paymentApplePayNoCardSharing, style: const TextStyle(fontSize: 11))),
                    Chip(avatar: const Icon(Icons.flash_on, size: 14), label: Text(l10n.paymentApplePayInstant, style: const TextStyle(fontSize: 11))),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppButton(label: l10n.paymentPayWithApple(amountLabel), icon: Icons.apple, isLoading: _isPaying, onPressed: _isPaying ? null : _pay),
        ],
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(child: Text(label, style: Theme.of(context).textTheme.bodySmall)),
        const SizedBox(width: AppSpacing.sm),
        Text(value, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}

class _MethodTab extends StatelessWidget {
  const _MethodTab({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadii.mdRadius,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.primary.withValues(alpha: 0.08) : Colors.transparent,
          borderRadius: AppRadii.mdRadius,
          border: Border.all(color: selected ? AppColors.primary : AppColors.border, width: selected ? 1.5 : 1),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: selected ? AppColors.primary : AppColors.textSecondary,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
