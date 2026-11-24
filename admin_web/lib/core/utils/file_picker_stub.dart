import 'package:aqd_admin/core/utils/file_picker.dart';

/// Non-web builds (tests, tooling) cannot open a file chooser.
Future<PickedFile?> pickFile({required String accept}) async {
  throw UnsupportedError('Picking files needs the web build');
}
