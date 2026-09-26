import 'package:aqd_ionbit/core/security/token_manager.dart';

/// Two small "ports" [AuthInterceptor] calls into without `core` depending
/// on `features/auth` directly (that dependency would run the wrong way in
/// Clean Architecture — core must stay feature-agnostic). The auth feature
/// registers the real handlers at startup; until then both are safe no-ops.

/// What happened when the interceptor asked for a token refresh. The
/// distinction between [RefreshRejected] and [RefreshUnavailable] is what
/// keeps a flaky connection from signing the user out: only the server
/// explicitly refusing the refresh token ends the session.
sealed class RefreshOutcome {
  const RefreshOutcome();
}

/// A fresh token pair was issued and persisted.
final class RefreshSucceeded extends RefreshOutcome {
  const RefreshSucceeded(this.tokens);

  final AuthTokens tokens;
}

/// The server refused the refresh token (expired, revoked, reused, or the
/// account is no longer active) — the session is over.
final class RefreshRejected extends RefreshOutcome {
  const RefreshRejected();
}

/// The refresh could not be completed right now (offline, timeout, 5xx).
/// The session may still be valid, so it must be kept.
final class RefreshUnavailable extends RefreshOutcome {
  const RefreshUnavailable();
}

typedef RefreshTokenFn = Future<RefreshOutcome> Function();

class TokenRefresher {
  RefreshTokenFn? _refresh;

  void register(RefreshTokenFn refresh) => _refresh = refresh;

  /// Before the auth feature registers a handler there is no way to
  /// refresh, so any 401 is treated as a rejected session.
  Future<RefreshOutcome> call() => _refresh?.call() ?? Future.value(const RefreshRejected());
}

class SessionExpiredNotifier {
  void Function()? _handler;

  void registerHandler(void Function() handler) => _handler = handler;

  void notify() => _handler?.call();
}
