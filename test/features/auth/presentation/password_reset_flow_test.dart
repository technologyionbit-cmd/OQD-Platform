import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:aqd_ionbit/app.dart';
import 'package:aqd_ionbit/core/errors/failure.dart';
import 'package:aqd_ionbit/core/errors/result.dart';
import 'package:aqd_ionbit/core/providers/core_providers.dart';
import 'package:aqd_ionbit/core/routing/app_router.dart';
import 'package:aqd_ionbit/core/routing/route_paths.dart';
import 'package:aqd_ionbit/core/storage/app_preferences.dart';
import 'package:aqd_ionbit/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:aqd_ionbit/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:aqd_ionbit/features/auth/presentation/screens/login_screen.dart';
import 'package:aqd_ionbit/features/auth/presentation/screens/otp_verification_screen.dart';
import 'package:aqd_ionbit/features/auth/presentation/screens/reset_password_screen.dart';
import 'package:aqd_ionbit/features/auth/presentation/widgets/otp_code_field.dart';
import '../../../support/test_doubles.dart';

const _phone = '+962791234567';

void main() {
  late MockAuthRepository repository;
  late ProviderContainer container;

  setUp(() {
    repository = MockAuthRepository();
    when(repository.restoreSession).thenAnswer((_) async => const Result.success(null));
    when(() => repository.requestPasswordReset(phone: any(named: 'phone'))).thenAnswer((_) async => const Result.success(null));
  });

  /// Signed-out app on the login screen, tall enough that no step scrolls.
  Future<void> pumpApp(WidgetTester tester) async {
    tester.view.physicalSize = const Size(420, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    SharedPreferences.setMockInitialValues({'prefs.onboarding_seen': true});
    final prefs = await SharedPreferences.getInstance();
    container = ProviderContainer(
      overrides: [
        appPreferencesProvider.overrideWithValue(AppPreferences(prefs)),
        authRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const AqdApp()));
    await tester.pumpAndSettle();
  }

  Future<void> openForgotPassword(WidgetTester tester) async {
    await pumpApp(tester);
    await tester.tap(find.text('نسيت كلمة المرور؟'));
    await tester.pumpAndSettle();
    expect(find.byType(ForgotPasswordScreen), findsOneWidget);
  }

  Future<void> sendPhone(WidgetTester tester, String phone) async {
    await tester.enterText(find.byType(TextField), phone);
    await tester.tap(find.text('إرسال رمز التحقق'));
    await tester.pumpAndSettle();
  }

  Future<void> enterCode(WidgetTester tester, String code) async {
    await tester.enterText(find.descendant(of: find.byType(OtpCodeField), matching: find.byType(TextField)).first, code);
    await tester.pump();
    await tester.tap(find.text('تأكيد'));
    await tester.pumpAndSettle();
  }

  Future<void> openResetPassword(WidgetTester tester) async {
    when(
      () => repository.verifyPasswordResetCode(phone: _phone, code: '123456'),
    ).thenAnswer((_) async => const Result.success(null));
    await openForgotPassword(tester);
    await sendPhone(tester, _phone);
    await enterCode(tester, '123456');
    expect(find.byType(ResetPasswordScreen), findsOneWidget);
  }

  Future<void> submitPasswords(WidgetTester tester, String password, [String? confirm]) async {
    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), password);
    await tester.enterText(fields.at(1), confirm ?? password);
    await tester.tap(find.text('حفظ كلمة المرور'));
    await tester.pumpAndSettle();
  }

  testWidgets('asks for the phone number only and checks it before sending', (tester) async {
    await openForgotPassword(tester);
    expect(find.byType(TextField), findsOneWidget);

    await sendPhone(tester, 'user@aqd.test');
    expect(find.text('أدخل رقم موبايل أردني صحيح، مثل 0791234567'), findsOneWidget);

    await sendPhone(tester, '065000000');
    expect(find.text('أدخل رقم موبايل أردني صحيح، مثل 0791234567'), findsOneWidget);
    verifyNever(() => repository.requestPasswordReset(phone: any(named: 'phone')));
  });

  testWidgets('goes straight to the code screen once the code is sent', (tester) async {
    await openForgotPassword(tester);

    // Typed the local way, sent normalized, shown the local way.
    await sendPhone(tester, ' 079 123 4567 ');

    verify(() => repository.requestPasswordReset(phone: _phone)).called(1);
    expect(find.byType(OtpVerificationScreen), findsOneWidget);
    expect(find.text('أرسلنا رمزًا مكونًا من 6 أرقام إلى 0791234567'), findsOneWidget);
  });

  testWidgets('too many requests says how long to wait and stays on the form', (tester) async {
    when(() => repository.requestPasswordReset(phone: any(named: 'phone'))).thenAnswer(
      (_) async => const Result.failure(RateLimitedFailure(retryAfter: Duration(seconds: 40))),
    );
    await openForgotPassword(tester);

    await sendPhone(tester, _phone);

    expect(find.text('محاولات كثيرة، حاول مجددًا بعد دقيقة'), findsOneWidget);
    expect(find.byType(ForgotPasswordScreen), findsOneWidget);
  });

  testWidgets('a wrong or locked code shows a localized error, never server text', (tester) async {
    await openForgotPassword(tester);
    await sendPhone(tester, _phone);

    when(() => repository.verifyPasswordResetCode(phone: _phone, code: '111111')).thenAnswer(
      (_) async => const Result.failure(
        ValidationFailure(message: 'Invalid or expired code.', code: ApiErrorCodes.invalidVerificationCode),
      ),
    );
    await enterCode(tester, '111111');
    expect(find.text('رمز التحقق غير صحيح'), findsOneWidget);
    expect(find.text('Invalid or expired code.'), findsNothing);

    when(() => repository.verifyPasswordResetCode(phone: _phone, code: '222222')).thenAnswer(
      (_) async => const Result.failure(ValidationFailure(code: ApiErrorCodes.verificationCodeLocked)),
    );
    await enterCode(tester, '222222');
    expect(find.text('محاولات خاطئة كثيرة، اطلب رمزًا جديدًا'), findsOneWidget);
    expect(find.byType(OtpVerificationScreen), findsOneWidget);
  });

  testWidgets('resending waits out the cooldown, then honours Retry-After', (tester) async {
    await openForgotPassword(tester);
    await sendPhone(tester, _phone);
    expect(find.text('إعادة الإرسال بعد 01:00'), findsOneWidget);

    await tester.pump(const Duration(seconds: 61));
    when(() => repository.requestPasswordReset(phone: any(named: 'phone'))).thenAnswer(
      (_) async => const Result.failure(RateLimitedFailure(retryAfter: Duration(seconds: 90))),
    );
    await tester.tap(find.text('إعادة الإرسال'));
    await tester.pump();

    expect(find.text('إعادة الإرسال بعد 01:30'), findsOneWidget);
    // Let the countdown finish so no timer outlives the test.
    await tester.pump(const Duration(seconds: 91));
  });

  testWidgets('a right code leads to a new password, then back to login', (tester) async {
    await openResetPassword(tester);
    when(
      () => repository.resetPassword(phone: _phone, code: '123456', newPassword: 'NewPass123'),
    ).thenAnswer((_) async => const Result.success(null));

    await submitPasswords(tester, 'NewPass123');
    expect(find.text('تم تغيير كلمة المرور!'), findsOneWidget);

    await tester.tap(find.text('الذهاب لتسجيل الدخول'));
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('the new password follows the registration rules', (tester) async {
    await openResetPassword(tester);

    await submitPasswords(tester, 'onlyletters');
    expect(find.text('كلمة المرور يجب أن تحتوي على حرف ورقم على الأقل'), findsOneWidget);

    await submitPasswords(tester, 'NewPass123', 'NewPass124');
    expect(find.text('كلمتا المرور غير متطابقتين'), findsOneWidget);

    verifyNever(
      () => repository.resetPassword(
        phone: any(named: 'phone'),
        code: any(named: 'code'),
        newPassword: any(named: 'newPassword'),
      ),
    );
  });

  testWidgets('a code that expired before saving asks for a new one', (tester) async {
    await openResetPassword(tester);
    when(
      () => repository.resetPassword(
        phone: any(named: 'phone'),
        code: any(named: 'code'),
        newPassword: any(named: 'newPassword'),
      ),
    ).thenAnswer(
      (_) async => const Result.failure(ValidationFailure(code: ApiErrorCodes.invalidVerificationCode)),
    );

    await submitPasswords(tester, 'NewPass123');

    expect(find.text('انتهت صلاحية رمز التحقق. ارجع واطلب رمزًا جديدًا'), findsOneWidget);
    expect(find.byType(ResetPasswordScreen), findsOneWidget);
  });

  testWidgets('opening a later step without its data starts the reset over', (tester) async {
    await pumpApp(tester);

    container.read(routerProvider).go(RoutePaths.otpVerification);
    await tester.pumpAndSettle();
    expect(find.byType(ForgotPasswordScreen), findsOneWidget);

    container.read(routerProvider).go(RoutePaths.resetPassword);
    await tester.pumpAndSettle();
    expect(find.byType(ForgotPasswordScreen), findsOneWidget);
  });
}
