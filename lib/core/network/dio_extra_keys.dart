/// Keys used in `RequestOptions.extra` to signal per-request behavior to
/// interceptors (e.g. `dio.get(path, options: Options(extra: {DioExtraKeys.skipAuth: true}))`).
class DioExtraKeys {
  const DioExtraKeys._();

  /// Skip attaching the Authorization header (public endpoints: login,
  /// register, forgot-password, refresh itself).
  static const skipAuth = 'skipAuth';

  /// Internal — marks a request as already retried once after a token
  /// refresh, so [AuthInterceptor] never loops.
  static const retried = 'retried';
}
