import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:aqd_ionbit/features/auth/presentation/widgets/login_required_dialog.dart';

import 'package:aqd_ionbit/core/routing/route_paths.dart';
import 'package:aqd_ionbit/features/auth/presentation/screens/biometric_login_screen.dart';
import 'package:aqd_ionbit/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:aqd_ionbit/features/auth/presentation/screens/login_screen.dart';
import 'package:aqd_ionbit/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:aqd_ionbit/features/auth/presentation/screens/otp_verification_screen.dart';
import 'package:aqd_ionbit/features/auth/presentation/screens/register_screen.dart';
import 'package:aqd_ionbit/features/auth/presentation/screens/reset_password_screen.dart';
import 'package:aqd_ionbit/features/auth/presentation/screens/verify_phone_screen.dart';
import 'package:aqd_ionbit/features/auth/presentation/screens/welcome_screen.dart';

/// Routes reachable while signed out, once onboarding has been seen. Kept
/// as a set so the router's redirect logic doesn't hardcode a chain of
/// `||` comparisons.
const publicAuthRoutes = {RoutePaths.welcome, RoutePaths.biometricLogin, RoutePaths.login, RoutePaths.register, RoutePaths.forgotPassword, RoutePaths.otpVerification, RoutePaths.resetPassword};

/// Page that presents its route as a dialog over whatever is underneath.
class _DialogPage extends Page<void> {
  const _DialogPage({required this.child, super.key});

  final Widget child;

  @override
  Route<void> createRoute(BuildContext context) => DialogRoute<void>(context: context, settings: this, builder: (_) => child);
}

final authRoutes = [
  GoRoute(
    path: RoutePaths.loginRequired,
    pageBuilder: (context, state) => _DialogPage(key: state.pageKey, child: LoginRequiredDialog(from: state.uri.queryParameters['from'])),
  ),
  GoRoute(path: RoutePaths.onboarding, builder: (context, state) => const OnboardingScreen()),
  GoRoute(path: RoutePaths.welcome, builder: (context, state) => const WelcomeScreen()),
  GoRoute(path: RoutePaths.biometricLogin, builder: (context, state) => const BiometricLoginScreen()),
  GoRoute(path: RoutePaths.login, builder: (context, state) => const LoginScreen()),
  GoRoute(path: RoutePaths.register, builder: (context, state) => const RegisterScreen()),
  GoRoute(path: RoutePaths.forgotPassword, builder: (context, state) => const ForgotPasswordScreen()),
  GoRoute(path: RoutePaths.verifyPhone, builder: (context, state) => const VerifyPhoneScreen()),
  GoRoute(
    path: RoutePaths.otpVerification,
    // The phone number travels as `extra`, which a reload or deep link drops —
    // start the reset over rather than crash.
    redirect: (context, state) => state.extra is String ? null : RoutePaths.forgotPassword,
    builder: (context, state) => OtpVerificationScreen(phone: state.extra! as String),
  ),
  GoRoute(
    path: RoutePaths.resetPassword,
    redirect: (context, state) => state.extra is ({String phone, String code}) ? null : RoutePaths.forgotPassword,
    builder: (context, state) {
      final args = state.extra! as ({String phone, String code});
      return ResetPasswordScreen(phone: args.phone, code: args.code);
    },
  ),
];
