import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:aqd_ionbit/core/config/env_config.dart';
import 'package:aqd_ionbit/core/config/environment.dart';
import 'package:aqd_ionbit/core/localization/generated/app_localizations.dart';
import 'package:aqd_ionbit/core/providers/core_providers.dart';
import 'package:aqd_ionbit/core/security/token_manager.dart';
import 'package:aqd_ionbit/core/storage/app_preferences.dart';
import 'package:aqd_ionbit/core/theme/app_theme.dart';
import 'package:aqd_ionbit/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:aqd_ionbit/features/auth/presentation/screens/login_screen.dart';
import 'package:aqd_ionbit/features/auth/presentation/screens/onboarding_screen.dart';
import 'package:aqd_ionbit/features/auth/presentation/screens/otp_verification_screen.dart';
import 'package:aqd_ionbit/features/auth/presentation/screens/register_screen.dart';
import 'package:aqd_ionbit/features/auth/presentation/screens/reset_password_screen.dart';

class _MockTokenManager extends Mock implements TokenManager {}

/// A small representative spread, not exhaustive — the point is to catch a
/// RenderFlex overflow that only shows up at a real device extreme, not to
/// enumerate every physical device.
const _smallPhone = Size(320, 568); // iPhone SE (1st gen) — the narrowest realistic target
const _largePhone = Size(430, 932); // iPhone 15 Pro Max

Future<void> _pumpAtSize(WidgetTester tester, Widget screen, Size size, {Locale locale = const Locale('ar')}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  final tokenManager = _MockTokenManager();
  when(() => tokenManager.loadFromStorage()).thenAnswer((_) async => null);
  when(() => tokenManager.current).thenReturn(null);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        envConfigProvider.overrideWithValue(EnvConfig.forEnvironment(Environment.development)),
        appPreferencesProvider.overrideWithValue(AppPreferences(prefs)),
        tokenManagerProvider.overrideWithValue(tokenManager),
      ],
      child: MaterialApp(
        theme: AppTheme.light,
        locale: locale,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: screen,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  final screens = <String, Widget Function()>{
    'OnboardingScreen': () => const OnboardingScreen(),
    'LoginScreen': () => const LoginScreen(),
    'RegisterScreen': () => const RegisterScreen(),
    'ForgotPasswordScreen': () => const ForgotPasswordScreen(),
    'OtpVerificationScreen': () => const OtpVerificationScreen(destination: 'client@aqd.test'),
    'ResetPasswordScreen': () => const ResetPasswordScreen(destination: 'client@aqd.test', code: '1234'),
  };

  for (final entry in screens.entries) {
    for (final locale in [const Locale('ar'), const Locale('en')]) {
      for (final size in [_smallPhone, _largePhone]) {
        testWidgets('${entry.key} renders with no overflow at ${size.width.toInt()}x${size.height.toInt()} (${locale.languageCode})', (
          tester,
        ) async {
          await _pumpAtSize(tester, entry.value(), size, locale: locale);
          expect(tester.takeException(), isNull);
        });
      }
    }
  }
}
