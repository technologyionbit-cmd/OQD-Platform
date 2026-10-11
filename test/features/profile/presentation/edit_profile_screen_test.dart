import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:aqd_ionbit/core/errors/failure.dart';
import 'package:aqd_ionbit/core/errors/result.dart';
import 'package:aqd_ionbit/core/routing/app_router.dart';
import 'package:aqd_ionbit/core/routing/route_paths.dart';
import 'package:aqd_ionbit/core/widgets/app_button.dart';
import 'package:aqd_ionbit/features/auth/domain/entities/auth_user.dart';
import 'package:aqd_ionbit/features/profile/presentation/screens/edit_profile_screen.dart';

import '../../../support/role_test_harness.dart';

const _nameLabel = 'الاسم الكامل';
const _emailLabel = 'البريد الإلكتروني';
const _passwordLabel = 'كلمة المرور الحالية';

Future<RoleTestHarness> _openEditProfile(WidgetTester tester, {AuthUser user = testClient, String? path}) async {
  final harness = await pumpAuthenticatedApp(tester, user: user);
  unawaited(harness.container.read(routerProvider).push(path ?? RoutePaths.clientAccountEdit));
  await tester.pumpAndSettle();
  expect(find.byType(EditProfileScreen), findsOneWidget);
  return harness;
}

Finder _field(String label) => find.widgetWithText(TextField, label);

String? _errorOf(WidgetTester tester, String label) => tester.widget<TextField>(_field(label)).decoration?.errorText;

Future<void> _tapSave(WidgetTester tester) async {
  await tester.pump(); // Let the last edit enable the button.
  await tester.tap(find.text('حفظ'));
  await tester.pumpAndSettle();
}

void _stubUpdate(RoleTestHarness harness, Result<AuthUser> result) {
  when(
    () => harness.repository.updateProfile(
      fullName: any(named: 'fullName'),
      email: any(named: 'email'),
      currentPassword: any(named: 'currentPassword'),
    ),
  ).thenAnswer((_) async => result);
}

void main() {
  testWidgets('save stays disabled until the name or email changes', (tester) async {
    await _openEditProfile(tester);
    AppButton saveButton() => tester.widget<AppButton>(find.widgetWithText(AppButton, 'حفظ'));

    expect(saveButton().onPressed, isNull);

    await tester.enterText(_field(_emailLabel), 'NEW@aqd.test');
    await tester.pump();
    expect(saveButton().onPressed, isNotNull);

    // Back to the stored email, only in other letter case: nothing to save.
    await tester.enterText(_field(_emailLabel), testClient.email.toUpperCase());
    await tester.pump();
    expect(saveButton().onPressed, isNull);
  });

  testWidgets('a change without the current password is not sent', (tester) async {
    final harness = await _openEditProfile(tester);
    _stubUpdate(harness, const Result.success(testClient));

    await tester.enterText(_field(_nameLabel), 'New Name');
    await _tapSave(tester);

    expect(_errorOf(tester, _passwordLabel), 'هذا الحقل مطلوب');
    verifyNever(
      () => harness.repository.updateProfile(
        fullName: any(named: 'fullName'),
        email: any(named: 'email'),
        currentPassword: any(named: 'currentPassword'),
      ),
    );
  });

  testWidgets('a wrong password shows under the password field and clears it', (tester) async {
    final harness = await _openEditProfile(tester);
    _stubUpdate(
      harness,
      const Result.failure(
        ValidationFailure(
          code: ApiErrorCodes.validationError,
          fieldErrors: {
            'currentPassword': ['Current password is incorrect.'],
          },
        ),
      ),
    );

    await tester.enterText(_field(_nameLabel), 'New Name');
    await tester.enterText(_field(_passwordLabel), 'Wrong1234');
    await _tapSave(tester);

    expect(_errorOf(tester, _passwordLabel), 'كلمة المرور الحالية غير صحيحة');
    expect(find.byType(EditProfileScreen), findsOneWidget);
    final password = tester.widget<TextField>(_field(_passwordLabel));
    expect(password.controller!.text, isEmpty);
  });

  testWidgets('an email used by another account shows under the email field', (tester) async {
    final harness = await _openEditProfile(tester);
    _stubUpdate(harness, const Result.failure(ValidationFailure(code: ApiErrorCodes.emailAlreadyRegistered)));

    await tester.enterText(_field(_emailLabel), 'taken@aqd.test');
    await tester.enterText(_field(_passwordLabel), 'Password123');
    await _tapSave(tester);

    expect(_errorOf(tester, _emailLabel), isNotNull);
    expect(find.byType(EditProfileScreen), findsOneWidget);
  });

  testWidgets('a valid save sends the password and closes the screen', (tester) async {
    final harness = await _openEditProfile(tester);
    _stubUpdate(harness, Result.success(testClient.copyWith(fullName: 'New Name')));

    await tester.enterText(_field(_nameLabel), '  New Name  ');
    await tester.enterText(_field(_passwordLabel), 'Password123');
    await _tapSave(tester);

    verify(
      () => harness.repository.updateProfile(fullName: 'New Name', email: testClient.email, currentPassword: 'Password123'),
    ).called(1);
    expect(find.byType(EditProfileScreen), findsNothing);
  });

  testWidgets('a verified lawyer is warned before renaming', (tester) async {
    await _openEditProfile(tester, user: testLawyer, path: RoutePaths.lawyerAccountEdit);
    const warning = 'تغيير اسمك سيعيد حسابك إلى المراجعة، ولن يظهر في قائمة المحامين حتى تتم الموافقة عليه من جديد.';
    expect(find.text(warning), findsNothing);

    await tester.enterText(_field(_nameLabel), 'Another Name');
    await tester.pump();

    expect(find.text(warning), findsOneWidget);
  });
}
