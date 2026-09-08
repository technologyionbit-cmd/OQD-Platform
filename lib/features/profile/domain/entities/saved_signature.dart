import 'dart:typed_data';
import 'dart:ui';

enum SavedSignatureType { drawn, uploaded, typed }

class SavedSignatureState {
  const SavedSignatureState({this.type, this.savedAt, this.strokes = const [], this.typedText, this.imageBytes});

  final SavedSignatureType? type;
  final DateTime? savedAt;
  final List<List<Offset>> strokes;
  final String? typedText;
  final Uint8List? imageBytes;

  bool get hasSignature => type != null;
}
