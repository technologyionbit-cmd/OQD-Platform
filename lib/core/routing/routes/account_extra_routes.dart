import 'package:go_router/go_router.dart';

import 'package:aqd_ionbit/core/routing/route_paths.dart';
import 'package:aqd_ionbit/features/billing/presentation/screens/subscription_plans_screen.dart';
import 'package:aqd_ionbit/features/profile/presentation/screens/help_support_screen.dart';
import 'package:aqd_ionbit/features/profile/presentation/screens/invoices_screen.dart';
import 'package:aqd_ionbit/features/profile/presentation/screens/payment_methods_screen.dart';
import 'package:aqd_ionbit/features/profile/presentation/screens/saved_signature_screen.dart';
import 'package:aqd_ionbit/features/profile/presentation/screens/security_privacy_screen.dart';

/// Account-menu sub-screens shared by every role (no role-specific logic
/// behind any of them) — one function so client/lawyer/company route files
/// register the same screens under their own base instead of each
/// re-typing identical `GoRoute`s.
List<RouteBase> accountExtraRoutesFor(String base) {
  return [
    GoRoute(path: RoutePaths.subscriptionPlansFor(base), builder: (context, state) => SubscriptionPlansScreen(routeBase: base)),
    GoRoute(path: RoutePaths.paymentMethodsFor(base), builder: (context, state) => const PaymentMethodsScreen()),
    GoRoute(path: RoutePaths.savedSignatureFor(base), builder: (context, state) => const SavedSignatureScreen()),
    GoRoute(path: RoutePaths.securityPrivacyFor(base), builder: (context, state) => const SecurityPrivacyScreen()),
    GoRoute(path: RoutePaths.helpSupportFor(base), builder: (context, state) => const HelpSupportScreen()),
    GoRoute(path: RoutePaths.invoicesFor(base), builder: (context, state) => const InvoicesScreen()),
  ];
}
