import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:aqd_ionbit/core/routing/routes/auth_routes.dart';
import 'package:aqd_ionbit/core/routing/routes/client_contract_routes.dart';
import 'package:aqd_ionbit/core/routing/routes/client_extra_routes.dart';
import 'package:aqd_ionbit/core/routing/routes/client_routes.dart';
import 'package:aqd_ionbit/core/routing/routes/company_extra_routes.dart';
import 'package:aqd_ionbit/core/routing/routes/company_routes.dart';
import 'package:aqd_ionbit/core/routing/routes/lawyer_extra_routes.dart';
import 'package:aqd_ionbit/core/routing/routes/lawyer_routes.dart';
import 'package:aqd_ionbit/features/auth/presentation/screens/splash_screen.dart';
import 'package:aqd_ionbit/core/routing/route_paths.dart';
import 'package:aqd_ionbit/features/auth/domain/entities/user_role.dart';
import 'package:aqd_ionbit/features/auth/presentation/providers/auth_controller.dart';
import 'package:aqd_ionbit/features/auth/presentation/providers/phone_verification_prompt.dart';
import 'package:aqd_ionbit/features/onboarding/presentation/providers/onboarding_controller.dart';

/// Lives in `app/`, not `core/routing/` — unlike [RoutePaths] (plain
/// constants, genuinely feature-agnostic), this file imports every
/// feature's screens (via the route files below) to wire routes, which is
/// exactly the kind of cross-feature composition `core/` must never
/// depend on. `app/` is the composition root: it's allowed to know about
/// everything.
///
/// Single app-wide router, created once. State changes that affect where
/// the user may be (auth, onboarding) don't rebuild [GoRouter] (that would
/// reset navigation) — instead `refreshNotifier` pulses via `ref.listen`,
/// and go_router re-evaluates [_redirect] itself.
final routerProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = ValueNotifier(0);
  void refresh() => refreshNotifier.value++;
  // Only what [_redirect] reads. A profile edit (new name or email) must
  // not refresh: that re-applies the location from before the editing
  // screen closed, which opened it again.
  ref.listen(
    authControllerProvider.select((auth) => (auth.isLoading, auth.hasError, auth.value?.id, auth.value?.role, auth.value?.phoneVerified)),
    (_, _) => refresh(),
  );
  ref.listen(onboardingControllerProvider, (_, _) => refresh());
  ref.listen(phoneVerificationPromptProvider, (_, _) => refresh());
  ref.onDispose(refreshNotifier.dispose);

  return GoRouter(
    initialLocation: RoutePaths.splash,
    refreshListenable: refreshNotifier,
    redirect: (context, state) => _redirect(ref, state),
    routes: [
      GoRoute(path: RoutePaths.splash, builder: (context, state) => const SplashScreen()),
      ...authRoutes,
      ...clientContractRoutes(),
      ...clientExtraRoutes(),
      ...lawyerExtraRoutes(),
      ...companyExtraRoutes(),
      clientShellRoute(),
      lawyerShellRoute(),
      companyShellRoute(),
    ],
  );
});

/// Base path prefix for a role's routes — every route inside that role's
/// shell is nested under it, so this is also how the guard below tells
/// "client trying to open a lawyer route" apart from "client on their own
/// route".
String _roleBase(UserRole role) => switch (role) {
  UserRole.client => RoutePaths.clientBase,
  UserRole.lawyer => RoutePaths.lawyerBase,
  UserRole.company => RoutePaths.companyBase,
};

String _homeRouteFor(UserRole role) => switch (role) {
  UserRole.client => RoutePaths.clientHome,
  UserRole.lawyer => RoutePaths.lawyerDashboard,
  UserRole.company => RoutePaths.companyHome,
};

/// Single source of truth for auth + role access — no screen re-checks
/// this itself.
String? _redirect(Ref ref, GoRouterState state) {
  final authState = ref.read(authControllerProvider);
  final user = authState.value;
  final location = state.matchedLocation;

  // An error here means the stored session couldn't be verified (server
  // unreachable) — the splash screen owns the retry, so stay on it rather
  // than treating the user as signed out.
  if (authState.isLoading || authState.hasError) {
    return location == RoutePaths.splash ? null : RoutePaths.splash;
  }

  // Signed out: onboarding until it's been seen, then only the public auth
  // screens — landing on login by default (including straight out of
  // onboarding, which is how onboarding "navigates" when it completes).
  if (user == null) {
    if (!ref.read(onboardingControllerProvider)) {
      return location == RoutePaths.onboarding ? null : RoutePaths.onboarding;
    }
    return publicAuthRoutes.contains(location) ? null : RoutePaths.login;
  }

  // Signed in with an unverified phone: the code screen while the prompt
  // is on (right after sign-up, or from the banner). Otherwise that screen
  // is closed, whatever the reason (verified, "later", or a stale link).
  if (!user.phoneVerified && ref.read(phoneVerificationPromptProvider)) {
    return location == RoutePaths.verifyPhone ? null : RoutePaths.verifyPhone;
  }
  if (location == RoutePaths.verifyPhone) return _homeRouteFor(user.role);

  // Authenticated: never allowed on splash/onboarding/public-auth screens,
  // and confined to their own role's route subtree — a client hitting
  // `/lawyer/dashboard` (typed URL, stale deep link, whatever) lands back
  // on their own home rather than a lawyer-only screen.
  final isEntryOrPublicRoute = location == RoutePaths.splash || location == RoutePaths.onboarding || publicAuthRoutes.contains(location);
  final isOnOwnRoleRoute = location.startsWith(_roleBase(user.role));

  if (isEntryOrPublicRoute || !isOnOwnRoleRoute) {
    return _homeRouteFor(user.role);
  }
  return null;
}
