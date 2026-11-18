import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// How long the splash screen stays up at cold start even if the session
/// resolves sooner. Zero here so tests never wait; `bootstrap()` sets the
/// real value.
final splashMinDurationProvider = Provider<Duration>((ref) => Duration.zero);

/// True from app start until [splashMinDurationProvider] has elapsed. The
/// router keeps the user on the splash while this is true, then lets its
/// normal redirect rules take over.
final splashHoldProvider = NotifierProvider<SplashHold, bool>(SplashHold.new);

class SplashHold extends Notifier<bool> {
  @override
  bool build() {
    final duration = ref.watch(splashMinDurationProvider);
    if (duration <= Duration.zero) return false;
    final timer = Timer(duration, () => state = false);
    ref.onDispose(timer.cancel);
    return true;
  }
}
