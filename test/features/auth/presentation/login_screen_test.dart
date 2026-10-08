import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:aqd_ionbit/app.dart';
import 'package:aqd_ionbit/core/errors/failure.dart';
import 'package:aqd_ionbit/core/errors/result.dart';
import 'package:aqd_ionbit/core/providers/core_providers.dart';
import 'package:aqd_ionbit/core/security/token_manager.dart';
import 'package:aqd_ionbit/core/storage/app_preferences.dart';
import 'package:aqd_ionbit/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:aqd_ionbit/features/auth/domain/entities/auth_user.dart';
import '../../../support/test_doubles.dart';

typedef _LoginResult = Result<({AuthUser user, AuthTokens tokens})>;

void main() {
  late MockAuthRepository repository;

  setUp(() {
    repository = MockAuthRepository();
    when(repository.restoreSession).thenAnswer((_) async => const Result.success(null));
  });

  Future<void> pumpLogin(WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({'prefs.onboarding_seen': true});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appPreferencesProvider.overrideWithValue(AppPreferences(prefs)),
          authRepositoryProvider.overrideWithValue(repository),
        ],
        child: const AqdApp(),
      ),
    );
    await tester.pumpAndSettle();
  }

  void loginAnswers(Future<_LoginResult> Function() answer) {
    when(
      () => repository.login(phone: any(named: 'phone'), password: any(named: 'password')),
    ).thenAnswer((_) => answer());
  }

  Future<void> submit(WidgetTester tester, {String phone = '0791234567', String password = 'Password123'}) async {
    await tester.enterText(find.byType(TextField).at(0), phone);
    await tester.enterText(find.byType(TextField).at(1), password);
    await tester.tap(find.text('دخول'));
    await tester.pumpAndSettle();
  }

  testWidgets('wrong credentials show the generic invalid-credentials message', (tester) async {
    loginAnswers(() async => const Result.failure(UnauthorizedFailure()));
    await pumpLogin(tester);

    await submit(tester);

    expect(find.text('رقم الهاتف أو كلمة المرور غير صحيحة'), findsOneWidget);
  });

  testWidgets('signs in with the phone number, normalized', (tester) async {
    loginAnswers(() async => const Result.failure(UnauthorizedFailure()));
    await pumpLogin(tester);

    await submit(tester, phone: ' 079 123 4567 ');

    verify(() => repository.login(phone: '+962791234567', password: 'Password123')).called(1);
  });

  testWidgets('refuses an email or a non-Jordanian number before sending', (tester) async {
    await pumpLogin(tester);

    await submit(tester, phone: 'user@aqd.test');

    expect(find.text('أدخل رقم موبايل أردني صحيح، مثل 0791234567'), findsOneWidget);
    verifyNever(() => repository.login(phone: any(named: 'phone'), password: any(named: 'password')));
  });

  testWidgets('too many attempts tells the user how long to wait', (tester) async {
    loginAnswers(() async => const Result.failure(RateLimitedFailure(retryAfter: Duration(minutes: 15))));
    await pumpLogin(tester);

    await submit(tester);

    expect(find.text('محاولات كثيرة، حاول مجددًا بعد 15 دقيقة'), findsOneWidget);
  });

  testWidgets('an inactive account gets a localized explanation, not the raw server text', (tester) async {
    loginAnswers(
      () async => const Result.failure(
        ForbiddenFailure(message: 'This account is not active.', code: ApiErrorCodes.accountInactive),
      ),
    );
    await pumpLogin(tester);

    await submit(tester);

    expect(find.text('هذا الحساب غير مفعّل، يرجى التواصل مع الدعم'), findsOneWidget);
    expect(find.text('This account is not active.'), findsNothing);
  });

  testWidgets('submitting again from the keyboard while in flight sends one request', (tester) async {
    final pending = Completer<_LoginResult>();
    loginAnswers(() => pending.future);
    await pumpLogin(tester);

    await tester.enterText(find.byType(TextField).at(0), '0791234567');
    await tester.enterText(find.byType(TextField).at(1), 'Password123');
    await tester.tap(find.text('دخول'));
    await tester.pump();
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();

    verify(() => repository.login(phone: any(named: 'phone'), password: any(named: 'password'))).called(1);
    pending.complete(const Result.failure(UnauthorizedFailure()));
    await tester.pumpAndSettle();
  });

  testWidgets('offers a language switch before sign-in', (tester) async {
    await pumpLogin(tester);

    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();

    expect(find.text('Sign In'), findsOneWidget);
  });
}
