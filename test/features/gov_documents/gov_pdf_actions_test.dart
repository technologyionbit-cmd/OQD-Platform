import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

import 'package:aqd_ionbit/core/localization/generated/app_localizations.dart';
import 'package:aqd_ionbit/core/pdf/pdf_providers.dart';
import 'package:aqd_ionbit/features/gov_documents/domain/entities/gov_procedure.dart';
import 'package:aqd_ionbit/features/gov_documents/presentation/utils/gov_pdf_actions.dart';

class _FakeLoader extends OfficialPdfLoader {
  _FakeLoader() : super(Dio());

  final paths = <String>[];

  @override
  Future<Uint8List> load(String path) async {
    paths.add(path);
    return Uint8List.fromList('%PDF-official'.codeUnits);
  }
}

GovProcedure _procedure({required bool hasPdf}) => GovProcedure(
  id: 'p1',
  type: GovProcedureType.companyRegistration,
  durationLabel: '٧ أيام عمل',
  accessType: GovProcedureAccessType.guide,
  hasPdf: hasPdf,
  requiredDocuments: const [GovRequiredDocument(id: 'd1', title: 'الهوية الوطنية')],
  steps: const [GovProcedureStep(order: 1, title: 'تجهيز المستندات', description: 'تجميع الهويات')],
);

Future<void> _tapDownload(WidgetTester tester, GovProcedure procedure, List<Override> overrides) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        locale: const Locale('ar'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: Scaffold(
          body: Consumer(
            builder: (context, ref, _) => TextButton(onPressed: () => downloadProcedurePdf(context, ref, procedure), child: const Text('download')),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('download'));
  // Building a PDF reads the font and runs real async work.
  await tester.runAsync(() => Future<void>.delayed(const Duration(seconds: 2)));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('a procedure with an official PDF downloads that file and builds nothing', (tester) async {
    final loader = _FakeLoader();
    final shared = <({Uint8List bytes, String name})>[];
    await _tapDownload(tester, _procedure(hasPdf: true), [
      officialPdfLoaderProvider.overrideWithValue(loader),
      pdfSharerProvider.overrideWithValue((bytes, name) async => shared.add((bytes: bytes, name: name))),
    ]);

    expect(loader.paths, ['/gov-procedures/p1/pdf']);
    expect(String.fromCharCodes(shared.single.bytes), '%PDF-official');
    expect(shared.single.name, 'تسجيل-شركة.pdf');
  });

  testWidgets('a procedure without one gets a PDF built from its documents and steps', (tester) async {
    final loader = _FakeLoader();
    final shared = <({Uint8List bytes, String name})>[];
    await _tapDownload(tester, _procedure(hasPdf: false), [
      officialPdfLoaderProvider.overrideWithValue(loader),
      pdfSharerProvider.overrideWithValue((bytes, name) async => shared.add((bytes: bytes, name: name))),
    ]);

    expect(loader.paths, isEmpty);
    expect(String.fromCharCodes(shared.single.bytes.take(5)), '%PDF-');
    expect(shared.single.bytes.length, greaterThan(2000));
  });
}
