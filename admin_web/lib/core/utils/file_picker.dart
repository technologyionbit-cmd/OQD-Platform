import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aqd_admin/core/utils/file_picker_stub.dart' if (dart.library.js_interop) 'package:aqd_admin/core/utils/file_picker_web.dart' as impl;

/// A file the admin chose from their computer.
class PickedFile {
  const PickedFile(this.name, this.bytes);

  final String name;
  final Uint8List bytes;
}

/// Opens the browser's file chooser; null if the admin cancelled. A
/// provider so tests can hand in a file without a browser.
typedef FilePicker = Future<PickedFile?> Function({required String accept});

final filePickerProvider = Provider<FilePicker>((ref) => impl.pickFile);
