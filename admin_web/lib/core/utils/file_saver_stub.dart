import 'dart:typed_data';

/// Non-web builds (tests, tooling) cannot save files.
Future<void> saveFile(String filename, Uint8List bytes, String mimeType) async {
  throw UnsupportedError('Saving files needs the web build');
}
