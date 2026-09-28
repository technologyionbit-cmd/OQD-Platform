import 'package:go_router/go_router.dart';

import 'package:aqd_ionbit/core/routing/route_paths.dart';
import 'package:aqd_ionbit/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:aqd_ionbit/features/auth/presentation/screens/login_screen.dart';
import 'package:aqd_ionbit/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:aqd_ionbit/features/auth/presentation/screens/otp_verification_screen.dart';
import 'package:aqd_ionbit/features/auth/presentation/screens/register_screen.dart';
import 'package:aqd_ionbit/features/auth/presentation/screens/reset_password_screen.dart';
import 'package:aqd_ionbit/features/auth/presentation/screens/verify_email_screen.dart';

/// Routes reachable while signed out, once onboarding has been seen. Kept
/// as a set so the router's redirect logic doesn't hardcode a chain of
/// `||` comparisons.
const publicAuthRoutes = {
  RoutePaths.login,
  RoutePaths.register,
  RoutePaths.forgotPassword,
  RoutePaths.otpVerification,
  RoutePaths.resetPassword,
};

final authRoutes = [
  GoRoute(path: RoutePaths.onboarding, builder: (context, state) => const OnboardingScreen()),
  GoRoute(path: RoutePaths.login, builder: (context, state) => const LoginScreen()),
  GoRoute(path: RoutePaths.register, builder: (context, state) => const RegisterScreen()),
  GoRoute(path: RoutePaths.forgotPassword, builder: (context, state) => const ForgotPasswordScreen()),
  GoRoute(path: RoutePaths.verifyEmail, builder: (context, state) => const VerifyEmailScreen()),
  GoRoute(
    path: RoutePaths.otpVerification,
    // The email travels as `extra`, which a reload or deep link drops —
    // start the reset over rather than crash.
    redirect: (context, state) => state.extra is String ? null : RoutePaths.forgotPassword,
    builder: (context, state) => OtpVerificationScreen(email: state.extra! as String),
  ),
  GoRoute(
    path: RoutePaths.resetPassword,
    redirect: (context, state) => state.extra is ({String email, String code}) ? null : RoutePaths.forgotPassword,
    builder: (context, state) {
      final args = state.extra! as ({String email, String code});
      return ResetPasswordScreen(email: args.email, code: args.code);
    },
  ),
];
