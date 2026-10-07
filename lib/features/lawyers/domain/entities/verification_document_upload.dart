import 'dart:typed_data';

/// One file a lawyer sends for verification (ID or bar card photo, or a
/// PDF). The server checks the real type from the bytes, so [fileName] is
/// only a label.
class VerificationDocumentUpload {
  const VerificationDocumentUpload({required this.fileName, required this.bytes});

  final String fileName;
  final Uint8List bytes;

  /// Server limits (see backend `verification-files.ts`).
  static const maxFiles = 3;
  static const maxBytes = 10 * 1024 * 1024;
  static const allowedExtensions = ['jpg', 'jpeg', 'png', 'pdf'];
}
