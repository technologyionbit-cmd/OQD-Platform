import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:aqd_ionbit/core/errors/failure.dart';
import 'package:aqd_ionbit/core/errors/result.dart';
import 'package:aqd_ionbit/features/auth/domain/entities/auth_user.dart';
import 'package:aqd_ionbit/features/auth/domain/entities/user_role.dart';
import 'package:aqd_ionbit/features/auth/presentation/screens/verify_phone_screen.dart';
import 'package:aqd_ionbit/features/auth/presentation/widgets/phone_verification_banner.dart';
import 'package:aqd_ionbit/features/auth/presentation/widgets/otp_code_field.dart';
import 'package:aqd_ionbit/features/home/presentation/screens/client_home_screen.dart';

import '../../../support/role_test_harness.dart';

const _unverified = AuthUser(id: 'u_client', fullName: 'Client User', email: 'client@aqd.test', phone: '+962791234567', role: UserRole.client, phoneVerified: false);

void main() {
  Future<RoleTestHarness> openVerifyScreen(WidgetTester tester) async {
    final harness = await pumpAuthenticatedApp(tester, user: _unverified, size: const Size(420, 1600));
    await tester.tap(find.text('تأكيد الآن'));
    await tester.pumpAndSettle();
    return harness;
  }

  Future<void> enterCode(WidgetTester tester, String code) async {
    final boxes = find.descendant(of: find.byType(OtpCodeField), matching: find.byType(TextField));
    for (var i = 0; i < code.length; i++) {
      await tester.enterText(boxes.at(i), code[i]);
    }
    await tester.pump();
  }

  testWidgets('an unverified user sees the banner, and a verified one does not', (tester) async {
    await pumpAuthenticatedApp(tester, user: _unverified, size: const Size(420, 1600));
    expect(find.text('رقم هاتفك غير مؤكَّد. أكّده لتتمكن من حجز الاستشارات وتوقيع العقود وإضافة التقييمات'), findsOneWidget);
  });

  testWidgets('a verified user has no banner', (tester) async {
    await pumpAuthenticatedApp(tester, user: testClient, size: const Size(420, 1600));
    expect(find.byType(PhoneVerificationBanner), findsOneWidget);
    expect(find.text('تأكيد الآن'), findsNothing);
  });

  testWidgets('the banner opens the code screen and "later" returns home', (tester) async {
    await openVerifyScreen(tester);
    expect(find.byType(VerifyPhoneScreen), findsOneWidget);
    expect(find.text('أرسلنا رسالة نصية فيها رمز من 6 أرقام إلى 0791234567'), findsOneWidget);

    await tester.tap(find.text('لاحقًا'));
    await tester.pumpAndSettle();

    expect(find.byType(VerifyPhoneScreen), findsNothing);
    expect(find.byType(ClientHomeScreen), findsOneWidget);
  });

  testWidgets('a wrong code shows a localized error and stays on the screen', (tester) async {
    final harness = await openVerifyScreen(tester);
    when(() => harness.repository.verifyPhone(code: any(named: 'code'))).thenAnswer(
      (_) async => const Result.failure(
        ValidationFailure(message: 'Invalid or expired code.', code: ApiErrorCodes.invalidVerificationCode),
      ),
    );

    await enterCode(tester, '123456');
    await tester.tap(find.text('تأكيد'));
    await tester.pumpAndSettle();

    expect(find.text('رمز التحقق غير صحيح'), findsOneWidget);
    expect(find.text('Invalid or expired code.'), findsNothing);
    expect(find.byType(VerifyPhoneScreen), findsOneWidget);
  });

  testWidgets('the right code verifies, returns home, and clears the banner', (tester) async {
    final harness = await openVerifyScreen(tester);
    when(() => harness.repository.verifyPhone(code: '123456')).thenAnswer((_) async => Result.success(_unverified.copyWith(phoneVerified: true)));

    await enterCode(tester, '123456');
    await tester.tap(find.text('تأكيد'));
    await tester.pumpAndSettle();

    verify(() => harness.repository.verifyPhone(code: '123456')).called(1);
    expect(find.byType(VerifyPhoneScreen), findsNothing);
    expect(find.text('تأكيد الآن'), findsNothing);
  });

  testWidgets('resend waits out the countdown and follows the server Retry-After', (tester) async {
    final harness = await openVerifyScreen(tester);
    when(harness.repository.resendPhoneVerification).thenAnswer(
      (_) async => const Result.failure(RateLimitedFailure(retryAfter: Duration(seconds: 90))),
    );

    expect(find.text('إعادة الإرسال بعد 01:00'), findsOneWidget);
    await tester.pump(VerifyPhoneScreen.resendCooldown);
    await tester.pump();

    await tester.tap(find.text('إعادة الإرسال'));
    await tester.pump();

    verify(harness.repository.resendPhoneVerification).called(1);
    expect(find.text('إعادة الإرسال بعد 01:30'), findsOneWidget);

    // Leave no timer running past the test.
    await tester.tap(find.text('لاحقًا'));
    await tester.pumpAndSettle();
  });

  testWidgets('a successful resend confirms and restarts the countdown', (tester) async {
    final harness = await openVerifyScreen(tester);
    when(harness.repository.resendPhoneVerification).thenAnswer((_) async => const Result.success(null));

    await tester.pump(VerifyPhoneScreen.resendCooldown);
    await tester.pump();
    await tester.tap(find.text('إعادة الإرسال'));
    await tester.pump();

    expect(find.text('تم إرسال رمز جديد'), findsOneWidget);
    expect(find.text('إعادة الإرسال بعد 01:00'), findsOneWidget);

    await tester.tap(find.text('لاحقًا'));
    await tester.pumpAndSettle();
  });
}
