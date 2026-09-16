import 'package:dio/dio.dart';

import 'package:aqd_ionbit/core/config/app_config.dart';
import 'package:aqd_ionbit/core/network/interceptors/auth_interceptor.dart';
import 'package:aqd_ionbit/core/network/interceptors/redacting_logging_interceptor.dart';
import 'package:aqd_ionbit/core/security/token_manager.dart';

/// Builds the single, app-wide [Dio] instance. Every feature's remote data
/// source takes this same client — no feature creates its own `Dio()`.
class DioClient {
  DioClient({
    required AppConfig appConfig,
    required TokenManager tokenManager,
    required void Function() onSessionExpired,
    Future<AuthTokens?> Function()? onRefreshToken,
  }) {
    dio = Dio(
      BaseOptions(
        baseUrl: appConfig.apiBaseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(seconds: 30),
      ),
    );

    dio.interceptors.add(
      AuthInterceptor(
        dio: dio,
        tokenManager: tokenManager,
        // The auth feature registers the real refresh handler at startup
        // (see AuthController.build); until then this defaults to "refresh
        // always fails", which routes straight to onSessionExpired.
        onRefreshToken: onRefreshToken ?? () async => null,
        onSessionExpired: onSessionExpired,
      ),
    );

    if (appConfig.enableNetworkLogging) {
      dio.interceptors.add(RedactingLoggingInterceptor());
    }
  }

  late final Dio dio;
}
