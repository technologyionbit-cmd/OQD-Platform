import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';

import 'package:aqd_ionbit/core/network/api_error_mapper.dart';
import 'package:aqd_ionbit/core/pdf/pdf_documents.dart';
import 'package:aqd_ionbit/core/providers/core_providers.dart';

/// The Arabic font, read from the app bundle once.
final pdfFontsProvider = FutureProvider<PdfFonts>((ref) => PdfFonts.load(rootBundle));

/// Hands a finished PDF to the person: the share sheet on a phone, a save
/// or print dialog elsewhere. A provider so tests can capture the bytes.
typedef PdfSharer = Future<void> Function(Uint8List bytes, String filename);

final pdfSharerProvider = Provider<PdfSharer>((ref) {
  return (bytes, filename) => Printing.sharePdf(bytes: bytes, filename: filename);
});

/// Downloads an official PDF staff uploaded (contract template or
/// procedure). Throws a `Failure` if there is none or the request fails.
class OfficialPdfLoader {
  OfficialPdfLoader(this._dio, {ApiErrorMapper errorMapper = const ApiErrorMapper()}) : _errorMapper = errorMapper;

  final Dio _dio;
  final ApiErrorMapper _errorMapper;

  Future<Uint8List> load(String path) {
    return _errorMapper.guard(() async {
      final res = await _dio.get<List<int>>(path, options: Options(responseType: ResponseType.bytes));
      return Uint8List.fromList(res.data!);
    });
  }
}

final officialPdfLoaderProvider = Provider<OfficialPdfLoader>((ref) => OfficialPdfLoader(ref.watch(dioProvider)));

/// A file name made from a title: letters (any script), digits and dashes.
String pdfFileName(String title) {
  final cleaned = title.trim().replaceAll(RegExp(r'[^\p{L}\p{N}]+', unicode: true), '-').replaceAll(RegExp(r'^-+|-+$'), '');
  return '${cleaned.isEmpty ? 'document' : cleaned}.pdf';
}
