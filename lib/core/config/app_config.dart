import 'package:flutter/foundation.dart';

/// Single runtime configuration for the app. There is one build — no
/// dev/staging/production flavors. [apiBaseUrl] defaults to the local
/// backend and can be overridden at compile time without touching code:
///
/// ```
/// flutter run --dart-define=API_BASE_URL=https://api.aqd.example.com/v1
/// ```
class AppConfig {
  const AppConfig({required this.apiBaseUrl, required this.enableNetworkLogging});

  factory AppConfig.resolve() {
    const defined = String.fromEnvironment('API_BASE_URL');
    return AppConfig(
      apiBaseUrl: defined.isNotEmpty ? defined : _defaultApiBaseUrl,
      enableNetworkLogging: !kReleaseMode,
    );
  }

  /// Local NestJS backend (`backend/`, `npm run dev`). On a physical
  /// device, override via `--dart-define=API_BASE_URL=...` with your
  /// machine's LAN address.
  static const _defaultApiBaseUrl = 'http://localhost:3000/v1';

  final String apiBaseUrl;
  final bool enableNetworkLogging;
}
