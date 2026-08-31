import 'package:aqd_ionbit/core/security/token_manager.dart';

/// Two small "ports" [AuthInterceptor] calls into without `core` depending
/// on `features/auth` directly (that dependency would run the wrong way in
/// Clean Architecture — core must stay feature-agnostic). The auth feature
/// registers the real handlers at startup; until then both are safe no-ops.

typedef RefreshTokenFn = Future<AuthTokens?> Function();

class TokenRefresher {
  RefreshTokenFn? _refresh;

  void register(RefreshTokenFn refresh) => _refresh = refresh;

  Future<AuthTokens?> call() => _refresh?.call() ?? Future.value(null);
}

class SessionExpiredNotifier {
  void Function()? _handler;

  void registerHandler(void Function() handler) => _handler = handler;

  void notify() => _handler?.call();
}
