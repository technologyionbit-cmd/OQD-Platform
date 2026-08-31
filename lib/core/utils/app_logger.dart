import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

enum LogLevel { debug, info, warning, error }

/// Thin wrapper around `dart:developer.log` (visible in DevTools/IDE
/// consoles without pulling in a logging package).
///
/// Every call site is expected to pass already-safe data — this class does
/// not attempt to scan arbitrary strings for secrets. The rule is upstream:
/// interceptors and repositories must never pass a token, password, or full
/// payment payload into [error]/[warning]/[info]/[debug] in the first place.
class AppLogger {
  const AppLogger._();

  static void debug(String message, {String name = 'aqd'}) {
    if (kReleaseMode) return;
    _log(LogLevel.debug, message, name: name);
  }

  static void info(String message, {String name = 'aqd'}) {
    if (kReleaseMode) return;
    _log(LogLevel.info, message, name: name);
  }

  static void warning(String message, {String name = 'aqd'}) {
    _log(LogLevel.warning, message, name: name);
  }

  static void error(String message, {Object? error, StackTrace? stackTrace, String name = 'aqd'}) {
    developer.log(
      message,
      name: name,
      level: 1000,
      error: error,
      stackTrace: stackTrace,
    );
  }

  static void _log(LogLevel level, String message, {required String name}) {
    developer.log(message, name: name, level: _levelValue(level));
  }

  static int _levelValue(LogLevel level) => switch (level) {
    LogLevel.debug => 500,
    LogLevel.info => 800,
    LogLevel.warning => 900,
    LogLevel.error => 1000,
  };
}
