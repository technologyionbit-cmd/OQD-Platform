import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aqd_ionbit/features/auth/presentation/providers/current_user_id_provider.dart';
import 'package:aqd_ionbit/features/profile/domain/entities/saved_signature.dart';

/// The account's one saved signature (Account → Saved Signature, and later
/// reusable by any contract e-signature step) — mock storage only, held in
/// memory for the session.
class SavedSignatureController extends Notifier<SavedSignatureState> {
  @override
  SavedSignatureState build() {
    ref.watch(currentUserIdProvider); // Fresh state for each account.
    return const SavedSignatureState();
  }

  void saveDrawn(List<List<Offset>> strokes) {
    state = SavedSignatureState(type: SavedSignatureType.drawn, savedAt: DateTime.now(), strokes: strokes);
  }

  void saveTyped(String text) {
    state = SavedSignatureState(type: SavedSignatureType.typed, savedAt: DateTime.now(), typedText: text);
  }

  void saveUploaded(Uint8List imageBytes) {
    state = SavedSignatureState(type: SavedSignatureType.uploaded, savedAt: DateTime.now(), imageBytes: imageBytes);
  }

  void clear() => state = const SavedSignatureState();
}

final savedSignatureControllerProvider = NotifierProvider<SavedSignatureController, SavedSignatureState>(SavedSignatureController.new);
