import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:aqd_ionbit/app/home_screen.dart';
import 'package:aqd_ionbit/app/splash_screen.dart';
import 'package:aqd_ionbit/core/routing/route_paths.dart';
import 'package:aqd_ionbit/features/auth/presentation/providers/auth_controller.dart';
import 'package:aqd_ionbit/features/auth/presentation/screens/login_screen.dart';

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
      GoRoute(path: RoutePaths.login, builder: (context, state) => const LoginScreen()),
      GoRoute(path: RoutePaths.home, builder: (context, state) => const HomeScreen()),
    ],
  );
});

/// Role-based redirects (client/lawyer/company shells) are added here in
/// the next phase, branching on `authState.value?.role` — the seam is
/// already in place via [AuthController]'s `AuthUser.role`.
String? _redirect(Ref ref, GoRouterState state) {
  final authState = ref.read(authControllerProvider);
  final isAuthenticated = authState.value != null;
  final isGoingToSplash = state.matchedLocation == RoutePaths.splash;
  final isGoingToLogin = state.matchedLocation == RoutePaths.login;

  if (authState.isLoading) {
    return isGoingToSplash ? null : RoutePaths.splash;
  }
  if (!isAuthenticated) {
    return isGoingToLogin ? null : RoutePaths.login;
  }
  if (isGoingToLogin || isGoingToSplash) {
    return RoutePaths.home;
  }
  return null;
}
