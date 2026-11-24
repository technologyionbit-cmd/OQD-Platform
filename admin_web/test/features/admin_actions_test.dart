import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

import 'package:aqd_admin/core/config/app_config.dart';
import 'package:aqd_admin/core/network/api_client.dart';
import 'package:aqd_admin/core/network/session_store.dart';
import 'package:aqd_admin/core/providers/core_providers.dart';
import 'package:aqd_admin/core/utils/file_picker.dart';
import 'package:aqd_admin/features/auth/domain/admin_user.dart';
import 'package:aqd_admin/features/auth/presentation/providers/auth_controller.dart';
import 'package:aqd_admin/core/routing/app_router.dart';
import 'package:aqd_admin/core/routing/nav_items.dart';
import 'package:aqd_admin/core/routing/route_paths.dart';
import 'package:aqd_admin/features/admins/presentation/admins_screen.dart';
import 'package:aqd_admin/features/consultations/presentation/consultations_screen.dart';
import 'package:aqd_admin/features/contract_templates/presentation/contract_template_editor_screen.dart';
import 'package:aqd_admin/features/gov_procedures/presentation/gov_procedure_editor_screen.dart';
import 'package:aqd_admin/features/notifications/presentation/send_notification_dialog.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' show AsyncData;

import '../support/test_app.dart';

class _FullAccessAdmin extends AuthController {
  @override
  Future<AdminUser?> build() async => const AdminUser(id: '1', fullName: 'Admin', email: 'a@a.com', role: 'admin', fullAccess: true);
}

/// An admin who may only look: no permission to change anything.
class _ViewerAdmin extends AuthController {
  @override
  Future<AdminUser?> build() async => const AdminUser(id: '2', fullName: 'Viewer', email: 'v@a.com', role: 'admin', permissions: ['consultations.view', 'govProcedures.view']);
}

/// A server stand-in: answers by `METHOD path` and records every call.
class _FakeServer implements HttpClientAdapter {
  _FakeServer(this.routes);

  final Map<String, Object?> routes;
  final List<({String method, String path, Object? body})> calls = [];

  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    calls.add((method: options.method, path: options.path, body: options.data));
    final key = '${options.method} ${options.path}';
    final body = routes[key];
    if (body == null) {
      return ResponseBody.fromString(jsonEncode({'error': {'message': 'no route $key', 'code': 'NOT_FOUND'}}), 404, headers: {Headers.contentTypeHeader: ['application/json']});
    }
    final status = body is int ? body : 200;
    final json = body is int ? <String, Object?>{'data': <String, Object?>{}} : body;
    return ResponseBody.fromString(jsonEncode(json), status, headers: {Headers.contentTypeHeader: ['application/json']});
  }

  @override
  void close({bool force = false}) {}
}

Override _api(_FakeServer server) => apiClientProvider.overrideWithValue(
      ApiClient(config: const AppConfig(apiBaseUrl: 'http://test'), session: SessionStore(), dio: Dio()..httpClientAdapter = server),
    );

