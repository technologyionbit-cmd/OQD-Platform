import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:aqd_ionbit/core/routing/splash_hold.dart';

void main() {
  test('holds for the configured duration, then releases', () async {
    final container = ProviderContainer(
      overrides: [splashMinDurationProvider.overrideWithValue(const Duration(milliseconds: 50))],
    );
    addTearDown(container.dispose);
    container.listen(splashHoldProvider, (_, _) {});

    expect(container.read(splashHoldProvider), isTrue);
    await Future<void>.delayed(const Duration(milliseconds: 120));
    expect(container.read(splashHoldProvider), isFalse);
  });

  test('is never held by default (tests)', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(splashHoldProvider), isFalse);
  });
}
