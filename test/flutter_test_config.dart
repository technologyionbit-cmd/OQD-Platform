import 'dart:async';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';

/// Runs every test as if on an Arabic-language device — the app's primary
/// market and the language most assertions are written in. The app picks
/// its initial language from the device (see LocaleController), so without
/// this the test host's own locale would decide. Tests covering the device
/// language itself override `deviceLocalesProvider` or this value.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => binding.platformDispatcher.localesTestValue = const [Locale('ar')]);
  await testMain();
}
