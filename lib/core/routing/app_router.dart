import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:aqd_ionbit/app/home_screen.dart';
import 'package:aqd_ionbit/app/splash_screen.dart';
import 'package:aqd_ionbit/core/providers/core_providers.dart';
import 'package:aqd_ionbit/core/routing/route_paths.dart';
import 'package:aqd_ionbit/features/auth/presentation/providers/auth_controller.dart';
import 'package:aqd_ionbit/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:aqd_ionbit/features/auth/presentation/screens/login_screen.dart';
import 'package:aqd_ionbit/features/auth/presentation/screens/onboarding_screen.dart';
import 'package:aqd_ionbit/features/auth/presentation/screens/otp_verification_screen.dart';
import 'package:aqd_ionbit/features/auth/presentation/screens/register_screen.dart';
import 'package:aqd_ionbit/features/auth/presentation/screens/reset_password_screen.dart';

/// Routes reachable while signed out, once onboarding has been seen. Kept
/// as a set so `_redirect` doesn't hardcode a chain of `||` comparisons.
const _publicAuthRoutes = {
  RoutePaths.login,
  RoutePaths.register,
  RoutePaths.forgotPassword,
  RoutePaths.otpVerification,
  RoutePaths.resetPassword,
};

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
      GoRoute(path: RoutePaths.onboarding, builder: (context, state) => const OnboardingScreen()),
      GoRoute(path: RoutePaths.login, builder: (context, state) => const LoginScreen()),
      GoRoute(path: RoutePaths.register, builder: (context, state) => const RegisterScreen()),
      GoRoute(path: RoutePaths.forgotPassword, builder: (context, state) => const ForgotPasswordScreen()),
      GoRoute(
        path: RoutePaths.otpVerification,
        builder: (context, state) => OtpVerificationScreen(destination: state.extra! as String),
      ),
      GoRoute(
        path: RoutePaths.resetPassword,
        builder: (context, state) {
          final args = state.extra! as ({String destination, String code});
          return ResetPasswordScreen(destination: args.destination, code: args.code);
        },
      ),
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
  final location = state.matchedLocation;

  if (authState.isLoading) {
    return location == RoutePaths.splash ? null : RoutePaths.splash;
  }

  final hasSeenOnboarding = ref.read(appPreferencesProvider).hasSeenOnboarding;
  if (!isAuthenticated && !hasSeenOnboarding) {
    return location == RoutePaths.onboarding ? null : RoutePaths.onboarding;
  }

  if (!isAuthenticated) {
    if (location == RoutePaths.onboarding || _publicAuthRoutes.contains(location)) return null;
    return RoutePaths.login;
  }

  if (location == RoutePaths.splash || location == RoutePaths.onboarding || _publicAuthRoutes.contains(location)) {
    return RoutePaths.home;
  }
  return null;
}
