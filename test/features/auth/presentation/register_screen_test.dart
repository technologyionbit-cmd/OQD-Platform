import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:aqd_ionbit/app.dart';
import 'package:aqd_ionbit/core/config/app_config.dart';
import 'package:aqd_ionbit/core/errors/failure.dart';
import 'package:aqd_ionbit/core/errors/result.dart';
import 'package:aqd_ionbit/core/providers/core_providers.dart';
import 'package:aqd_ionbit/core/security/token_manager.dart';
import 'package:aqd_ionbit/core/storage/app_preferences.dart';
import 'package:aqd_ionbit/core/widgets/app_chip.dart';
import 'package:aqd_ionbit/core/widgets/app_text_field.dart';
import 'package:aqd_ionbit/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:aqd_ionbit/features/auth/domain/entities/auth_user.dart';
import 'package:aqd_ionbit/features/auth/domain/entities/register_request.dart';
import 'package:aqd_ionbit/features/auth/domain/entities/user_role.dart';
import 'package:aqd_ionbit/features/auth/domain/repositories/auth_repository.dart';
import 'package:aqd_ionbit/features/auth/presentation/screens/verify_email_screen.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

typedef _SessionResult = Result<({AuthUser user, AuthTokens tokens})>;

const _newUser = AuthUser(id: 'u1', fullName: 'Ahmad', email: 'ahmad@aqd.test', role: UserRole.client, emailVerified: false);
const _tokens = AuthTokens(accessToken: 'access', refreshToken: 'refresh');
const _config = AppConfig(
  apiBaseUrl: 'http://localhost/v1',
  enableNetworkLogging: false,
  termsUrl: 'https://example.test/terms',
  privacyUrl: 'https://example.test/privacy',
);