Future<void> _pump(WidgetTester tester, Widget child, _FakeServer server, {bool viewer = false, PickedFile? file}) async {
  tester.view.physicalSize = const Size(1600, 1400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(testApp(Scaffold(body: Padding(padding: const EdgeInsets.all(16), child: child)), overrides: [_api(server), authControllerProvider.overrideWith(viewer ? _ViewerAdmin.new : _FullAccessAdmin.new), if (file != null) filePickerProvider.overrideWithValue(({required String accept}) async => file)]));
  await tester.pumpAndSettle();
}

Map<String, String> _loc(String ar, String en) => {'ar': ar, 'en': en};

void main() {
  testWidgets('gov procedure editor keeps ids of existing rows and saves the edit', (tester) async {
    final server = _FakeServer({
      'GET /admin/gov-procedures/p1': {
        'data': {
          'id': 'p1',
          'type': 'companyRegistration',
          'accessType': 'guide',
          'durationLabel': _loc('٧ أيام', '7 days'),
          'requiredDocuments': [
            {'id': 'd1', 'title': _loc('هوية', 'ID')},
          ],
          'steps': [
            {'id': 's1', 'title': _loc('جهّز', 'Prepare'), 'description': _loc('وصف', 'Collect papers')},
          ],
        },
      },
      'PUT /admin/gov-procedures/p1': {'data': <String, Object?>{}},
    });
    await _pump(tester, const GovProcedureEditorScreen(procedureId: 'p1'), server);

    expect(find.text('Company registration'), findsOneWidget);
    await tester.enterText(find.widgetWithText(TextFormField, 'Title (EN)').first, 'National ID');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    final put = server.calls.firstWhere((c) => c.method == 'PUT');
    final body = put.body! as Map<String, dynamic>;
    expect(body['accessType'], 'guide');
    expect((body['requiredDocuments'] as List).single, {'id': 'd1', 'title': _loc('هوية', 'National ID')});
    expect(((body['steps'] as List).single as Map)['id'], 's1');
  });

  testWidgets('gov procedure editor will not save an empty text', (tester) async {
    final server = _FakeServer({
      'GET /admin/gov-procedures/p1': {
        'data': {
          'id': 'p1',
          'type': 'lawsuitFiling',
          'accessType': 'directLink',
          'durationLabel': _loc('يوم', '1 day'),
          'requiredDocuments': <Object>[],
          'steps': <Object>[],
        },
      },
    });
    await _pump(tester, const GovProcedureEditorScreen(procedureId: 'p1'), server);
    await tester.enterText(find.widgetWithText(TextFormField, 'Duration (EN)'), '');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('This field is required'), findsOneWidget);
    expect(server.calls.where((c) => c.method == 'PUT'), isEmpty);
  });

  testWidgets('a new contract template starts with the two party fields and posts the form', (tester) async {
    final server = _FakeServer({'POST /admin/contract-templates': {'data': <String, Object?>{}}, 'GET /admin/contract-templates': {'data': <Object>[]}});
    await _pump(tester, const ContractTemplateEditorScreen(), server);

    await tester.enterText(find.widgetWithText(TextFormField, 'Key'), 'loan');
    await tester.enterText(find.widgetWithText(TextFormField, 'Title (AR)').first, 'عقد قرض');
    await tester.enterText(find.widgetWithText(TextFormField, 'Title (EN)').first, 'Loan');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    final post = server.calls.firstWhere((c) => c.method == 'POST');
    final body = post.body! as Map<String, dynamic>;
    expect(body['key'], 'loan');
    expect(body['title'], _loc('عقد قرض', 'Loan'));
    expect([for (final f in body['fields'] as List) (f as Map)['id']], ['partyA', 'partyB']);
  });

  testWidgets('a bad template key is stopped before it is sent', (tester) async {
    final server = _FakeServer({});
    await _pump(tester, const ContractTemplateEditorScreen(), server);
    await tester.enterText(find.widgetWithText(TextFormField, 'Key'), 'Bad Key!');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(server.calls, isEmpty);
  });

  Map<String, Object?> consultation({required String status, bool cancel = false, bool complete = false}) => {
        'data': {
          'id': 'c1',
          'type': 'video',
          'status': status,
          'scheduledAt': '2026-12-01T10:00:00.000Z',
          'price': 50,
          'notes': '',
          'cancellationReason': null,
          'client': {'name': 'Sara', 'email': 's@x.com', 'phone': null},
          'lawyer': {'name': 'Omar', 'email': 'o@x.com', 'phone': null},
          'room': null,
          'canCancel': cancel,
          'canComplete': complete,
        },
      };

  testWidgets('consultation dialog cancels with a reason', (tester) async {
    final server = _FakeServer({
      'GET /admin/consultations/c1': consultation(status: 'confirmed', cancel: true, complete: true),
      'POST /admin/consultations/c1/cancel': 204,
    });
    await _pump(tester, const ConsultationDialog(id: 'c1'), server);

    expect(find.text('Cancel consultation'), findsOneWidget);
    expect(find.text('Mark completed'), findsOneWidget);
    await tester.tap(find.text('Cancel consultation'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextFormField, 'Reason'), 'duplicate booking');
    await tester.tap(find.widgetWithText(FilledButton, 'Cancel consultation').last);
    await tester.pumpAndSettle();

    final post = server.calls.firstWhere((c) => c.method == 'POST');
    expect(post.path, '/admin/consultations/c1/cancel');
    expect(post.body, {'reason': 'duplicate booking'});
  });

  testWidgets('consultation dialog offers no action for a finished consultation', (tester) async {
    final server = _FakeServer({'GET /admin/consultations/c1': consultation(status: 'completed')});
    await _pump(tester, const ConsultationDialog(id: 'c1'), server);
    expect(find.text('Cancel consultation'), findsNothing);
    expect(find.text('Mark completed'), findsNothing);
  });

  testWidgets('a view-only admin sees the consultation but no action buttons', (tester) async {
    final server = _FakeServer({'GET /admin/consultations/c1': consultation(status: 'confirmed', cancel: true, complete: true)});
    await _pump(tester, const ConsultationDialog(id: 'c1'), server, viewer: true);
    expect(find.text('Sara  ·  s@x.com  ·  -'), findsOneWidget);
    expect(find.text('Cancel consultation'), findsNothing);
    expect(find.text('Mark completed'), findsNothing);
  });

  testWidgets('a view-only admin cannot save a procedure', (tester) async {
    final server = _FakeServer({
      'GET /admin/gov-procedures/p1': {
        'data': {'id': 'p1', 'type': 'lawsuitFiling', 'accessType': 'guide', 'durationLabel': _loc('يوم', '1 day'), 'requiredDocuments': <Object>[], 'steps': <Object>[]},
      },
    });
    await _pump(tester, const GovProcedureEditorScreen(procedureId: 'p1'), server, viewer: true);
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(server.calls.where((c) => c.method == 'PUT'), isEmpty);
  });


  Map<String, Object?> procedure({String? pdf}) => {
        'data': {
          'id': 'p1',
          'type': 'lawsuitFiling',
          'accessType': 'guide',
          'hasPdf': pdf != null,
          'pdfFileName': pdf,
          'durationLabel': _loc('يوم', '1 day'),
          'requiredDocuments': <Object>[],
          'steps': <Object>[],
        },
      };

  testWidgets('uploading an official PDF sends it as a file field', (tester) async {
    final server = _FakeServer({'GET /admin/gov-procedures/p1': procedure(), 'POST /admin/gov-procedures/p1/pdf': {'data': <String, Object?>{}}});
    final file = PickedFile('form.pdf', Uint8List.fromList(utf8.encode('%PDF-1.4 hello')));
    await _pump(tester, const GovProcedureEditorScreen(procedureId: 'p1'), server, file: file);

    expect(find.text('No file uploaded'), findsOneWidget);
    await tester.tap(find.text('Upload PDF'));
    await tester.pumpAndSettle();

    final post = server.calls.firstWhere((c) => c.method == 'POST');
    expect(post.path, '/admin/gov-procedures/p1/pdf');
    final form = post.body! as FormData;
    expect(form.files.single.key, 'file');
    expect(form.files.single.value.filename, 'form.pdf');
  });

  testWidgets('an existing PDF shows its name and can be removed after confirming', (tester) async {
    final server = _FakeServer({'GET /admin/gov-procedures/p1': procedure(pdf: 'official.pdf'), 'DELETE /admin/gov-procedures/p1/pdf': 204});
    await _pump(tester, const GovProcedureEditorScreen(procedureId: 'p1'), server);

    expect(find.text('official.pdf'), findsOneWidget);
    await tester.tap(find.byTooltip('Remove'));
    await tester.pumpAndSettle();
    expect(server.calls.where((c) => c.method == 'DELETE'), isEmpty);
    await tester.tap(find.widgetWithText(FilledButton, 'Remove'));
    await tester.pumpAndSettle();
    expect(server.calls.where((c) => c.method == 'DELETE').single.path, '/admin/gov-procedures/p1/pdf');
  });

  testWidgets('a view-only admin cannot upload or remove the PDF', (tester) async {
    final server = _FakeServer({'GET /admin/gov-procedures/p1': procedure(pdf: 'official.pdf')});
    await _pump(tester, const GovProcedureEditorScreen(procedureId: 'p1'), server, viewer: true);
    expect(find.text('official.pdf'), findsOneWidget);
    expect(find.text('Replace'), findsNothing);
    expect(find.byTooltip('Remove'), findsNothing);
  });

  testWidgets('sending a message to everyone asks first, then posts both languages', (tester) async {
    final server = _FakeServer({'POST /admin/notifications/send': {'data': {'sent': 3}}});
    await _pump(
      tester,
      Builder(builder: (context) => TextButton(onPressed: () => showSendNotificationDialog(context), child: const Text('open'))),
      server,
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextFormField, 'Title (AR)'), 'عنوان');
    await tester.enterText(find.widgetWithText(TextFormField, 'Title (EN)'), 'Title');
    await tester.enterText(find.widgetWithText(TextFormField, 'Message (AR)'), 'نص');
    await tester.enterText(find.widgetWithText(TextFormField, 'Message (EN)'), 'Body');
    await tester.tap(find.widgetWithText(FilledButton, 'Send'));
    await tester.pumpAndSettle();

    expect(find.text('Send this message?'), findsOneWidget);
    expect(server.calls.where((c) => c.method == 'POST'), isEmpty);
    await tester.tap(find.widgetWithText(FilledButton, 'Send').last);
    await tester.pumpAndSettle();

    final post = server.calls.firstWhere((c) => c.method == 'POST');
    expect(post.body, {'audience': 'all', 'titleAr': 'عنوان', 'titleEn': 'Title', 'bodyAr': 'نص', 'bodyEn': 'Body'});
  });

  group('permissions', () {
    const viewer = AdminUser(id: '2', fullName: 'V', email: 'v@a.com', role: 'admin', permissions: ['consultations.view', 'lawyers.manage']);
    const full = AdminUser(id: '1', fullName: 'F', email: 'f@a.com', role: 'admin', fullAccess: true);

    test('the sidebar shows only what the admin may open, settings always', () {
      final paths = [for (final i in navItemsFor(viewer)) i.path];
      expect(paths, [RoutePaths.lawyerVerifications, RoutePaths.lawyers, RoutePaths.consultations, RoutePaths.settings]);
      expect(navItemsFor(full).map((i) => i.path), contains(RoutePaths.admins));
      expect(navItemsFor(viewer).map((i) => i.path), isNot(contains(RoutePaths.admins)));
    });

    test('manage includes view, view does not include manage', () {
      expect(viewer.can('lawyers'), isTrue);
      expect(viewer.can('lawyers', manage: true), isTrue);
      expect(viewer.can('consultations'), isTrue);
      expect(viewer.can('consultations', manage: true), isFalse);
      expect(viewer.can('contracts'), isFalse);
    });

    test('opening a page the admin may not use goes to their first allowed page', () {
      String? go(String location) => redirectFor(
            auth: const AsyncData<Object?>('x'),
            isAdmin: true,
            location: location,
            homePath: RoutePaths.lawyerVerifications,
            canOpen: (l) {
              final item = navItemFor(l);
              return item == null || item.allowedFor(viewer);
            },
          );
      expect(go(RoutePaths.contracts), RoutePaths.lawyerVerifications);
      expect(go(RoutePaths.admins), RoutePaths.lawyerVerifications);
      expect(go(RoutePaths.consultations), isNull);
      expect(go(RoutePaths.login), RoutePaths.lawyerVerifications);
    });
  });

  testWidgets('adding an admin posts the chosen permissions', (tester) async {
    final server = _FakeServer({'POST /admin/admins': {'data': <String, Object?>{}}, 'GET /admin/admins': {'data': <Object>[]}});
    await _pump(tester, const AdminFormDialog(), server);

    await tester.enterText(find.widgetWithText(TextFormField, 'Name'), 'Second Admin');
    await tester.enterText(find.widgetWithText(TextFormField, 'Email'), 's@x.com');
    await tester.enterText(find.widgetWithText(TextFormField, 'Mobile'), '0791234567');
    await tester.enterText(find.widgetWithText(TextFormField, 'Temporary password'), 'Password123');
    // Contracts -> Manage, Users -> View
    final rows = find.ancestor(of: find.text('Contracts'), matching: find.byType(Row)).first;
    await tester.tap(find.descendant(of: rows, matching: find.text('Manage')));
    final usersRow = find.ancestor(of: find.text('Users'), matching: find.byType(Row)).first;
    await tester.tap(find.descendant(of: usersRow, matching: find.text('View')));
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Add admin'));
    await tester.pumpAndSettle();

    final post = server.calls.firstWhere((c) => c.method == 'POST');
    final body = post.body! as Map<String, dynamic>;
    expect(body['fullName'], 'Second Admin');
    expect(body['phone'], '0791234567');
    expect(body['fullAccess'], false);
    expect(body['permissions'], containsAll(['contracts.view', 'contracts.manage', 'users.view']));
    expect(body['permissions'], isNot(contains('users.manage')));
  });

  testWidgets('a weak password is stopped before it is sent', (tester) async {
    final server = _FakeServer({});
    await _pump(tester, const AdminFormDialog(), server);
    await tester.enterText(find.widgetWithText(TextFormField, 'Name'), 'X Y');
    await tester.enterText(find.widgetWithText(TextFormField, 'Email'), 'x@y.com');
    await tester.enterText(find.widgetWithText(TextFormField, 'Mobile'), '0791234567');
    await tester.enterText(find.widgetWithText(TextFormField, 'Temporary password'), 'short');
    await tester.tap(find.widgetWithText(FilledButton, 'Add admin'));
    await tester.pumpAndSettle();
    expect(server.calls, isEmpty);
  });
}
