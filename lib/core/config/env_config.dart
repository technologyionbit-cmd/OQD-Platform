import 'package:aqd_ionbit/core/config/environment.dart';

/// Build-time configuration for one environment.
///
/// [apiBaseUrl] below is a **placeholder** — the real Aqd backend contract
/// has not been shared with the frontend yet (see `core/network/README` /
/// the auth data layer, which is mock-backed for the same reason). Nothing
/// currently calls this URL. Once the backend is wired in, override it via
/// `--dart-define-from-file=env/<environment>.json` without touching any
/// other file — every consumer reads through [EnvConfig], never a literal.
class EnvConfig {
  const EnvConfig({
    required this.environment,
    required this.apiBaseUrl,
    required this.enableNetworkLogging,
  });

  factory EnvConfig.forEnvironment(Environment environment) {
    // `--dart-define-from-file=env/<name>.json` overrides these placeholders
    // at compile time without requiring a code change.
    const definedApiBaseUrl = String.fromEnvironment('API_BASE_URL');

    switch (environment) {
      case Environment.development:
        return EnvConfig(
          environment: environment,
          apiBaseUrl: definedApiBaseUrl.isNotEmpty ? definedApiBaseUrl : 'https://dev-api.aqd.example.com/v1',
          enableNetworkLogging: true,
        );
      case Environment.staging:
        return EnvConfig(
          environment: environment,
          apiBaseUrl: definedApiBaseUrl.isNotEmpty ? definedApiBaseUrl : 'https://staging-api.aqd.example.com/v1',
          enableNetworkLogging: true,
        );
      case Environment.production:
        return EnvConfig(
          environment: environment,
          apiBaseUrl: definedApiBaseUrl.isNotEmpty ? definedApiBaseUrl : 'https://api.aqd.example.com/v1',
          enableNetworkLogging: false,
        );
    }
  }

  final Environment environment;
  final String apiBaseUrl;
  final bool enableNetworkLogging;

  bool get isProduction => environment == Environment.production;
}
