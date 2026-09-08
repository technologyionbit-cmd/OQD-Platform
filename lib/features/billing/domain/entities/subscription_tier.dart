/// Plan tier shown on the Subscriptions & Plans screen — mock only, no
/// real billing provider behind it.
enum SubscriptionTier { basic, pro, enterprise }

/// How often the plan is billed — changes the price shown per tier, per the
/// reference's monthly/6-months/annual toggle.
enum BillingCycle { monthly, sixMonths, annual }
