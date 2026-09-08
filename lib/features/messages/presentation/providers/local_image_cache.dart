import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// In-memory, session-only cache mapping a mock attachment reference to the
/// actual picked image bytes. `Message.attachmentUrl` only ever carries an
/// opaque mock reference (no real upload happens — see the `messages`
/// feature's data layer), so the bytes needed to actually render a
/// just-picked image before it's "sent" have to live somewhere; this is
/// that somewhere. Cleared automatically on app restart, same as the rest
/// of this mock chat feature.
class LocalImageCache {
  final Map<String, Uint8List> _bytesByReference = {};

  void put(String reference, Uint8List bytes) => _bytesByReference[reference] = bytes;

  Uint8List? get(String? reference) => reference == null ? null : _bytesByReference[reference];
}

final localImageCacheProvider = Provider<LocalImageCache>((ref) => LocalImageCache());
