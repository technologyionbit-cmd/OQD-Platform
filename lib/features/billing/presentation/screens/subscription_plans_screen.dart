import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:aqd_ionbit/core/localization/generated/app_localizations.dart';
import 'package:aqd_ionbit/core/routing/route_paths.dart';
import 'package:aqd_ionbit/core/theme/app_colors.dart';
import 'package:aqd_ionbit/core/theme/app_radii.dart';
import 'package:aqd_ionbit/core/theme/app_spacing.dart';
import 'package:aqd_ionbit/core/theme/app_status_colors.dart';
import 'package:aqd_ionbit/core/widgets/app_button.dart';
import 'package:aqd_ionbit/core/widgets/app_card.dart';
import 'package:aqd_ionbit/features/billing/domain/entities/invoice.dart';
import 'package:aqd_ionbit/features/billing/domain/entities/subscription_tier.dart';
import 'package:aqd_ionbit/features/billing/presentation/providers/invoices_controller.dart';
import 'package:aqd_ionbit/features/billing/presentation/providers/subscription_controller.dart';
import 'package:aqd_ionbit/features/billing/presentation/widgets/payment_panel.dart';

const _prices = {
  SubscriptionTier.basic: {BillingCycle.monthly: 20.0, BillingCycle.sixMonths: 40.0, BillingCycle.annual: 80.0},
  SubscriptionTier.pro: {BillingCycle.monthly: 49.0, BillingCycle.sixMonths: 99.0, BillingCycle.annual: 189.0},
  SubscriptionTier.enterprise: {BillingCycle.monthly: 99.0, BillingCycle.sixMonths: 199.0, BillingCycle.annual: 399.0},
};

String _tierLabel(SubscriptionTier tier, AppLocalizations l10n) => switch (tier) {
  SubscriptionTier.basic => l10n.subscriptionTierBasic,
  SubscriptionTier.pro => l10n.subscriptionTierPro,
  SubscriptionTier.enterprise => l10n.subscriptionTierEnterprise,
};

String _priceLabel(SubscriptionTier tier, BillingCycle cycle, AppLocalizations l10n) {
  final amount = _prices[tier]![cycle]!.toStringAsFixed(0);
  return switch (cycle) {
    BillingCycle.monthly => l10n.subscriptionPerMonth(amount),
    BillingCycle.sixMonths => l10n.subscriptionPerSixMonths(amount),
    BillingCycle.annual => l10n.subscriptionPerYear(amount),
  };
}

/// The reference's plan-tier + billing-cycle upgrade screen — mock only
/// (see [SubscriptionController]). Tapping a plan's CTA swaps in the shared
/// [PaymentPanel] inline (same inline-step pattern as `BookingDetailsScreen`)
/// rather than pushing a new route.
class SubscriptionPlansScreen extends ConsumerStatefulWidget {
  const SubscriptionPlansScreen({super.key, this.routeBase = RoutePaths.clientBase});

  final String routeBase;

  @override
  ConsumerState<SubscriptionPlansScreen> createState() => _SubscriptionPlansScreenState();
}

class _SubscriptionPlansScreenState extends ConsumerState<SubscriptionPlansScreen> {
  SubscriptionTier? _payingTier;
  bool _success = false;

