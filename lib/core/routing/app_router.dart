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
import 'package:aqd_ionbit/core/app/splash_screen.dart';
import 'package:aqd_ionbit/core/providers/core_providers.dart';
import 'package:aqd_ionbit/core/routing/route_paths.dart';
import 'package:aqd_ionbit/features/auth/domain/entities/user_role.dart';
import 'package:aqd_ionbit/features/auth/presentation/providers/auth_controller.dart';

/// Lives in `app/`, not `core/routing/` — unlike [RoutePaths] (plain
/// constants, genuinely feature-agnostic), this file imports every
/// feature's screens (via the route files below) to wire routes, which is
/// exactly the kind of cross-feature composition `core/` must never
/// depend on. `app/` is the composition root: it's allowed to know about
/// everything.
///
/// Single app-wide router, created once. Auth-state changes don't rebuild
/// [GoRouter] (that would reset navigation) — instead [_authRefreshNotifier]
/// pulses via `ref.listen`, and go_router re-evaluates [_redirect] itself.
final routerProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = ValueNotifier(ref.read(authControllerProvider));
  ref.listen(authControllerProvider, (_, next) => refreshNotifier.value = next);
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

  if (authState.isLoading) {
    return location == RoutePaths.splash ? null : RoutePaths.splash;
  }

  final hasSeenOnboarding = ref.read(appPreferencesProvider).hasSeenOnboarding;
  if (user == null && !hasSeenOnboarding) {
    return location == RoutePaths.onboarding ? null : RoutePaths.onboarding;
  }

  if (user == null) {
    if (location == RoutePaths.onboarding || publicAuthRoutes.contains(location)) return null;
    return RoutePaths.login;
  }

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
