import 'package:dio/dio.dart';

import 'package:aqd_ionbit/core/config/env_config.dart';
import 'package:aqd_ionbit/core/network/interceptors/auth_interceptor.dart';
import 'package:aqd_ionbit/core/network/interceptors/redacting_logging_interceptor.dart';
import 'package:aqd_ionbit/core/security/token_manager.dart';

/// Builds the single, app-wide [Dio] instance. Every feature's remote data
/// source takes this same client — no feature creates its own `Dio()`.
class DioClient {
  DioClient({
    required EnvConfig envConfig,
    required TokenManager tokenManager,
    required void Function() onSessionExpired,
    Future<AuthTokens?> Function()? onRefreshToken,
  }) {
    dio = Dio(
      BaseOptions(
        baseUrl: envConfig.apiBaseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(seconds: 30),
      ),
    );

    dio.interceptors.add(
      AuthInterceptor(
        dio: dio,
        tokenManager: tokenManager,
        // No real refresh endpoint yet (backend contract not available) —
        // defaults to "refresh always fails", which correctly routes to
        // onSessionExpired. Replace once the auth feature is wired to the
        // real backend; nothing else in this file needs to change.
        onRefreshToken: onRefreshToken ?? () async => null,
        onSessionExpired: onSessionExpired,
      ),
    );

    if (envConfig.enableNetworkLogging) {
      dio.interceptors.add(RedactingLoggingInterceptor());
    }
  }

  late final Dio dio;
}
