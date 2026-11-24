import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:aqd_admin/features/users/domain/managed_user.dart';
import 'package:aqd_admin/features/users/presentation/providers/users_providers.dart';
import 'package:aqd_admin/features/users/presentation/screens/user_detail_screen.dart';

import '../../support/fakes.dart';
import '../../support/test_app.dart';

Future<void> pumpDetail(WidgetTester tester, FakeUsersRepository repo) async {
  tester.view.physicalSize = const Size(1500, 1200);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    testApp(
      const Scaffold(body: Padding(padding: EdgeInsets.all(16), child: UserDetailScreen(userId: '1'))),
      overrides: [usersRepositoryProvider.overrideWithValue(repo)],
    ),
  );
  await tester.pumpAndSettle();
}

final _session = SessionInfo(id: 's1', createdAt: DateTime.utc(2026, 3), deviceLabel: 'Chrome on Windows', ipAddress: '1.2.3.4');

void main() {
  testWidgets('an active user can be suspended (with a reason), reset, signed out or removed', (tester) async {
    final repo = FakeUsersRepository(detail: detailOf('1', sessions: [_session]));
    await pumpDetail(tester, repo);

    expect(find.text('Suspend account'), findsOneWidget);
    expect(find.text('Send password-reset code'), findsOneWidget);
    expect(find.text('Sign out everywhere'), findsOneWidget);
    expect(find.text('Remove account'), findsOneWidget);
    expect(find.text('Reactivate account'), findsNothing);
    expect(find.text('Restore account'), findsNothing);
    expect(find.text('Chrome on Windows'), findsOneWidget);

    await tester.tap(find.text('Suspend account'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), 'abusive behaviour');
    await tester.tap(find.widgetWithText(FilledButton, 'Suspend account'));
    await tester.pumpAndSettle();

    expect(repo.calls, ['suspend:1:abusive behaviour']);
    expect(find.text('Done'), findsOneWidget);
  });

  testWidgets('a suspended user can be reactivated, not suspended again', (tester) async {
    final repo = FakeUsersRepository(detail: detailOf('1', status: 'suspended'));
    await pumpDetail(tester, repo);

    expect(find.text('Suspend account'), findsNothing);
    expect(find.text('Send password-reset code'), findsNothing);
    await tester.tap(find.text('Reactivate account'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Confirm'));
    await tester.pumpAndSettle();

    expect(repo.calls, ['activate:1']);
  });

  testWidgets('removing needs a reason AND the typed confirmation word', (tester) async {
    final repo = FakeUsersRepository(detail: detailOf('1'));
    await pumpDetail(tester, repo);

    await tester.tap(find.text('Remove account'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), 'user asked to leave');
    await tester.tap(find.widgetWithText(FilledButton, 'Remove account'));
    await tester.pumpAndSettle();

    final confirm = find.widgetWithText(FilledButton, 'Remove account');
    expect(tester.widget<FilledButton>(confirm).onPressed, isNull);
    expect(repo.calls, isEmpty);

    await tester.enterText(find.byType(TextField), 'DELETE');
    await tester.pump();
    await tester.tap(confirm);
    await tester.pumpAndSettle();

    expect(repo.calls, ['delete:1:user asked to leave']);
  });

  testWidgets('a removed user can only be restored', (tester) async {
    final repo = FakeUsersRepository(detail: detailOf('1', deletedAt: DateTime.utc(2026, 4)));
    await pumpDetail(tester, repo);

    expect(find.text('Remove account'), findsNothing);
    expect(find.text('Suspend account'), findsNothing);
    await tester.tap(find.text('Restore account'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Confirm'));
    await tester.pumpAndSettle();

    expect(repo.calls, ['restore:1']);
  });

  testWidgets('an admin account has no actions here', (tester) async {
    final repo = FakeUsersRepository(detail: detailOf('1', role: 'admin'));
    await pumpDetail(tester, repo);

    expect(find.text('Admin accounts are managed from Settings, not here.'), findsOneWidget);
    expect(find.text('Suspend account'), findsNothing);
    expect(find.text('Remove account'), findsNothing);
  });

  testWidgets('cancelling a confirmation changes nothing', (tester) async {
    final repo = FakeUsersRepository(detail: detailOf('1', sessions: [_session]));
    await pumpDetail(tester, repo);

    await tester.tap(find.text('Sign out everywhere'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(repo.calls, isEmpty);
  });
}
