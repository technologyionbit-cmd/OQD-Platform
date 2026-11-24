import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:aqd_admin/features/audit/domain/audit_entry.dart';
import 'package:aqd_admin/features/audit/presentation/audit_screen.dart';
import 'package:aqd_admin/features/audit/presentation/providers/audit_providers.dart';

import '../../support/fakes.dart';
import '../../support/test_app.dart';

final _entries = [
  AuditEntry(
    id: 'a1',
    action: 'user.suspend',
    method: 'POST',
    path: '/v1/admin/users/:id/suspend',
    statusCode: 200,
    createdAt: DateTime.utc(2026, 11, 1, 10),
    entityType: 'user',
    entityId: '3f2b6c1e-8a4d-4c1b-9e57-0d2f6a1b7c33',
    ipAddress: '1.2.3.4',
    actor: const AuditActor(id: 'x', fullName: 'Ibrahim Admin', email: 'i@a.com'),
  ),
  AuditEntry(
    id: 'a2',
    action: 'user.activate',
    method: 'POST',
    path: '/v1/admin/users/:id/activate',
    statusCode: 409,
    createdAt: DateTime.utc(2026, 11, 1, 11),
  ),
];

Future<FakeAuditRepository> pumpAudit(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1700, 1000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final repo = FakeAuditRepository(
    entries: _entries,
    detail: AuditDetail(
      id: 'a1',
      action: 'user.suspend',
      method: 'POST',
      path: '/v1/admin/users/:id/suspend',
      statusCode: 200,
      createdAt: DateTime.utc(2026, 11, 1, 10),
      before: {'status': 'active'},
      after: {'status': 'suspended', 'suspendedReason': 'spam'},
      meta: {'body': {'reason': 'spam', 'password': '[redacted]'}},
    ),
  );
  await tester.pumpWidget(
    testApp(
      const Scaffold(body: Padding(padding: EdgeInsets.all(16), child: AuditScreen())),
      overrides: [auditRepositoryProvider.overrideWithValue(repo)],
    ),
  );
  await tester.pumpAndSettle();
  return repo;
}

void main() {
  testWidgets('lists who did what, with success and failure marked', (tester) async {
    await pumpAudit(tester);

    expect(find.text('Ibrahim Admin'), findsOneWidget);
    expect(find.text('user.suspend'), findsOneWidget);
    expect(find.text('200'), findsOneWidget);
    expect(find.text('409'), findsOneWidget);
    expect(find.text('Total: 2'), findsOneWidget);
  });

  testWidgets('filtering by outcome asks the server', (tester) async {
    final repo = await pumpAudit(tester);

    await tester.tap(find.widgetWithText(DropdownButtonFormField<String?>, 'Outcome'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Failed').last);
    await tester.pumpAndSettle();

    expect(repo.queries.last.outcome, 'failure');
    expect(repo.queries.last.page, 1);
  });

  testWidgets('opening a row shows the before/after state', (tester) async {
    await pumpAudit(tester);

    await tester.tap(find.text('Ibrahim Admin'));
    await tester.pumpAndSettle();

    expect(find.text('Audit entry'), findsOneWidget);
    expect(find.textContaining('"status": "suspended"'), findsOneWidget);
    expect(find.textContaining('"status": "active"'), findsOneWidget);
    expect(find.textContaining('[redacted]'), findsOneWidget);

    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();
    expect(find.text('Audit entry'), findsNothing);
  });

  testWidgets('sort toggles oldest first', (tester) async {
    final repo = await pumpAudit(tester);

    await tester.tap(find.text('When'));
    await tester.pumpAndSettle();

    expect(repo.queries.last.ascending, isTrue);
  });
}
