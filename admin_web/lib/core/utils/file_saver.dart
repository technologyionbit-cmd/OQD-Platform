import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aqd_admin/core/utils/file_saver_stub.dart' if (dart.library.js_interop) 'package:aqd_admin/core/utils/file_saver_web.dart' as impl;

/// Hands a downloaded file to the browser's "save as". A provider so tests
/// can capture the bytes instead of touching the DOM.
typedef FileSaver = Future<void> Function(String filename, Uint8List bytes, String mimeType);

final fileSaverProvider = Provider<FileSaver>((ref) => impl.saveFile);
