import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:aqd_ionbit/features/auth/domain/entities/auth_user.dart';
import 'package:aqd_ionbit/features/billing/presentation/screens/subscription_plans_screen.dart';
import 'package:aqd_ionbit/features/profile/presentation/screens/account_screen.dart';
import 'package:aqd_ionbit/features/profile/presentation/screens/payment_methods_screen.dart';

import '../../../support/role_test_harness.dart';

Future<void> _openAccount(WidgetTester tester, {required AuthUser user}) async {
  await pumpAuthenticatedApp(tester, user: user);
  await tester.tap(find.text('حسابي'));
  await tester.pumpAndSettle();
  expect(find.byType(AccountScreen), findsOneWidget);
}

void main() {
  testWidgets('the header shows the phone as people type it, its verified state and the email', (tester) async {
    await _openAccount(tester, user: testClient);

    expect(find.text('0791234567'), findsOneWidget);
    expect(find.text('موثّق'), findsOneWidget);
    expect(find.text('client@aqd.test'), findsOneWidget);
  });

  testWidgets('an unverified phone is flagged in the header', (tester) async {
    await _openAccount(tester, user: testClient.copyWith(phoneVerified: false));

    expect(find.text('غير موثّق'), findsOneWidget);
  });

  testWidgets('rows without a backend are tagged coming soon and open nothing', (tester) async {
    await _openAccount(tester, user: testClient);

    // Subscriptions, payment methods, saved signature, documents, invoices.
    expect(find.text('قريباً'), findsNWidgets(5));

    await tester.tap(find.text('طرق الدفع'));
    await tester.pumpAndSettle();
    expect(find.byType(PaymentMethodsScreen), findsNothing);

    await tester.tap(find.text('الاشتراكات والباقات'));
    await tester.pumpAndSettle();
    expect(find.byType(SubscriptionPlansScreen), findsNothing);
    expect(find.byType(AccountScreen), findsOneWidget);
  });

  testWidgets('no mock-backed figures: no documents stat and no plan badge', (tester) async {
    await _openAccount(tester, user: testClient);

    expect(find.text('استشارة'), findsOneWidget);
    expect(find.text('عقد'), findsOneWidget);
    expect(find.text('مستند'), findsNothing);
    expect(find.byIcon(Icons.star), findsNothing);
  });
}
