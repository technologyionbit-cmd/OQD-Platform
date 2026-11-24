import 'dart:io';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_test/flutter_test.dart';

import 'package:aqd_ionbit/core/pdf/pdf_documents.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  prepareTests();

  test('builds a real PDF from an Arabic contract', () async {
    final fonts = await PdfFonts.load(rootBundle);
    final bytes = await buildContractPdf(
      fonts: fonts,
      title: 'عقد عمل',
      subtitle: 'مسودة للمراجعة',
      parties: const ['شركة النور للتجارة', 'أحمد الخالدي'],
      content: 'تم الاتفاق بين الطرف الأول: شركة النور للتجارة، والطرف الثاني: أحمد الخالدي (Ahmad Khaldi)،\n'
          'على أن يعمل الطرف الثاني بوظيفة مهندس برمجيات براتب شهري قدره 1,200 دينار أردني اعتباراً من 2026-12-01.\n\n'
          'مدة العقد سنة واحدة قابلة للتجديد.',
      rtl: true,
      footer: 'عقد',
    );
    expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
    expect(bytes.length, greaterThan(2000));
    // A reviewable copy: open it to check the Arabic is joined and in order.
    final out = File('${Directory.systemTemp.path}/aqd_contract_sample.pdf');
    await out.writeAsBytes(bytes);
    expect(out.existsSync(), isTrue);
  });

  test('builds a procedure checklist PDF in English', () async {
    final fonts = await PdfFonts.load(rootBundle);
    final bytes = await buildProcedurePdf(
      fonts: fonts,
      title: 'Company registration',
      rtl: false,
      durationHeading: 'Duration',
      duration: '7 business days',
      documentsHeading: 'Required documents',
      documents: const ['Valid national ID for all partners', 'Notarized articles of incorporation'],
      stepsHeading: 'Steps',
      steps: const [(title: 'Prepare documents', description: 'Collect IDs and supporting documents'), (title: 'Submit the request', description: 'Submit via the online platform')],
    );
    expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
  });

  test('text that crashed the bidi package no longer fails the whole PDF', () async {
    final fonts = await PdfFonts.load(rootBundle);
    final bytes = await buildContractPdf(
      fonts: fonts,
      title: 'عقد أُجرة',
      subtitle: 'مُسوّدة',
      parties: const ['أُحمد', 'إِبراهيم'],
      content: 'يلتزم الطرف الأُوّل بدفع الأجرة.\nوتُعدّ هذه الأحكامُ ملزمةً.',
      rtl: true,
      footer: 'أُعدّ عبر عقد',
    );
    expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
  });

  test('an Arabic procedure PDF builds too', () async {
    final fonts = await PdfFonts.load(rootBundle);
    final bytes = await buildProcedurePdf(
      fonts: fonts,
      title: 'تسجيل شركة',
      rtl: true,
      durationHeading: 'المدة',
      duration: '٧ أيام عمل',
      documentsHeading: 'المستندات المطلوبة',
      documents: const ['الهوية الوطنية سارية المفعول لجميع الشركاء'],
      stepsHeading: 'الخطوات',
      steps: const [(title: 'تجهيز المستندات', description: 'تجميع الهويات وعقد التأسيس والوثائق الداعمة')],
    );
    expect(bytes.length, greaterThan(2000));
    await File('${Directory.systemTemp.path}/aqd_procedure_sample.pdf').writeAsBytes(bytes);
  });
}

void prepareTests() {
  group('prepareArabicText', () {
    test('writes ISO dates with slashes and a leading plus as 00', () {
      expect(prepareArabicText('من 2026-12-01 إلى 2027-1-5'), 'من 2026/12/01 إلى 2027/1/5');
      expect(prepareArabicText('+962791234567'), '00962791234567');
    });

    test('drops a diacritic after a hamza letter, which crashes the layout library', () {
      expect(prepareArabicText('أُعدّ عبر عقد'), 'أعدّ عبر عقد');
      expect(prepareArabicText('إِذا آَمن ؤُ ئِ'), 'إذا آمن ؤ ئ');
      // Other letters keep their marks.
      expect(prepareArabicText('الأوّل تعذّر محمَّد'), 'الأوّل تعذّر محمَّد');
    });

    test('leaves everything else alone', () {
      const text = 'المبلغ 1,200 والساعة 10:30 (مرجع A-12) و 12-3';
      expect(prepareArabicText(text), text);
      expect(prepareArabicText('رقم 120261201 فقط'), 'رقم 120261201 فقط');
    });
  });
}
