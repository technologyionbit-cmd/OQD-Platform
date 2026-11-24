import 'dart:typed_data';

import 'package:flutter/services.dart' show AssetBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// The app's Arabic-capable font, loaded once for PDFs. IBM Plex Sans
/// Arabic has Arabic and Latin letters, so a mixed Arabic/English text
/// (names, dates, numbers) prints correctly.
class PdfFonts {
  const PdfFonts({required this.regular, required this.bold});

  final pw.Font regular;
  final pw.Font bold;

  static Future<PdfFonts> load(AssetBundle bundle) async {
    final regular = await bundle.load('assets/fonts/IBMPlexSansArabic-Regular.ttf');
    final bold = await bundle.load('assets/fonts/IBMPlexSansArabic-Bold.ttf');
    return PdfFonts(regular: pw.Font.ttf(regular), bold: pw.Font.ttf(bold));
  }
}

/// Arabic text in a PDF: the layout library's bidi step flips numbers that
/// are joined by a hyphen ("2026-12-01" prints as "01-12-2026") and moves a
/// leading plus to the end ("+962..." prints as "962...+"). Slashes, colons,
/// commas and dots are fine, so dates are written with slashes and an
/// international prefix as 00. Only used for right-to-left documents.
///
/// The same bidi step also throws a RangeError (and the whole PDF fails)
/// on a hamza or madda letter (أ إ آ ؤ ئ) followed by a diacritic such as
/// "أُ", so a mark right after one of those is dropped.
String prepareArabicText(String text) {
  return text
      .replaceAllMapped(RegExp('([آ-ئ])[ً-ْٰ]+'), (m) => m[1]!)
      .replaceAllMapped(RegExp(r'(?<!\d)(\d{4})-(\d{1,2})-(\d{1,2})(?!\d)'), (m) => '${m[1]}/${m[2]}/${m[3]}')
      .replaceAllMapped(RegExp(r'\+(?=\d)'), (_) => '00');
}

const _ink = PdfColor.fromInt(0xFF0F1B2B);
const _muted = PdfColor.fromInt(0xFF5B6472);
const _brand = PdfColor.fromInt(0xFF0078C0);

pw.Document _document(PdfFonts fonts) => pw.Document(theme: pw.ThemeData.withFont(base: fonts.regular, bold: fonts.bold));

pw.Widget _header(String title, {required bool rtl, String? subtitle}) {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Text(title, style: const pw.TextStyle(fontSize: 22, wordSpacing: 4, fontWeight: pw.FontWeight.bold, color: _ink)),
      if (subtitle != null && subtitle.isNotEmpty) ...[pw.SizedBox(height: 4), pw.Text(subtitle, style: const pw.TextStyle(fontSize: 11, color: _muted))],
      pw.SizedBox(height: 8),
      pw.Container(height: 2, color: _brand),
      pw.SizedBox(height: 16),
    ],
  );
}

pw.Widget _footer(pw.Context context, String? text) {
  return pw.Padding(
    padding: const pw.EdgeInsets.only(top: 12),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(text ?? '', style: const pw.TextStyle(fontSize: 9, color: _muted)),
        pw.Text('${context.pageNumber} / ${context.pagesCount}', style: const pw.TextStyle(fontSize: 9, color: _muted)),
      ],
    ),
  );
}

/// A contract as a printable document: [title], optionally the [parties],
/// then the generated [content], one paragraph per line.
Future<Uint8List> buildContractPdf({
  required PdfFonts fonts,
  required String title,
  required String content,
  required bool rtl,
  List<String> parties = const [],
  String? subtitle,
  String? footer,
}) {
  final doc = _document(fonts);
  String t(String text) => rtl ? prepareArabicText(text) : text;
  final lines = t(content).split(RegExp(r'\r?\n'));
  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(40),
      textDirection: rtl ? pw.TextDirection.rtl : pw.TextDirection.ltr,
      header: (_) => _header(t(title), rtl: rtl, subtitle: subtitle == null ? null : t(subtitle)),
      footer: (context) => _footer(context, footer == null ? null : t(footer)),
      build: (context) => [
        if (parties.isNotEmpty) ...[pw.Text(t(parties.join('   •   ')), style: const pw.TextStyle(fontSize: 12, wordSpacing: 3, fontWeight: pw.FontWeight.bold)), pw.SizedBox(height: 12)],
        for (final line in lines)
          line.trim().isEmpty
              ? pw.SizedBox(height: 8)
              : pw.Padding(padding: const pw.EdgeInsets.only(bottom: 6), child: pw.Text(line, style: const pw.TextStyle(fontSize: 12, lineSpacing: 4, wordSpacing: 3, color: _ink))),
      ],
    ),
  );
  return doc.save();
}

/// A government procedure as a checklist: how long it takes, the documents
/// to bring, and the steps. Headings are passed in so they follow the
/// reader's language.
Future<Uint8List> buildProcedurePdf({
  required PdfFonts fonts,
  required String title,
  required bool rtl,
  required String durationHeading,
  required String duration,
  required String documentsHeading,
  required List<String> documents,
  required String stepsHeading,
  required List<({String title, String description})> steps,
  String? footer,
}) {
  final doc = _document(fonts);
  String fix(String text) => rtl ? prepareArabicText(text) : text;
  String t(String text) => fix(text);
  pw.Widget heading(String text) => pw.Padding(
    padding: const pw.EdgeInsets.only(top: 14, bottom: 8),
    child: pw.Text(text, style: const pw.TextStyle(fontSize: 15, fontWeight: pw.FontWeight.bold, color: _brand)),
  );

  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(40),
      textDirection: rtl ? pw.TextDirection.rtl : pw.TextDirection.ltr,
      header: (_) => _header(fix(title), rtl: rtl),
      footer: (context) => _footer(context, footer == null ? null : t(footer)),
      build: (context) => [
        pw.Text(fix('$durationHeading: $duration'), style: const pw.TextStyle(fontSize: 12, wordSpacing: 3, fontWeight: pw.FontWeight.bold)),
        heading(fix(documentsHeading)),
        for (final d in documents)
          pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 6),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Container(width: 10, height: 10, margin: const pw.EdgeInsets.only(top: 3, left: 6, right: 6), decoration: pw.BoxDecoration(border: pw.Border.all(color: _muted))),
                pw.Expanded(child: pw.Text(fix(d), style: const pw.TextStyle(fontSize: 12, lineSpacing: 3, wordSpacing: 3))),
              ],
            ),
          ),
        heading(fix(stepsHeading)),
        for (final (i, s) in steps.indexed)
          pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 10),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Container(
                  width: 20,
                  height: 20,
                  margin: const pw.EdgeInsets.only(left: 6, right: 6),
                  alignment: pw.Alignment.center,
                  decoration: const pw.BoxDecoration(color: _brand, shape: pw.BoxShape.circle),
                  child: pw.Text('${i + 1}', style: const pw.TextStyle(fontSize: 10, color: PdfColors.white)),
                ),
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(fix(s.title), style: const pw.TextStyle(fontSize: 12, wordSpacing: 3, fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 2),
                      pw.Text(fix(s.description), style: const pw.TextStyle(fontSize: 11, lineSpacing: 3, wordSpacing: 3, color: _muted)),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    ),
  );
  return doc.save();
}