  Future<bool> _pay(SubscriptionTier tier, BillingCycle cycle) async {
    await ref.read(subscriptionControllerProvider.notifier).subscribe(tier);
    if (!mounted) return false;
    final l10n = AppLocalizations.of(context)!;
    ref
        .read(invoicesControllerProvider.notifier)
        .add(
          Invoice(
            id: 'inv_sub_${DateTime.now().microsecondsSinceEpoch}',
            title: _tierLabel(tier, l10n),
            amount: _prices[tier]![cycle]!,
            date: DateTime.now(),
            status: InvoiceStatus.paid,
          ),
        );
    setState(() => _success = true);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final subscription = ref.watch(subscriptionControllerProvider);

    if (_success) {
      return Scaffold(body: _SuccessView(tier: _payingTier!, cycle: subscription.cycle, routeBase: widget.routeBase));
    }

    if (_payingTier != null) {
      final tier = _payingTier!;
      return Scaffold(
        appBar: AppBar(title: Text(l10n.paymentTitle), leading: BackButton(onPressed: () => setState(() => _payingTier = null))),
        body: SafeArea(
          child: PaymentPanel(
            summaryLines: [PaymentSummaryLine(label: _tierLabel(tier, l10n), value: _priceLabel(tier, subscription.cycle, l10n))],
            totalAmount: _prices[tier]![subscription.cycle]!,
            onPay: () => _pay(tier, subscription.cycle),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.subscriptionPlansTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          children: [
            Row(
              children: [
                for (final cycle in BillingCycle.values) ...[
                  Expanded(
                    child: _CycleTab(
                      label: switch (cycle) {
                        BillingCycle.monthly => l10n.subscriptionCycleMonthly,
                        BillingCycle.sixMonths => l10n.subscriptionCycleSixMonths,
                        BillingCycle.annual => l10n.subscriptionCycleAnnual,
                      },
                      saveBadge: switch (cycle) {
                        BillingCycle.monthly => null,
                        BillingCycle.sixMonths => l10n.subscriptionSaveBadge(10),
                        BillingCycle.annual => l10n.subscriptionSaveBadge(15),
                      },
                      selected: subscription.cycle == cycle,
                      onTap: () => ref.read(subscriptionControllerProvider.notifier).setCycle(cycle),
                    ),
                  ),
                  if (cycle != BillingCycle.values.last) const SizedBox(width: AppSpacing.xs),
                ],
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            for (final tier in SubscriptionTier.values) ...[
              _PlanCard(
                tier: tier,
                cycle: subscription.cycle,
                isCurrent: subscription.tier == tier,
                onUpgrade: () => setState(() => _payingTier = tier),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ],
        ),
      ),
    );
  }
}

class _CycleTab extends StatelessWidget {
  const _CycleTab({required this.label, required this.saveBadge, required this.selected, required this.onTap});

  final String label;
  final String? saveBadge;
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
          color: selected ? AppColors.primary : Colors.transparent,
          borderRadius: AppRadii.mdRadius,
          border: Border.all(color: selected ? AppColors.primary : AppColors.border),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: selected ? AppColors.onPrimary : AppColors.textPrimary, fontWeight: FontWeight.w600),
            ),
            if (saveBadge != null)
              PositionedDirectional(
                top: -18,
                end: -4,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs, vertical: AppSpacing.xxs),
                  decoration: BoxDecoration(color: AppColors.secondary, borderRadius: BorderRadius.circular(AppRadii.pill)),
                  child: Text(saveBadge!, style: const TextStyle(color: AppColors.onPrimary, fontSize: 9, fontWeight: FontWeight.w700)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({required this.tier, required this.cycle, required this.isCurrent, required this.onUpgrade});

  final SubscriptionTier tier;
  final BillingCycle cycle;
  final bool isCurrent;
  final VoidCallback onUpgrade;

  List<String> _features(AppLocalizations l10n) => switch (tier) {
    SubscriptionTier.basic => [
      l10n.subscriptionBasicFeature1,
      l10n.subscriptionBasicFeature2,
      l10n.subscriptionBasicFeature3,
      l10n.subscriptionBasicFeature4,
    ],
    SubscriptionTier.pro => [
      l10n.subscriptionProFeature1,
      l10n.subscriptionProFeature2,
      l10n.subscriptionProFeature3,
      l10n.subscriptionProFeature4,
      l10n.subscriptionProFeature5,
      l10n.subscriptionProFeature6,
    ],
    SubscriptionTier.enterprise => [
      l10n.subscriptionEnterpriseFeature1,
      l10n.subscriptionEnterpriseFeature2,
      l10n.subscriptionEnterpriseFeature3,
      l10n.subscriptionEnterpriseFeature4,
      l10n.subscriptionEnterpriseFeature5,
      l10n.subscriptionEnterpriseFeature6,
    ],
  };

  String _description(AppLocalizations l10n) => switch (tier) {
    SubscriptionTier.basic => l10n.subscriptionBasicDesc,
    SubscriptionTier.pro => l10n.subscriptionProDesc,
    SubscriptionTier.enterprise => l10n.subscriptionEnterpriseDesc,
  };

  bool get _isPopular => tier == SubscriptionTier.pro;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final tierLabel = _tierLabel(tier, l10n);

    return Container(
      decoration: BoxDecoration(
        borderRadius: AppRadii.lgRadius,
        border: Border.all(color: _isPopular ? AppColors.secondary : AppColors.border, width: _isPopular ? 2 : 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_isPopular)
            Container(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
              decoration: const BoxDecoration(color: AppColors.secondary, borderRadius: BorderRadiusDirectional.vertical(top: Radius.circular(AppRadii.md))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.star, color: AppColors.onPrimary, size: 14),
                  const SizedBox(width: AppSpacing.xxs),
                  Text(l10n.subscriptionMostPopular, style: const TextStyle(color: AppColors.onPrimary, fontSize: 12, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(tierLabel, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: AppSpacing.xxs),
                Text(_priceLabel(tier, cycle, l10n), style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AppColors.primary)),
                const SizedBox(height: AppSpacing.xs),
                Text(_description(l10n), style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: AppSpacing.md),
                for (final feature in _features(l10n))
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, color: context.statusColors.success.foreground, size: 18),
                        const SizedBox(width: AppSpacing.xs),
                        Expanded(child: Text(feature, style: Theme.of(context).textTheme.bodyMedium)),
                      ],
                    ),
                  ),
                const SizedBox(height: AppSpacing.md),
                AppButton(
                  label: isCurrent ? tierLabel : l10n.subscriptionUpgradeButton(tierLabel),
                  variant: _isPopular ? AppButtonVariant.primary : AppButtonVariant.outlined,
                  onPressed: isCurrent ? null : onUpgrade,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SuccessView extends StatelessWidget {
  const _SuccessView({required this.tier, required this.cycle, required this.routeBase});

  final SubscriptionTier tier;
  final BillingCycle cycle;
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
              Text(l10n.subscriptionSuccessTitle, textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: AppSpacing.xs),
              Text(
                l10n.subscriptionSuccessMessage,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.xl),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _SuccessRow(label: _tierLabel(tier, l10n), value: _priceLabel(tier, cycle, l10n)),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              AppButton(label: l10n.subscriptionBackHome, onPressed: () => context.go(RoutePaths.accountTabFor(routeBase))),
            ],
          ),
        ),
      ),
    );
  }
}

class _SuccessRow extends StatelessWidget {
  const _SuccessRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        Text(value, style: Theme.of(context).textTheme.titleSmall),
      ],
    );
  }
}
