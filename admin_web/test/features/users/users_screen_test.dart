import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:aqd_admin/core/errors/failure.dart';
import 'package:aqd_admin/core/utils/file_saver.dart';
import 'package:aqd_admin/features/users/domain/managed_user.dart';
import 'package:aqd_admin/features/users/presentation/providers/users_providers.dart';
import 'package:aqd_admin/features/users/presentation/screens/users_screen.dart';

import '../../support/fakes.dart';
import '../../support/test_app.dart';

Future<void> pumpUsers(WidgetTester tester, FakeUsersRepository repo, {FileSaver? saver}) async {
  tester.view.physicalSize = const Size(1700, 1000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    testApp(
      const Scaffold(body: Padding(padding: EdgeInsets.all(16), child: UsersScreen())),
      overrides: [
        usersRepositoryProvider.overrideWithValue(repo),
        if (saver != null) fileSaverProvider.overrideWithValue(saver),
      ],
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('shows the users with role and status labels', (tester) async {
    final repo = FakeUsersRepository(users: [
      user('1', name: 'Layla Haddad', role: 'lawyer'),
      user('2', name: 'Omar Saleh', status: 'suspended'),
      user('3', name: 'Gone Person', deletedAt: DateTime.utc(2026, 2)),
    ]);
    await pumpUsers(tester, repo);

    expect(find.text('Layla Haddad'), findsOneWidget);
    expect(find.text('Lawyer'), findsWidgets);
    expect(find.text('Suspended'), findsWidgets);
    expect(find.text('Removed'), findsWidgets);
    expect(find.text('Total: 3'), findsOneWidget);
    expect(repo.queries.single.deleted, 'exclude');
  });

  testWidgets('searching sends the text to the server after a pause and returns to page 1', (tester) async {
    final repo = FakeUsersRepository();
    await pumpUsers(tester, repo);

    await tester.enterText(find.byType(TextField).first, 'layla');
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    expect(repo.queries.last.search, 'layla');
    expect(repo.queries.last.page, 1);
  });

  testWidgets('filters by role and status, and can clear them', (tester) async {
    final repo = FakeUsersRepository();
    await pumpUsers(tester, repo);

    await tester.tap(find.widgetWithText(DropdownButtonFormField<String?>, 'Role'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lawyer').last);
    await tester.pumpAndSettle();
    expect(repo.queries.last.role, 'lawyer');

    expect(find.text('Clear filters'), findsOneWidget);
    await tester.tap(find.text('Clear filters'));
    await tester.pumpAndSettle();
    expect(repo.queries.last.role, isNull);
    expect(find.text('Clear filters'), findsNothing);
  });

  testWidgets('sorting by a column asks the server to sort', (tester) async {
    final repo = FakeUsersRepository();
    await pumpUsers(tester, repo);

    await tester.tap(find.text('Name'));
    await tester.pumpAndSettle();

    expect(repo.queries.last.sort, 'fullName');
  });

  testWidgets('shows an error with retry when the list fails', (tester) async {
    final repo = FakeUsersRepository(failWith: const NetworkFailure());
    await pumpUsers(tester, repo);

    expect(find.textContaining('Cannot reach the server'), findsOneWidget);
    repo.failWith = null;
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();
    expect(find.text('User 1'), findsOneWidget);
  });

  testWidgets('bulk suspend: asks for a reason, sends the selected ids and reports the result', (tester) async {
    final repo = FakeUsersRepository()..bulkResult = const BulkResult(succeeded: ['1'], skipped: [BulkSkip(id: '2', reason: 'Admin accounts')]);
    await pumpUsers(tester, repo);

    await tester.tap(find.byType(Checkbox).at(1));
    await tester.pumpAndSettle(); // the bulk bar replaces the filters: rows move
    await tester.tap(find.byType(Checkbox).at(2));
    await tester.pumpAndSettle();
    expect(find.text('2 selected'), findsOneWidget);

    await tester.tap(find.text('Suspend selected'));
    await tester.pumpAndSettle();

    // Too short a reason is refused.
    await tester.enterText(find.byType(TextFormField), 'x');
    await tester.tap(find.descendant(of: find.byType(AlertDialog), matching: find.byType(FilledButton)));
    await tester.pumpAndSettle();
    expect(find.text('Give a reason of at least 3 characters'), findsOneWidget);
    expect(repo.lastBulk, isNull);

    await tester.enterText(find.byType(TextFormField), 'spam accounts');
    await tester.tap(find.descendant(of: find.byType(AlertDialog), matching: find.byType(FilledButton)));
    await tester.pumpAndSettle();

    expect(repo.lastBulk, {'action': 'suspend', 'ids': ['1', '2'], 'reason': 'spam accounts'});
    expect(find.text('Done: 1, skipped: 1'), findsOneWidget);
    expect(find.text('2 selected'), findsNothing);
  });

  testWidgets('bulk reactivate needs a confirmation and sends no reason', (tester) async {
    final repo = FakeUsersRepository();
    await pumpUsers(tester, repo);

    await tester.tap(find.byType(Checkbox).at(1));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Reactivate selected'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Confirm'));
    await tester.pumpAndSettle();

    expect(repo.lastBulk, {'action': 'activate', 'ids': ['1'], 'reason': null});
  });

  testWidgets('export asks first, then hands the CSV to the browser', (tester) async {
    final repo = FakeUsersRepository();
    String? savedName;
    Uint8List? savedBytes;
    await pumpUsers(tester, repo, saver: (name, bytes, mime) async {
      savedName = name;
      savedBytes = bytes;
    });

    await tester.tap(find.text('Export CSV'));
    await tester.pumpAndSettle();
    expect(find.text('Export personal data'), findsOneWidget);
    expect(repo.calls, isEmpty);

    await tester.tap(find.widgetWithText(FilledButton, 'Export CSV'));
    await tester.pumpAndSettle();

    expect(repo.calls, ['export']);
    expect(savedName, 'users.csv');
    expect(String.fromCharCodes(savedBytes!), startsWith('id,name'));
    expect(find.text('File downloaded'), findsOneWidget);
  });

  testWidgets('cancelling the export does nothing', (tester) async {
    final repo = FakeUsersRepository();
    await pumpUsers(tester, repo);

    await tester.tap(find.text('Export CSV'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(repo.calls, isEmpty);
  });
}
