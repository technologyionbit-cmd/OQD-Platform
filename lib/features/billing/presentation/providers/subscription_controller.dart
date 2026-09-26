import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aqd_ionbit/features/billing/domain/entities/subscription_tier.dart';

class SubscriptionState {
  const SubscriptionState({this.tier, this.cycle = BillingCycle.monthly});

  final SubscriptionTier? tier;
  final BillingCycle cycle;

  SubscriptionState copyWith({SubscriptionTier? tier, BillingCycle? cycle}) {
    return SubscriptionState(tier: tier ?? this.tier, cycle: cycle ?? this.cycle);
  }
}

/// The account's active plan — mock only, no real billing provider behind
/// it. [subscribe] is what the subscription payment screen calls on
/// success; the Account screen's plan badge and every gated feature read
/// this same state, so upgrading actually changes what the rest of the app
/// shows.
class SubscriptionController extends Notifier<SubscriptionState> {
  @override
  SubscriptionState build() => const SubscriptionState();

  void setCycle(BillingCycle cycle) => state = state.copyWith(cycle: cycle);

  Future<void> subscribe(SubscriptionTier tier) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    state = state.copyWith(tier: tier);
  }
}

final subscriptionControllerProvider = NotifierProvider<SubscriptionController, SubscriptionState>(SubscriptionController.new);
