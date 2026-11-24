import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:aqd_admin/core/errors/failure.dart';
import 'package:aqd_admin/features/auth/domain/admin_user.dart';
import 'package:aqd_admin/features/auth/domain/auth_repository.dart';
import 'package:aqd_admin/features/auth/presentation/providers/auth_controller.dart';
import 'package:aqd_admin/features/auth/presentation/screens/login_screen.dart';

import '../../support/test_app.dart';

class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({this.onLogin});

  Future<AdminUser> Function()? onLogin;
  int loginCalls = 0;

  @override
  Future<AdminUser> login({required String phone, required String password}) {
    loginCalls++;
    return onLogin!();
  }

  @override
  Future<AdminUser?> restoreSession() async => null;

  @override
  Future<void> logout() async {}
}

const _admin = AdminUser(id: '1', fullName: 'Aqd Admin', email: 'a@a.com', role: 'admin');

Future<FakeAuthRepository> pumpLogin(WidgetTester tester, Future<AdminUser> Function() onLogin) async {
  final repo = FakeAuthRepository(onLogin: onLogin);
  await tester.pumpWidget(testApp(const LoginScreen(), overrides: [authRepositoryProvider.overrideWithValue(repo)]));
  await tester.pumpAndSettle();
  return repo;
}

Future<void> fillAndSubmit(WidgetTester tester, {String phone = '0791234567', String password = 'Password123'}) async {
  await tester.enterText(find.byType(TextFormField).at(0), phone);
  await tester.enterText(find.byType(TextFormField).at(1), password);
  await tester.tap(find.byType(FilledButton));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('validates the fields before calling the server', (tester) async {
    final repo = await pumpLogin(tester, () async => _admin);

    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();
    expect(find.text('This field is required'), findsNWidgets(2));

    await fillAndSubmit(tester, phone: '12345');
    expect(find.text('Enter a valid Jordanian mobile number'), findsOneWidget);
    expect(repo.loginCalls, 0);
  });

  testWidgets('a non-admin gets the access-denied card, and can go back', (tester) async {
    await pumpLogin(tester, () async => throw const ForbiddenFailure(code: 'FORBIDDEN'));

    await fillAndSubmit(tester);

    expect(find.text('You do not have access to this panel'), findsOneWidget);
    expect(find.byType(TextFormField), findsNothing);

    await tester.tap(find.text('Back to sign-in'));
    await tester.pumpAndSettle();
    expect(find.byType(TextFormField), findsNWidgets(2));
  });

  testWidgets('wrong credentials show an inline error and keep the form', (tester) async {
    await pumpLogin(tester, () async => throw const UnauthorizedFailure());

    await fillAndSubmit(tester);

    expect(find.text('Wrong mobile number or password.'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(2));
  });

  testWidgets('an inactive account is told so, not shown as access denied', (tester) async {
    await pumpLogin(tester, () async => throw const ForbiddenFailure(code: ApiErrorCodes.accountInactive));

    await fillAndSubmit(tester);

    expect(find.text('This account is not active.'), findsOneWidget);
    expect(find.text('You do not have access to this panel'), findsNothing);
  });

  testWidgets('a network failure shows the localized message', (tester) async {
    await pumpLogin(tester, () async => throw const NetworkFailure());

    await fillAndSubmit(tester);

    expect(find.textContaining('Cannot reach the server'), findsOneWidget);
  });

  testWidgets('renders right-to-left in Arabic', (tester) async {
    final repo = FakeAuthRepository(onLogin: () async => _admin);
    await tester.pumpWidget(
      testApp(const LoginScreen(), locale: const Locale('ar'), overrides: [authRepositoryProvider.overrideWithValue(repo)]),
    );
    await tester.pumpAndSettle();

    expect(find.text('تسجيل دخول الأدمن'), findsOneWidget);
    expect(Directionality.of(tester.element(find.byType(LoginScreen))), TextDirection.rtl);
  });
}
