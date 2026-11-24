import 'dart:async';
import 'dart:js_interop';

import 'package:web/web.dart' as web;

import 'package:aqd_admin/core/utils/file_picker.dart';

Future<PickedFile?> pickFile({required String accept}) {
  final done = Completer<PickedFile?>();
  final input = web.HTMLInputElement()
    ..type = 'file'
    ..accept = accept;

  void finish(PickedFile? file) {
    if (!done.isCompleted) done.complete(file);
  }

  // The callbacks handed to JS must return void, so the async read is
  // started with `.then` rather than by making the callback async.
  input.addEventListener(
    'change',
    ((web.Event _) {
      final file = input.files?.item(0);
      if (file == null) {
        finish(null);
        return;
      }
      file.arrayBuffer().toDart.then((buffer) => finish(PickedFile(file.name, buffer.toDart.asUint8List())), onError: (Object _) => finish(null));
    }).toJS,
  );
  // Fired by current browsers when the chooser is closed without a file.
  input.addEventListener('cancel', ((web.Event _) => finish(null)).toJS);

  input.click();
  return done.future;
}