void main() {
  late _MockAuthRepository repository;
  late List<Uri> openedLinks;

  setUpAll(() {
    registerFallbackValue(
      const RegisterRequest.individual(fullName: '', phone: '', email: '', password: '', acceptTerms: true, termsVersion: ''),
    );
  });

  setUp(() {
    repository = _MockAuthRepository();
    openedLinks = [];
    when(repository.restoreSession).thenAnswer((_) async => const Result.success(null));
  });

  Future<void> pumpRegister(WidgetTester tester) async {
    // Tall phone-width surface so the whole form fits without scrolling.
    tester.view.physicalSize = const Size(420, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    SharedPreferences.setMockInitialValues({'prefs.onboarding_seen': true});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appPreferencesProvider.overrideWithValue(AppPreferences(prefs)),
          authRepositoryProvider.overrideWithValue(repository),
          appConfigProvider.overrideWithValue(_config),
          linkLauncherProvider.overrideWithValue((url) async {
            openedLinks.add(url);
            return true;
          }),
        ],
        child: const AqdApp(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('إنشاء حساب جديد'));
    await tester.pumpAndSettle();
  }

  Finder field(String label) => find.descendant(of: find.widgetWithText(AppTextField, label), matching: find.byType(TextField));

  Future<void> fillIndividual(WidgetTester tester, {String password = 'Password123', bool acceptTerms = true}) async {
    await tester.enterText(field('الاسم الكامل'), 'Ahmad');
    await tester.enterText(field('رقم الهاتف'), '0791234567');
    await tester.enterText(field('البريد الإلكتروني'), 'ahmad@aqd.test');
    await tester.enterText(field('كلمة المرور'), password);
    if (acceptTerms) await tester.tap(find.byType(Checkbox));
    await tester.pump();
  }

  Future<void> submit(WidgetTester tester) async {
    await tester.tap(find.text('إنشاء الحساب'));
    await tester.pumpAndSettle();
  }

  void registerAnswers(Future<_SessionResult> Function() answer) {
    when(() => repository.register(any())).thenAnswer((_) => answer());
  }

  testWidgets('shows the password rules under the password field', (tester) async {
    await pumpRegister(tester);

    expect(find.text('8 أحرف على الأقل، وتحتوي على حرف ورقم'), findsOneWidget);
  });

  testWidgets('refuses to submit without accepting the terms', (tester) async {
    await pumpRegister(tester);
    await fillIndividual(tester, acceptTerms: false);

    await submit(tester);

    expect(find.text('يجب الموافقة على شروط الخدمة وسياسة الخصوصية'), findsOneWidget);
    verifyNever(() => repository.register(any()));
  });

  testWidgets('checks the password the way the server does', (tester) async {
    await pumpRegister(tester);

    await fillIndividual(tester, password: 'onlyletters');
    await submit(tester);
    expect(find.text('كلمة المرور يجب أن تحتوي على حرف ورقم على الأقل'), findsOneWidget);

    await tester.enterText(field('كلمة المرور'), 'a1${'ب' * 36}');
    await submit(tester);
    expect(find.text('كلمة المرور طويلة جدًا'), findsOneWidget);

    verifyNever(() => repository.register(any()));
  });

  testWidgets('caps text fields at the server limits', (tester) async {
    await pumpRegister(tester);

    await tester.enterText(field('الاسم الكامل'), 'x' * 200);
    await tester.pump();

    final name = tester.widget<TextField>(field('الاسم الكامل'));
    expect(name.controller!.text.length, 120);
  });

  testWidgets('sends the accepted terms version and lands on email verification', (tester) async {
    registerAnswers(() async => const Result.success((user: _newUser, tokens: _tokens)));
    await pumpRegister(tester);
    await fillIndividual(tester);

    await submit(tester);

    final request = verify(() => repository.register(captureAny())).captured.single as RegisterRequest;
    expect(request.acceptTerms, isTrue);
    expect(request.termsVersion, AppConfig.termsVersion);
    expect(find.byType(VerifyEmailScreen), findsOneWidget);
    expect(find.text('أرسلنا رمزًا مكونًا من 6 أرقام إلى ahmad@aqd.test'), findsOneWidget);
  });

  testWidgets('a taken email is shown on the email field in Arabic, never the server text', (tester) async {
    registerAnswers(
      () async => const Result.failure(
        ValidationFailure(
          message: 'This email is already registered.',
          code: ApiErrorCodes.emailAlreadyRegistered,
          fieldErrors: {
            'email': ['This email is already registered.'],
          },
        ),
      ),
    );
    await pumpRegister(tester);
    await fillIndividual(tester);

    await submit(tester);

    final email = tester.widget<TextField>(field('البريد الإلكتروني'));
    expect(email.decoration!.errorText, 'هذا البريد الإلكتروني مسجَّل مسبقًا');
    expect(find.textContaining('already registered'), findsNothing);
  });

  testWidgets('a taken commercial registration number is shown on its field', (tester) async {
    registerAnswers(
      () async => const Result.failure(
        ValidationFailure(
          code: ApiErrorCodes.commercialRegistrationTaken,
          fieldErrors: {
            'commercialRegistrationNumber': ['in use'],
          },
        ),
      ),
    );
    await pumpRegister(tester);
    await tester.tap(find.text('شركة'));
    await tester.pumpAndSettle();
    await tester.enterText(field('اسم المنشأة / الشركة'), 'Rowad');
    await tester.enterText(field('رقم السجل التجاري'), 'CR-1');
    await tester.enterText(field('رقم الهاتف'), '0791234567');
    await tester.enterText(field('البريد الإلكتروني'), 'co@aqd.test');
    await tester.enterText(field('كلمة المرور'), 'Password123');
    await tester.tap(find.byType(Checkbox));

    await submit(tester);

    final registration = tester.widget<TextField>(field('رقم السجل التجاري'));
    expect(registration.decoration!.errorText, 'رقم السجل التجاري مستخدم في حساب آخر');
  });

  testWidgets('plain field errors get a localized message, not the server text', (tester) async {
    registerAnswers(
      () async => const Result.failure(
        ValidationFailure(
          code: ApiErrorCodes.validationError,
          fieldErrors: {
            'phone': ['Enter a valid phone number.'],
          },
        ),
      ),
    );
    await pumpRegister(tester);
    await fillIndividual(tester);

    await submit(tester);

    expect(tester.widget<TextField>(field('رقم الهاتف')).decoration!.errorText, 'رقم الهاتف غير صحيح');
    expect(find.text('Enter a valid phone number.'), findsNothing);
  });

  testWidgets('outdated terms explain that the app needs updating', (tester) async {
    registerAnswers(
      () async => const Result.failure(
        ValidationFailure(
          code: ApiErrorCodes.termsVersionOutdated,
          fieldErrors: {
            'termsVersion': ['The terms have changed.'],
          },
        ),
      ),
    );
    await pumpRegister(tester);
    await fillIndividual(tester);

    await submit(tester);

    expect(find.text('تم تحديث شروط الخدمة، حدّث التطبيق ثم حاول مجددًا'), findsOneWidget);
  });

  testWidgets('submitting again from the keyboard while in flight sends one request', (tester) async {
    final pending = Completer<_SessionResult>();
    registerAnswers(() => pending.future);
    await pumpRegister(tester);
    await fillIndividual(tester);

    await tester.tap(find.text('إنشاء الحساب'));
    await tester.pump();
    await tester.showKeyboard(field('كلمة المرور'));
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();

    verify(() => repository.register(any())).called(1);
    pending.complete(const Result.failure(NetworkFailure()));
    await tester.pumpAndSettle();
  });

  testWidgets('the terms and privacy links open the configured pages without ticking the box', (tester) async {
    await pumpRegister(tester);

    await tester.tapOnText(find.textRange.ofSubstring('شروط الخدمة'));
    await tester.pump();
    await tester.tapOnText(find.textRange.ofSubstring('سياسة الخصوصية'));
    await tester.pump();

    expect(openedLinks, [Uri.parse(_config.termsUrl), Uri.parse(_config.privacyUrl)]);
    expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, isFalse);
  });

  testWidgets('announces which account type is selected', (tester) async {
    final semantics = tester.ensureSemantics();
    await pumpRegister(tester);

    expect(tester.getSemantics(find.widgetWithText(AppChip, 'فرد')), isSemantics(isSelected: true, isButton: true));
    expect(tester.getSemantics(find.widgetWithText(AppChip, 'شركة')), isSemantics(isSelected: false, isButton: true));
    semantics.dispose();
  });
}
